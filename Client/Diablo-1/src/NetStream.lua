--[[
用于客户端，与服务器建立TCP连接。
1. TCP连接的建立与维护（连接、发送、接受、断线、连接失败检测、连接失败重连）
2. 数据包的第一层解包（对应Server端代码的NetStream）
]]

require "Util"

local NETSTREAM_TICK_TIME = 0.1 -- 检测服务端数据的时间间隔
local NETSTREAM_CONNECT_TIMEOUT = 5 -- 连接超时时长
local NETSTREAM_RECONNECT_TIME = 5 -- 失败重连时间间隔
local NETSTREAM_RECONNECT_MAX_NUM = 3 -- 失败重连最大次数

local NetStream = class("NetStream",function()
    return {}
end)

local NETSTREAM_STATE_CLOSED = 0 -- 关闭状态
local NETSTREAM_STATE_CONNECTING = 1 -- 尝试连接 
local NETSTREAM_STATE_CONNECT_FAIL = 2 -- 连接失败
local NETSTREAM_STATE_ESTABLISHED = 3 -- 连接建立
local NETSTREAM_STATE_DATA = 4 -- 接收新数据
local NETSTREAM_STATE_CLOSING = 5 -- 尝试关闭

-- 完成后改成这样的形式，在构造函数中进行初始化
--HEAD_HDR = (2, 2, 4, 4, 1, 1, 2, 2, 4, 4, 1, 1)
--HEAD_INC = (0, 0, 0, 0, 0, 0, 2, 2, 4, 4, 1, 1)
--HEAD_FMT = ('<H', '>H', '<I', '>I', '<B', '>B')  
local NETSTREAM_HEADINFO = {MODE = 8, HDR = 4, 
    INC = 4, FMT = "<I", INT = 2} -- 本地     

require "struct" -- 数据包格式解析
local _socket = require("socket") -- Socket对象



-- 根据当前客户端所在环境进行初始化，从而进行正确的数据包格式解析
function NetStream.create(__headMode)
    cclog("NetStream Create")
    local netStream = NetStream.new()
    
    netStream.headMode = __headMode
    return netStream
end



-- ”成员变量”的“初始化”
function NetStream:ctor()
    self.host = nil
    self.port = nil
    self.state = NETSTREAM_STATE_CLOSED
   
    self.socket = _socket.tcp() -- 初始化luasocket，封装tcp连接
    cclog("%s", self.socket._VERSION)
    
    self.tickScheduler = nil
    self.reConnectScheduler = nil
        
    self.recBuf = "" -- 接收消息的Buffer，因为Lua脚本单线程调用，所以这里不考虑读写同步问题
    self.sendBuf = "" -- 发送消息的Buffer，同理不考虑同步问题
end



-- 接收消息的执行函数
-- 目前没有想到好的封装方法
function NetStream:_tryReceive()

    local text, status, partial = self.socket:receive(128)
    local processText = text
    if status == "timeout" then
        processText = partial 
    end
    
    local _newStr = self.recBuf..processText
    self.recBuf = _newStr
    
    local function _peekRaw(__size)    
        local _recBufSize = string.len(self.recBuf)
        
        if 0 == _recBufSize then
            return ""
        end
        
        if __size > _recBufSize then
            __size = _recBufSize
        end
        
        local _rawData = string.sub(self.recBuf, 1, __size)
    
        return _rawData 
    end
    
    
    local function _recvRaw(__size)
        local _rawData = _peekRaw(__size)
        local _size = string.len(_rawData)
        local _newString = string.sub(self.recBuf, _size + 1, -1)
        self.recBuf = _newString
        
        return _rawData
    end
    
    local _rSize = _peekRaw(NETSTREAM_HEADINFO.HDR)
    
    if string.len(_rSize) < NETSTREAM_HEADINFO.HDR then
        return ""
    end
    
    local _tmp = struct.unpack(NETSTREAM_HEADINFO.FMT, _rSize)
    local _size = _tmp + NETSTREAM_HEADINFO.INC
    if string.len(self.recBuf) < _size then
        return ""
    end
    _recvRaw(NETSTREAM_HEADINFO.HDR)
    
    return _recvRaw(_size - NETSTREAM_HEADINFO.HDR)
end



-- 发送消息的执行函数
-- 目前没有想到好的封装方法
function NetStream:_trySend()    
    
    if string.len(self.sendBuf) == 0 then 
        return
    end
    
    -- 首先将数据打包成通用格式
    local size = string.len(self.sendBuf) + NETSTREAM_HEADINFO.HDR - NETSTREAM_HEADINFO.INC
    local wsize = struct.pack(NETSTREAM_HEADINFO.FMT, size)
    local sentData = wsize..self.sendBuf       
    self.sendBuf = ""
    
    -- 发送数据     
    local _len = self.socket:send(sentData)
    -- 检查发送长度逻辑
end



-- 发送消息的入口函数，供游戏层调用
function NetStream:send(__data)
    if self.state ~= NETSTREAM_STATE_ESTABLISHED then
        cclog("In NetStream:send(__data). Current connect is not established: %d", self.state)
        return
    end   

    -- 将当前消息加入原有消息
    -- TODO: 字符串连接效率待查明

    if __data then
        local newStr = self.sendBuf..__data
        self.sendBuf = newStr 
    end
   
    self:_trySend()     
end


-- 接收消息的入口函数，供游戏层调用
function NetStream:receive()
    if self.state ~= NETSTREAM_STATE_ESTABLISHED then
        cclog("In NetStream:receive(). Current connect is not established: %d", self.state)
        return
    end 
    local _data, _state = self:_tryReceive()
    if _data then
        return _data
    end
end



-- 开启连接入口函数
function NetStream:connect(__host, __port)    
    if self.state ~= NETSTREAM_STATE_CLOSED then
        cclog("In NetStream:connect(__host, __port). Current connect is not closed: %d", self.state)
        return
    end    
        
    cclog("Host address: %s, Port: %d", __host, __port)    
    if nil == __host or nil == __port then
        cclog("Incomplete host address or port!")
    end         
 
    -- 连接建立后的处理函数
    local function _onConnect()
        cclog("On connecting")
        self.socket:settimeout(0) --不阻塞立即返回 
        self.state = NETSTREAM_STATE_ESTABLISHED
        
        -- 网络层update函数
        local function _process()  
                  
--            if self.state == NETSTREAM_STATE_CLOSED then
--                return
--            end  
--                      
--            if self.state == NETSTREAM_STATE_CONNECTING then
--                -- 断线重连逻辑
--                return
--            end 
--                       
--            if self.state == NETSTREAM_STATE_ESTABLISHED then               
--                self:receive()
--            end   
--                                 
--            if self.state == NETSTREAM_STATE_ESTABLISHED then
--                self:send()
--            end
                       
        end   
        
        self.tickScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(_process, NETSTREAM_TICK_TIME, false)        
    end
    
    -- 尝试建立连接函数
    local function _tryConnect() 
        cclog("Start connecting")
        self.state = NETSTREAM_STATE_CONNECTING   
        self.socket:settimeout(NETSTREAM_CONNECT_TIMEOUT) --设置连接超时时长  
        local _result, _errorMsg = self.socket:connect(self.host, self.port) -- 调用luasocket connect接口进行连接
        if _result then
            _onConnect()
        else
            cclog("Failed to connect: %s", _errorMsg)
            -- 连接失败重连逻辑
        end 
    end
    
    self.host = __host
    self.port = __port
    _tryConnect() 
end

-- 关闭连接入口函数
function NetStream:close()
    if self.state ~= NETSTREAM_STATE_ESTABLISHED then
        cclog("In NetStream:close(). Current connect is not established: %d", self.state)
        return
    end 
    
    self.state = NETSTREAM_STATE_CLOSING
    cclog("Start closing")
    
    self.socket:close() 
    self.state = NETSTREAM_STATE_CLOSED
    cclog("Closed")
end


return NetStream
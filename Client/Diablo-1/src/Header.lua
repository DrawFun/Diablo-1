require "Util"

local Header = class("Header",function()
    return {}
end)

local struct = require("struct")

function Header.create(__type)
    local header = Header.new()
    __type = __type or 0
    header.type = __type 
    return header
end
       
function Header:ctor()    
    self.hfmt = 'I2'
    self.bfmt = ""
    self.strFlag = 'I'
    self.curIndex = 1
    self.raw = ""
    self.paramsName = {}
    self.indexParaNames = {}     
    return
end

function Header:appendParam(__pName, __pValue, __pType)
    if gStrTrim(__pType) == 's' then
        self.bfmt = self.bfmt..self.strFlag
        __pType = "%ds"
    end

    self.bfmt = self.bfmt..__pType
    table.insert(self.indexParaNames, __pName)      
    self.paramsName[__pName] = __pValue
end

function Header:getMsgType()
    local _type = struct.unpack('<I2', self.raw:sub(self.curIndex, self.curIndex + 1))
    self.curIndex = self.curIndex + 2
    return _type
end

function Header:readStr()
    local _length = struct.unpack("<i", self.raw:sub(self.curIndex, self.curIndex + 4))
    self.curIndex = self.curIndex + 4
    local _str = struct.unpack("<c".._length, self.raw:sub(self.curIndex, self.curIndex + _length))
    self.curIndex = self.curIndex + _length
    return _str
end

function Header:readInt()
    local _integer = struct.unpack("<i", self.raw:sub(self.curIndex, self.curIndex + 4))
    self.curIndex = self.curIndex + 4
    return _integer   
end

function Header:marshal()
    local rawStr = struct.pack("<I2", self.type);
    local fmtIndex = 1     
    for key, pName in ipairs(self.indexParaNames) do
        local curChar = string.sub(self.bfmt, fmtIndex, fmtIndex)
        local curValue = self.paramsName[pName] 
        if curChar == 'i' then
            rawStr = rawStr..struct.pack("<i", curValue)
            fmtIndex = fmtIndex + 1
        elseif curChar == 'I' then
            local length = string.len(curValue)
            rawStr = rawStr..struct.pack("<i", length)..struct.pack("<c"..length, curValue)
            fmtIndex = fmtIndex + 4
        else
            assert(0)
        end
    end
    return rawStr
end

function Header:unmarshal(__raw)
    if __raw and __raw:len() > 0 then
        self.raw = __raw
    end

    local _type = self:getMsgType()
    if self.type ~= _type then
        assert(0)
        return nil
    else        
        local paraIndex = 1
        local fmtIndex = 1        
        while fmtIndex <= string.len(self.bfmt) do        
            local curChar = string.sub(self.bfmt, fmtIndex, fmtIndex)            
            local curValue = nil
            if curChar == 'i' then
                curValue = self:readInt()
                fmtIndex = fmtIndex + 1                           
            elseif curChar == 'I' then
                curValue = self:readStr()    
                fmtIndex = fmtIndex + 4  
            else
                break                
            end            
            self.paramsName[self.indexParaNames[paraIndex]] = curValue
            self[self.indexParaNames[paraIndex]] = curValue
            paraIndex = paraIndex + 1
        end
        return
    end
end

return Header
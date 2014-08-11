--[[
用于客户端，定义与服务器通信信息的格式
]]

MSG_CS_LOGIN    = 0x1001
MSG_SC_CONFIRM  = 0x2001

MSG_CS_MOVETO   = 0x1002
MSG_SC_MOVETO   = 0x2002

MSG_CS_CHAT     = 0x1003
MSG_SC_CHAT     = 0x2003

MSG_SC_ADDUSER  = 0x2004
MSG_SC_DELUSER  = 0x2005

local MSGHeader = require("Header")

function MSG_CS_LOGIN_CREATE(_name, _icon)
    
    local name = _name or ''
    local icon = _icon or 1
    
    local msg = MSGHeader.create(MSG_CS_LOGIN)
    msg:appendParam('name', name, 's')        
    msg:appendParam('icon', icon, 'i')

    
    return msg
end

function MS_SC_CONFIRM_CREATE(_uid, _result)

    local uid = _uid or 0
    local result = _result or 0

    local msg = MSGHeader.create(MSG_SC_CONFIRM)
    msg:appendParam('uid', uid, 'i')
    msg:appendParam('result', result, 'i')    

    return msg
end

function MSG_CS_MOVETO_CREATE(_x, _y)

    local x = _x or 0
    local y = _y or 0
    
    local msg = MSGHeader.create(MSG_CS_MOVETO)
    msg:appendParam('x', x, 'i')
    msg:appendParam('y', y, 'i')
    
    return msg
end

function MSG_SC_MOVETO_CREATE(_uid, _x, _y)
    
    local uid = _uid or 0
    local x = _x or 0
    local y = _y or 0

    local msg = MSGHeader.create(MSG_SC_MOVETO)
    msg:appendParam('uid', uid, 'i')
    msg:appendParam('x', x, 'i')
    msg:appendParam('y', y, 'i')

    return msg    
end

function MSG_CS_CHAT_CREATE(_text)

    local text = _text or ""
    
    local msg = MSGHeader.create(MSG_CS_CHAT)
    msg:appendParam('text', text, 's')
    
    return msg 
end

function MSG_SC_CHAT_CREATE(_uid, _text)

    local uid = _uid or 0
    local text = _text or ""
    
    local msg = MSGHeader.create(MSG_SC_CHAT)
    msg:appendParam('uid', uid, 'i')
    msg:appendParam('text', text, 's')
    
    return msg
end

function MSG_SC_ADDUSER_CREATE(_uid, _name, _x, _y)

    local uid = _uid or 0
    local name = _name or ""
    local x = _x or 0
    local y = _y or 0
    
    local msg = MSGHeader.create(MSG_SC_ADDUSER)
    msg:appendParam('uid', uid, 'i')
    msg:appendParam('name', name, 's')
    msg:appendParam('x', x, 'i')
    msg:appendParam('y', y, 'i')
    
    return msg
end

function MSG_SC_DELUSER_CREATE(_uid)

    local uid = _uid or 0
    
    local msg = MSGHeader.create(MSG_SC_DELUSER)
    msg:appendParam('uid', uid, 'i')
    
    return msg
end






function testSerialization()
    require("Util")

    local _headerClass = require("Message")
    
    local function testMarshal()
        local chatMsg = MSG_SC_CHAT_CREATE(99, "hello world")
        local chatMsg1 = MSG_SC_CHAT_CREATE()
        local chatMsgRawStr = chatMsg:marshal()
        chatMsg1:unmarshal(chatMsgRawStr)
        print(chatMsg1.uid, chatMsg1.text)        
    end
    
    cclog("SERIALIZATION TEST START ^-^")  
    testMarshal()
    cclog("SERIALIZATION TEST PASS ^-^")

end


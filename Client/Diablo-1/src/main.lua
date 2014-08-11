require "Cocos2d"

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
                
    cc.FileUtils:getInstance():addSearchPath("src")
    cc.FileUtils:getInstance():addSearchPath("res")
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(960, 640, 0)
--    
    --create scene 
    local scene = require("GameScene")
    local gameScene = scene.create()    
    

    

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
    
--    require("testcase.TestUtil")
--    testStringUtil()
--    testHeapUtil()
--    require("testcase.TestSerialization")
--    testSerialization()
    
    
end

function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end

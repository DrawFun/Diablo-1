require "Cocos2d"
require "Cocos2dConstants"
require "Util"

local GameScene = class("GameScene",function()
    return cc.Scene:create()
end)

function GameScene.create()    
    local scene = GameScene.new()
    scene.tiledLayer = scene:createTileLayer()
    scene:addChild(scene.tiledLayer)
    return scene
end

function GameScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end

function GameScene:createTileLayer()
    local layer = cc.Layer:create()
    local TiledMapCreator = require("TiledMap")
    local tiledMap = TiledMapCreator.create()

    local player = require("Player")
    local gamePlayer = player.create()   
    tiledMap.map:addChild(gamePlayer, 1)
    
    local net = require("NetStream")
    local network = net.create(8)
    network:connect("127.0.0.1", 2000)        


    layer:addChild(tiledMap.map, 0)           

    local function onTouchBagan(touch, event)
        gamePlayer:stopAllActions()
        local touchPos = touch:getLocation()
        local playerLX, playerLY = tiledMap:getLogicalPos(gamePlayer:getPositionX(), gamePlayer:getPositionY()) 
        local logicalX, logicalY = tiledMap:getLogicalPos(touchPos.x, touchPos.y)             
        local newX, newY = tiledMap:alignPos(touchPos.x, touchPos.y)     
        -- gamePlayer:setPosition(newX, newY)
        local tmp = tiledMap.collision2DArray[logicalX][logicalY]
        cclog("(%d, %d) = %s", logicalX, logicalY, tmp.isCollision)
        
        require("Message")
--        local chatMsg = MSG_SC_CHAT_CREATE(99, "hello world")      
--        network:send(chatMsg:marshal())
--        local revData = network:receive()
--        cclog("%s", revData)        

        local posMsg = MSG_SC_MOVETO_CREATE(100, logicalX, logicalY)   
        local posMsg1 = MSG_CS_MOVETO_CREATE()   
        network:send(posMsg:marshal())
        local revPos = network:receive()
        if string.len(revPos) > 0 then
            posMsg1:unmarshal(revPos)
            cclog("%d, %d", posMsg1.x, posMsg1.y)
            gamePlayer:setPosition(posMsg1.x, posMsg1.y)
        end

           
        local path = tiledMap:findPath(playerLX, playerLY, logicalX, logicalY)
        local i = #path - 1
       
        local seq = {}
        
        while i > 0 do
            local lastX, lastY = tiledMap:getPhysicalPos(path[i].x, path[i].y)
            local curX, curY = tiledMap:getPhysicalPos(path[i + 1].x, path[i + 1].y) 
            local act = cc.MoveTo:create(0.1, cc.p(lastX, lastY));
            table.insert(seq, act)
            i = i - 1
        end
        
        if #seq > 0 then
            local acts = cc.Sequence:create(seq)
            gamePlayer:runAction(acts)            
        else
            cclog("Can't move in")
        end
    end

    local function onTouchMoved(touch, event)
        print("WHY NOT CALL")
    end
    
    local function onTouchEnded(touch, event)
        print("TOUCH END")
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBagan,cc.Handler.EVENT_TOUCH_BEGAN )  
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )    
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )     
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    return layer
end    

return GameScene

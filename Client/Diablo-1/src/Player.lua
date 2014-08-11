require "Cocos2d"
require "Cocos2dConstants"
require "Util"

local Player = class("Player",function()
    return cc.Sprite:create()
end)

function Player.create()
    local frameWidth = 105
    local frameHeight = 95

    -- create dog animate
    local textureDog = cc.Director:getInstance():getTextureCache():addImage("dog.png")
    local rect = cc.rect(0, 0, frameWidth, frameHeight)
    local frame0 = cc.SpriteFrame:createWithTexture(textureDog, rect)
    rect = cc.rect(frameWidth, 0, frameWidth, frameHeight)
    local frame1 = cc.SpriteFrame:createWithTexture(textureDog, rect)

    local player = cc.Sprite:createWithSpriteFrame(frame0)
    
    player:setScale(32 / 105.0, 32 / 95.0)
    player:setAnchorPoint(0, 0)

    player.isPaused = false
    player:setPosition(100, 100)

    local animation = cc.Animation:createWithSpriteFrames({frame0,frame1}, 0.5)
    local animate = cc.Animate:create(animation);
    player:runAction(cc.RepeatForever:create(animate))        
    
    -- moving dog at every frame
    local function tick()
        --print "hehe"
        return
    end

    schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 3, false)
  
    return player
end


function Player:ctor()
    return
end

return Player
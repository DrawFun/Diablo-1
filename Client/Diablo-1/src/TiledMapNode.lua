-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local TiledMapNode = class("TiledMapNode",function()
    return {}
end)

function TiledMapNode.create(x, y, fDistance, collision)
    -- cclog("TiledMapNode Create")
    local node = TiledMapNode.new()
    
    node.x = x
    node.y = y
    node.isCollision = collision
    
    node.isInOpen = false
    node.isInClose = false
    node.parentNode = nil    
    
    node.fDistance = fDistance
    node.hDistance = fDistance
    node.gDistance = fDistance
        
    node.pre = nil
    node.next = nil
    
    return node
end

function TiledMapNode:reset()
    self.isInOpen = false
    self.isInClose = false
    self.parentNode = nil    

    self.fDistance = 100000
    self.hDistance = 100000
    self.gDistance = 100000

    self.pre = nil
    self.next = nil    
end

function TiledMapNode:ctor()    
    return
end

return TiledMapNode
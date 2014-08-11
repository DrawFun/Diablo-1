require "Util"

local LinkedListNode = class("LinkedListNode",function()
    return {}
end)

function LinkedListNode.create(data)
    cclog("LinedListNode Create")
    local node = LinkedListNode.new()
    if nil == data then
        node.data = object or {}
    else
        node.data = data
    end
    node.pre = nil
    node.next = nil
    return node
end

function LinkedListNode:ctor()
    cclog("LinkedListNode Ctor")
    return
end

return LinkedListNode
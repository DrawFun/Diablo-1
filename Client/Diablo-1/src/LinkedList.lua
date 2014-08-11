require "Util"

local LinkedList = class("LinkedList",function()
    return {}
end)

function LinkedList.create()
    -- cclog("LinedList Create")
    local linkedList = LinkedList.new()
    local linkedListNode = require("LinkedListNode")
    linkedList.size = 0
    linkedList.dummyHead = linkedListNode.new()        
    return linkedList
end

function LinkedList:ctor()
    return
end

function LinkedList:insert(node)
    if nil ~= node then
        self.size = self.size + 1
        local preNode = self.dummyHead
        while nil ~= preNode.next and self:compare(node, preNode.next) do
            preNode = preNode.next
        end
        node.pre = preNode
        node.next = preNode.next
        node.pre.next = node
        if nil ~= node.next then
            node.next.pre = node                
        end  
    end
end

function LinkedList:compare(node1, node2)
    return node1.fDistance > node2.fDistance
end

function LinkedList:remove(node)
    if nil ~= node then
        if node.next ~= nil then   
            node.next.pre = node.pre
        end
        node.pre.next = node.next
        self.size = self.size - 1
    end
end

function LinkedList:print()
    local node = self.dummyHead
    print("List Size: ", self.size)
    while node.next do
        node = node.next
        print(node.x, ",", node.y, ",", node.fDistance)
    end
    print("\n")
end

function LinkedList:clear()
    local node = self.dummyHead.next
        
--    local nextNode = object or {}
--    while nil ~= node do
--        print(node.x, ",", node.y, ",", node.fDistance) 
--        nextNode = node.next
--        node:reset()
--        node = nextNode               
--    end
--    
    self.dummyHead.pre = nil
    self.dummyHead.next = nil      
    self.size = 0
end

function LinkedList:head()
    return self.dummyHead.next
end

return LinkedList
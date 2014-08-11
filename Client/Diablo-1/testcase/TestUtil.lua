--[[
实用工具类的相关测试用例
包括String相关操作、二叉堆等数据结构
]]

function testHeapUtil()
    require("Util")
    cclog("HEAP UTIL TEST START ^-^")    
    
    local function testGMakeHeap()
        local array = {}
        for i = 1, 10 do
            table.insert(array, math.random(1, 100))             
        end
        
        cclog("Before Sorted")
        for i, v in ipairs(array) do
            cclog(v)
        end
        
        cclog("Make Heap")
        gBuildHeap(array, function(_x, _y) return _x < _y end) 
                 
        for i, v in ipairs(array) do
            cclog(v)
        end                       
        
        cclog("Insert New Node")
        gHeapInsertNode(array, function(_x, _y) return _x < _y end, 0)
        gHeapInsertNode(array, function(_x, _y) return _x < _y end, 50)
        gHeapInsertNode(array, function(_x, _y) return _x < _y end, 100)
        
        cclog("Sorted")
        for i = 1, #array do 
            cclog("%d", gDeleteRoot(array, function(_x, _y) return _x < _y end))
        end  
                
        
    end
    testGMakeHeap()
    cclog("HEAP UTIL TEST DONE! CHECK IT ^-^")
end


function testStringUtil()
    require("Util")
      
    local function testGStrCount()
        local strCase1 = "%127%0%0%h%a%ha%%%%%"
        assert(gStrCount(strCase1, 'h') == 2, "Error: "..gStrCount(strCase1, 'h'))
        assert(gStrCount(strCase1, '1') == 1, "Error: "..gStrCount(strCase1, '1'))
        assert(gStrCount(strCase1, 'b') == 0, "Error: "..gStrCount(strCase1, 'b'))
        assert(gStrCount(strCase1, '%') == 11, "Error: "..gStrCount(strCase1, '%'))    
        
        local strCase2 = ""
        assert(gStrCount(strCase2, 'h') == 0, "Error: "..gStrCount(strCase2, 'h'))
        assert(gStrCount(strCase2, '1') == 0, "Error: "..gStrCount(strCase2, '1'))
        assert(gStrCount(strCase2, 'b') == 0, "Error: "..gStrCount(strCase2, 'b'))
        assert(gStrCount(strCase2, '%') == 0, "Error: "..gStrCount(strCase2, '%'))    
                            
    end
    
    local function testGStrIndex()
        local strCase1 = "%127%0%0%h%a%ha%%%%%"
        assert(gStrIndex(strCase1, 'h', 0) == 10, "Error: "..gStrIndex(strCase1, 'h', 0))
        assert(gStrIndex(strCase1, '1', 0) == 2, "Error: "..gStrIndex(strCase1, '1', 0))
        assert(gStrIndex(strCase1, 'b', 0) == -1, "Error: "..gStrIndex(strCase1, 'b', 0))
        assert(gStrIndex(strCase1, '%', 0) == 1, "Error: "..gStrIndex(strCase1, '%', 0))       
        
        local strCase2 = "%%%456789%"
        assert(gStrIndex(strCase2, '4', 1) == 4, "Error: "..gStrIndex(strCase2, '4', 1))
        assert(gStrIndex(strCase2, '%', 6) == 10, "Error: "..gStrIndex(strCase2, '%', 6))
        assert(gStrIndex(strCase2, '4', 5) == -1, "Error: "..gStrIndex(strCase2, '4', 5))
        assert(gStrIndex(strCase2, '%', 3) == 3, "Error: "..gStrIndex(strCase2, '%', 3))    
        assert(gStrIndex(strCase2, '%', 1111) == -1, "Error: "..gStrIndex(strCase2, '%', 1111))     
        
        local strCase3 = ""
        assert(gStrIndex(strCase3, '4', 1) == -1, "Error: "..gStrIndex(strCase2, '4', 1))
        assert(gStrIndex(strCase3, '%', 0) == -1, "Error: "..gStrIndex(strCase2, '%', 0))
    end    
    
    local function testGStrTrim()
        local strCase1 = "   s   "
        local strCase2 = " s s "
        local strCase3 = "\t \nuuu\t\n"
        assert(gStrTrim(strCase1) == "s", "Error: "..gStrTrim(strCase1))
        assert(gStrTrim(strCase2) == "s s", "Error: "..gStrTrim(strCase2))
        assert(gStrTrim(strCase3) == "uuu", "Error: "..gStrTrim(strCase3))
    end
    
    cclog("STRING UTIL TEST START ^-^")    
    testGStrCount()
    testGStrIndex()
    testGStrTrim()
    cclog("STRING UTIL TEST PASS ^-^")
end



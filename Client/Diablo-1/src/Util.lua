--[[
实用工具类，包括Log函数、String相关操作、Math函数、二叉堆等数据结构
本类中函数的相关测试用例位于testcase/TestUtil.lua
]]

-- Log函数
cclog = function(...)
    print(string.format(...))
end

--
-- String相关操作
--

-- 字符串中字符统计
-- _s为字符串，_c为计数字符，返回该字符串中字符出现个数
function gStrCount(_s, _c)
    assert(_s and _c)
    
    local count = 0
    for i = 1, string.len(_s) do
        if string.sub(_s, i, i) == _c then
            count = count + 1
        end
    end
    
    return count 
end


-- 字符串中字符位置查询
-- _s为字符串，_c为所查询字符，_begin为查询起始位置，
-- 返回该字符自查询位置起第一次出现的索引，找不到则返回-1
function gStrIndex(_s, _c, _begin)
    assert(_s and _c and _begin) 
    
    for i = _begin, string.len(_s) do
        if string.sub(_s, i, i) == _c then
            return i
        end
    end
    
    return -1 
end


-- 字符串去首尾空格
-- _s为字符串，返回去掉首尾空格的新字符串
function gStrTrim(_s)
    return _s:gsub("^%s*(.-)%s*$", "%1")
end


--
-- 二叉堆类，用于A*寻路算法OpenList的维护
--

function gHeapInsertNode(_array, _comp, _node)
    table.insert(_array, _node)    
    local i = #_array
    while i > 1 do
        if not _comp(_array[math.floor(i / 2)], _array[i]) then                    
            local tmp = _array[math.floor(i / 2)]
            _array[math.floor(i / 2)] = _array[i]
            _array[i] = tmp
        else
            break 
        end
        i = math.floor(i / 2)
    end
end

function makeHeap(_array, _begin, _comp)
    local i = _begin
    local left = i * 2
    local right = i * 2 + 1
    local current = i
    
    if left <= #_array and _comp(_array[left], _array[current]) then
        current = left
    end
    
    if right <= #_array and _comp(_array[right], _array[current]) then
        current = right
    end
    
    if current ~= i then        
        local tmp = _array[current]
        _array[current] = _array[i]
        _array[i] = tmp
        return makeHeap(_array, current, _comp)
    end
end

function gDeleteRoot(_array, _comp)
    local ret = _array[1]
    _array[1] = _array[#_array]
    table.remove(_array)
    makeHeap(_array, 1, _comp)
    return ret
end

function gBuildHeap(_array, _comp)
    local i = math.floor(#_array / 2)
    while i >= 1 do
        makeHeap(_array, i, _comp)
        i = i - 1
    end        
end
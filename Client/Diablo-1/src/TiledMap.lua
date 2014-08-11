require "Cocos2d"
require "Cocos2dConstants"
require "Util"

local TiledMap = class("TiledMap",function()
    return {}
end)

local MAX_DISTANCE = 20480 -- 寻路算法重初始化采用的初始目标距离
local DISGONAL_DELTA = 14
local NEIGHBOR_DELTA = 10

function TiledMap.create()
    cclog("TiledMap Create")
    local tiledMap = TiledMap.new()
    local LinkedListCreator = require("LinkedList")
    local TiledMapNodeCreator = require("TiledMapNode")

    tiledMap.collisionLayerSize = object    
    tiledMap.collision2DArray = {}      
    tiledMap.map = nil
    
    tiledMap.map = cc.TMXTiledMap:create("TestAStar.tmx")    
    local collisionLayer = tiledMap.map:getLayer("Wall")
    tiledMap.collisionLayerSize = collisionLayer:getLayerSize()
    for i = 1, tiledMap.collisionLayerSize.width do        
        table.insert(tiledMap.collision2DArray, {}) 
        for j = 1, tiledMap.collisionLayerSize.height do     
            local collision = (collisionLayer:getTileGIDAt(cc.vertex2F(i - 1, tiledMap.collisionLayerSize.height - j)) ~= 0)                 
            table.insert(tiledMap.collision2DArray[i], TiledMapNodeCreator.create(i, j, 1000, collision))     
        end
    end 
    
    return tiledMap
end

function TiledMap:ctor()
    return
end

function TiledMap:getLogicalPos(phyPosX, phyPosY)
    return math.floor(phyPosX / 32) + 1, math.floor(phyPosY / 32) + 1
end

function TiledMap:getPhysicalPos(logicalPosX, logicalPosY)
    return (logicalPosX - 1) * 32, (logicalPosY - 1) * 32
end

function TiledMap:alignPos(positionX, positionY)
    return TiledMap:getPhysicalPos(TiledMap:getLogicalPos(positionX, positionY))
end

--
-- A*寻路算法，使用二叉堆优化
--
function TiledMap:findPath(_posX, _posY, _tPosX, _tPosY)

    
    -- 起点与当前点的估值函数，计算曼哈顿距离
    local function calculateHDis(_x, _y)
        return math.abs(_x - _tPosX) + math.abs(_y - _tPosY)
    end    
    
    
    -- 二叉堆排序所需的比较算法
    local function compareDistance(_x, _y)
        return _x.fDistance < _y.fDistance
    end        

    
    -- 初始化（或者重新初始化寻路相关二维数组）
    -- 还原初始距离、清空Open、Close链表标记、清空父节点标记
    for i = 1, self.collisionLayerSize.width do        
        for j = 1, self.collisionLayerSize.height do                 
            self.collision2DArray[i][j].fDistance = MAX_DISTANCE 
            self.collision2DArray[i][j].gDistance = MAX_DISTANCE      
            self.collision2DArray[i][j].isInOpen = false
            self.collision2DArray[i][j].isInClose = false
            self.collision2DArray[i][j].parentNode = nil   
            self.collision2DArray[i][j].pre = nil
            self.collision2DArray[i][j].next = nil                
        end
    end        
    
    -- 初始化Openlist，加入起始点
    local openList = {}      
    self.collision2DArray[_posX][_posY].hDistance = calculateHDis(_posX, _posY)
    self.collision2DArray[_posX][_posY].fDistance = self.collision2DArray[_posX][_posY].hDistance
    self.collision2DArray[_posX][_posY].gDistance = 0          
    self.collision2DArray[_posX][_posY].isInClose = false
    self.collision2DArray[_posX][_posY].isInOpen = true 
    self.collision2DArray[_posX][_posY].parentNode = nil       
    gHeapInsertNode(openList, compareDistance, self.collision2DArray[_posX][_posY])
    

    while #openList > 0 do             
                           
        -- 拿出目前距离最近的节点（堆顶）进行计算（log(n))
        local current = gDeleteRoot(openList, compareDistance)           
        self.collision2DArray[current.x][current.y].isInOpen = false
        self.collision2DArray[current.x][current.y].isInClose = true   

        -- 如果是目标节点，则已经找到路径，跳出循环
        if current.x == _tPosX and current.y == _tPosY then            
            break
        end
   
        -- 检测当前待检测节点是否处于路径上，更新节点信息
        -- 待检测节点坐标：(_x, _y)，发起检测节点与起始节点距离：_fDis，发起检测节点与当前节点距离：_gDisDelta
        local function checkNode(_x, _y, _fDis, _gDisDelta)
        
            -- 如果节点不可达或者已经检测过，则返回
            if self.collision2DArray[_x][_y].isCollision or self.collision2DArray[_x][_y].isInClose then
                return
            end
            
            -- 计算节点估值距离
            local hDis = calculateHDis(_x, _y)
            
            -- 寻路算法中经典松弛操作（relax），当前距离小于过往距离则更新并加入重检测序列
            -- 这里同样为检测当前距离与过往距离，判断是否更新并加入Openlist待后续检测            
            if self.collision2DArray[_x][_y].gDistance + hDis > _fDis + _gDisDelta then
                
                -- 更新当前节点信息（松弛）            
                self.collision2DArray[_x][_y].gDistance = current.gDistance + _gDisDelta
                self.collision2DArray[_x][_y].hDistance = hDis
                self.collision2DArray[_x][_y].fDistance = self.collision2DArray[_x][_y].gDistance + hDis
                self.collision2DArray[_x][_y].parentNode = self.collision2DArray[current.x][current.y]
            
                -- 如果当前节点不处于Openlist中，则加入
                if not self.collision2DArray[_x][_y].isInOpen then
                    -- 插入二叉堆（log(n))
                    gHeapInsertNode(openList, compareDistance, self.collision2DArray[_x][_y])   
                    -- 置位于Openlist的标记                                    
                    self.collision2DArray[_x][_y].isInOpen = true
                end
                
            end
        end 
        
        -- 当前节点与目标节点的距离        
        local curFDis = current.fDistance
        
        -- 检测上下左右
        checkNode(current.x, current.y + 1, curFDis, NEIGHBOR_DELTA)
        checkNode(current.x, current.y - 1, curFDis, NEIGHBOR_DELTA)
        checkNode(current.x - 1, current.y, curFDis, NEIGHBOR_DELTA)
        checkNode(current.x + 1, current.y, curFDis, NEIGHBOR_DELTA)
        
        -- 检测斜向的四个位置
        
        -- 检测右方格子是否可通行，若可以，再检测右上和右下，以此减少判断次数
        if not self.collision2DArray[current.x + 1][current.y].isCollision then
        
            -- 右上
            if not self.collision2DArray[current.x][current.y + 1].isCollision then
                checkNode(current.x + 1, current.y + 1, curFDis, DISGONAL_DELTA)
            end
            
            -- 右下
            if not self.collision2DArray[current.x][current.y - 1].isCollision then
                checkNode(current.x + 1, current.y - 1, curFDis, DISGONAL_DELTA)
            end
            
        end
        
        -- 同理先检测左方格子是否可通行，若可以，再检测左上和左下，减少判断次数
        if not self.collision2DArray[current.x - 1][current.y].isCollision then
        
            -- 左上
            if not self.collision2DArray[current.x][current.y + 1].isCollision then
                checkNode(current.x - 1, current.y + 1, curFDis, DISGONAL_DELTA)
            end
            
            -- 左下
            if not self.collision2DArray[current.x][current.y - 1].isCollision then
                checkNode(current.x - 1, current.y - 1, curFDis, DISGONAL_DELTA)
            end
            
        end


    end
    
    -- 回溯寻找父节点并返回路径序列
    local ret = {}
    
    local curBacktrace = self.collision2DArray[_tPosX][_tPosY]    
    while curBacktrace ~= nil do
        table.insert(ret, cc.p(curBacktrace.x, curBacktrace.y))
        curBacktrace = curBacktrace.parentNode      
    end     
    
    return ret
end

return TiledMap

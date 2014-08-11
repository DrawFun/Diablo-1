#!/usr/bin/env python
# -*- coding: gbk -*-
'''
入口服务器
负责接收并维护客户端连接，接收和发送消息，调用分发器处理消息
游戏服务器主循环所在
拆分并替代提供代码包中的ServerStruct.py文件
'''
import time
import sys
from Dispatcher import *
from Timer import *
from  netstream import *

#服务器发送包格式
HEAD_FORMAT = 8
#服务器监听端口
HOST_PORT = 2000


#----------------------------------------------------------------------
# 抽象的IO服务器类
# 主循环包含了time schedule
#----------------------------------------------------------------------
class IoService(object):

    #主循环中的轮询函数，用于轮询网络信息
    def process(self, timeout):
        # process network
        raise NotImplementedError 
        
    def run(self, timeout = 0.5):
        while 1:

            self.process(timeout)
            
            TimerManager.scheduler()
            
        return


#----------------------------------------------------------------------
# 抽象的游戏服务器， 继承了IOServer
# 将IO服务器主循环的scheduler细化成重复的Tick
#----------------------------------------------------------------------
class GameServer(IoService):
    def __init__(self, ticktime = 0.1):
        super(GameServer, self).__init__()
        
        #每隔一定时长调用Tick
        self.ticktimer = TimerManager.addRepeatTimer(ticktime, self.tick)
        
        return
    
    def tick(self):
        # tick entities
        raise NotImplementedError 
        
    def run(self, timeout = 0.5):
        super(GameServer, self).run(timeout)
        

#----------------------------------------------------------------------
# 实际使用的服务器类，继承GameServer
# 细化了主循环中Tick
#----------------------------------------------------------------------
class MainServer(GameServer):
    
    #MainServer构造函数
    def __init__(self):
        super(MainServer, self).__init__(2)
        
        #创建分发器
        self.dispatcher = Dispatcher.GetInstance()
        
        #创建nethost供客户端进行连接
        self.host = nethost(HEAD_FORMAT)
        self.host.startup(HOST_PORT)
    
        print "Server Start at Port: ", HOST_PORT
                
        #添加定时回调
        self.tickStartTime = time.time()        
        TimerManager.addTimer(2, self.tickOnce)
          
        return
    
    
    #主循环中的轮询函数，调用网络接口
    def process(self, timeout):        
        self.host.process()   
        event, wparam, lparam, data = self.host.read()     
        self.dispatcher.DispatchEvent(event, wparam, lparam, data)
        return
                
                
    def tick(self):
        print 'I am called every some seconds'
        
        
    def tickOnce(self):
        print 'I am called after some time'


#----------------------------------------------------------------------
#main函数，服务器代码入口
#----------------------------------------------------------------------
if __name__ == '__main__':
    #创建MainServer
    mainServer = MainServer()
    #设置超时时长
    mainServer.run(0.1)

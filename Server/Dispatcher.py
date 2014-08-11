#!/usr/bin/env python
# -*- coding: gbk -*-

'''
分发器
负责解析接收消息并分发消息给子服务器进行处理
参考代码包中的netstream.py的测试用例进行设计，使用Map优化程序结构
'''
import threading
from events import * 

#----------------------------------------------------------------------
# 分发器类，单例类
#解析网络消息并分发给相应的功能服务器进行处理
#----------------------------------------------------------------------
class Dispatcher(object):
    
    instance = None
    mutex = threading.Lock()
    
    def __init__(self):
            pass


    #获取单例    
    @staticmethod
    def GetInstance():
        if None == Dispatcher.instance:
            Dispatcher.mutex.acquire()
            
            if None == Dispatcher.instance:
                Dispatcher.instance = Dispatcher()
            Dispatcher.mutex.release()
             
        return Dispatcher.instance
        
    
    def DispatchEvent(self, event, wparam, lparam, data):
        
        return
    
    
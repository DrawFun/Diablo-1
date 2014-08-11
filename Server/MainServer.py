#!/usr/bin/env python
# -*- coding: gbk -*-
'''
��ڷ�����
������ղ�ά���ͻ������ӣ����պͷ�����Ϣ�����÷ַ���������Ϣ
��Ϸ��������ѭ������
��ֲ�����ṩ������е�ServerStruct.py�ļ�
'''
import time
import sys
from Dispatcher import *
from Timer import *
from  netstream import *

#���������Ͱ���ʽ
HEAD_FORMAT = 8
#�����������˿�
HOST_PORT = 2000


#----------------------------------------------------------------------
# �����IO��������
# ��ѭ��������time schedule
#----------------------------------------------------------------------
class IoService(object):

    #��ѭ���е���ѯ������������ѯ������Ϣ
    def process(self, timeout):
        # process network
        raise NotImplementedError 
        
    def run(self, timeout = 0.5):
        while 1:

            self.process(timeout)
            
            TimerManager.scheduler()
            
        return


#----------------------------------------------------------------------
# �������Ϸ�������� �̳���IOServer
# ��IO��������ѭ����schedulerϸ�����ظ���Tick
#----------------------------------------------------------------------
class GameServer(IoService):
    def __init__(self, ticktime = 0.1):
        super(GameServer, self).__init__()
        
        #ÿ��һ��ʱ������Tick
        self.ticktimer = TimerManager.addRepeatTimer(ticktime, self.tick)
        
        return
    
    def tick(self):
        # tick entities
        raise NotImplementedError 
        
    def run(self, timeout = 0.5):
        super(GameServer, self).run(timeout)
        

#----------------------------------------------------------------------
# ʵ��ʹ�õķ������࣬�̳�GameServer
# ϸ������ѭ����Tick
#----------------------------------------------------------------------
class MainServer(GameServer):
    
    #MainServer���캯��
    def __init__(self):
        super(MainServer, self).__init__(2)
        
        #�����ַ���
        self.dispatcher = Dispatcher.GetInstance()
        
        #����nethost���ͻ��˽�������
        self.host = nethost(HEAD_FORMAT)
        self.host.startup(HOST_PORT)
    
        print "Server Start at Port: ", HOST_PORT
                
        #��Ӷ�ʱ�ص�
        self.tickStartTime = time.time()        
        TimerManager.addTimer(2, self.tickOnce)
          
        return
    
    
    #��ѭ���е���ѯ��������������ӿ�
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
#main�������������������
#----------------------------------------------------------------------
if __name__ == '__main__':
    #����MainServer
    mainServer = MainServer()
    #���ó�ʱʱ��
    mainServer.run(0.1)

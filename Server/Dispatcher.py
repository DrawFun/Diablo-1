#!/usr/bin/env python
# -*- coding: gbk -*-

'''
�ַ���
�������������Ϣ���ַ���Ϣ���ӷ��������д���
�ο�������е�netstream.py�Ĳ�������������ƣ�ʹ��Map�Ż�����ṹ
'''
import threading
from events import * 

#----------------------------------------------------------------------
# �ַ����࣬������
#����������Ϣ���ַ�����Ӧ�Ĺ��ܷ��������д���
#----------------------------------------------------------------------
class Dispatcher(object):
    
    instance = None
    mutex = threading.Lock()
    
    def __init__(self):
            pass


    #��ȡ����    
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
    
    
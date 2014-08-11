#!/usr/bin/env python
# -*- coding: gbk -*-

'''
定时器相关类型
负责服务器定时回调机制的实现
拆分自提供代码包中的ServerStruct.py文件
'''
import time
import heapq

#----------------------------------------------------------------------
#一定时间后回调某个函数，封装在TimerManager中使用
#----------------------------------------------------------------------
class CallLater(object):
    
    def __init__(self, seconds, target, *args, **kwargs):
        super(CallLater, self).__init__()
        self._delay = seconds
        self._target = target
        self._args = args
        self._kwargs = kwargs
        
        self.cancelled = False
        self.timeout = time.time() + self._delay

    
    def __le__(self, other):
        return self.timeout <= other.timeout

   
    def call(self):
            try:
                self._target(*self._args, **self._kwargs)
            except (KeyboardInterrupt, SystemExit):
                raise
                    
            return False
                    
    
    def cancel(self):
        self.cancelled = True


#----------------------------------------------------------------------
#每隔一定时间回调某个函数，封装于TimerManager中使用
#----------------------------------------------------------------------
class CallEvery(CallLater):
    def call(self):
        try:
            self._target(*self._args, **self._kwargs)
        except (KeyboardInterrupt, SystemExit):
            raise
            
        self.timeout = time.time() + self._delay
        
        return True
   

#----------------------------------------------------------------------
#回调类，封装以上两个回调机制，提供静态方法
#使用优先队列对所有回调函数进行管理
#----------------------------------------------------------------------
class TimerManager(object):
    #任务队列
    tasks = []
    #当前已经取消的任务数目，用于自动清理任务队列
    cancelled_num = 0
    
    
    #为某个函数增加一个定时器
    @staticmethod
    def addTimer(delay, func, *args, **kwargs):
        timer = CallLater(delay, func, *args, **kwargs)
        
        heapq.heappush(TimerManager.tasks, timer)
        
        return timer
    
    
    #为某个函数增加一个重复定时器
    @staticmethod    
    def addRepeatTimer(delay, func, *args, **kwargs):
        timer = CallEvery(delay, func, *args, **kwargs)
        
        heapq.heappush(TimerManager.tasks, timer)
        
        return timer
    
    
     #取消某个定时器     
    @staticmethod
    def scheduler():
        now = time.time()
        
        while TimerManager.tasks and now >= TimerManager.tasks[0].timeout:
            call = heapq.heappop(TimerManager.tasks)
            if call.cancelled:
                TimerManager.cancelled_num -= 1
                continue
            
            try:
                repeated = call.call()
            except (KeyboardInterrupt, SystemExit):
                raise
                
            if repeated:
                heapq.heappush(TimerManager.tasks, call)
     
     
     #取消某个定时器           
    @staticmethod
    def cancel(timer):
        if not timer in TimerManager.tasks:
            return
        
        timer.cancel()
        TimerManager.cancelled_num += 1
        
       #如果任务队列取消任务多于总量25%则进行清理
        if float(TimerManager.cancelled_num)/len(TimerManager.tasks) > 0.25:
            TimerManager.remove_cancelled_tasks()
        
        return
    
    
    #清理任务队列
    @staticmethod
    def remove_cancelled_tasks():
        print 'remove cancelled tasks'
        tmp_tasks = []
        for t in TimerManager.tasks:
            if not t.cancelled:
                tmp_tasks.append(t)
        
        TimerManager.tasks = tmp_tasks
        heapq.heapify(TimerManager.tasks)
        
        TimerManager.cancelled_num = 0
        
        return
# -*- coding: gbk -*-

import heapq
import time
import select
import sys

class CallLater(object):
	"""Calls a function at a later time.
	"""
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

class CallEvery(CallLater):
	"""Calls a function every x seconds.
        """
        
        def call(self):
		try:
			self._target(*self._args, **self._kwargs)
		except (KeyboardInterrupt, SystemExit):
			raise
			
		self.timeout = time.time() + self._delay
		
		return True
		
class TimerManager(object):
	tasks = []
	cancelled_num = 0
	
	@staticmethod
	def addTimer(delay, func, *args, **kwargs):
		timer = CallLater(delay, func, *args, **kwargs)
		
		heapq.heappush(TimerManager.tasks, timer)
		
		return timer
	
	@staticmethod	
	def addRepeatTimer(delay, func, *args, **kwargs):
		timer = CallEvery(delay, func, *args, **kwargs)
		
		heapq.heappush(TimerManager.tasks, timer)
		
		return timer
	
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
				
	@staticmethod
	def cancel(timer):
		if not timer in TimerManager.tasks:
			return
		
		timer.cancel()
		TimerManager.cancelled_num += 1
		
		print 'ok, cancel task'	
		if float(TimerManager.cancelled_num)/len(TimerManager.tasks) > 0.25:
			TimerManager.remove_cancelled_tasks()
		
		return
	
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

class IoService(object):

	def process(self, timeout):
		# process network
		raise NotImplementedError 
		
	def run(self, timeout = 0.5):
		while 1:
			self.process(timeout)
			
			TimerManager.scheduler()
			
		return

class GameServer(IoService):
	def __init__(self, ticktime = 0.1):
		super(GameServer, self).__init__()
		
		self.ticktimer = TimerManager.addRepeatTimer(ticktime, self.tick)
		
		return
	
	def tick(self):
		# tick entities
		raise NotImplementedError 
		
	def run(self, timeout = 0.5):
		super(GameServer, self).run(timeout)
		
class TestGameServer(GameServer):
	def __init__(self):
		super(TestGameServer, self).__init__(2)
		
		self.tickStartTime = time.time()
		TimerManager.addTimer(2.5, self.tickOnce)
		
		return
	
	def process(self, timeout):
		select.select([], [], [], timeout)
		
		if time.time() - self.tickStartTime > 10.0:
			TimerManager.cancel(self.ticktimer)

			print 'stop test now'
			sys.exit(1)
		
		return
		
	def tick(self):
		print 'I am called every some seconds'
		
	def tickOnce(self):
		print 'I am called after some time'
	
if __name__ == '__main__':
	gs = TestGameServer()
	gs.run(0.1)
	

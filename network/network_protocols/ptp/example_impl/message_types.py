
import time
import date

class sync:
    id = 0x0
    def __init__(self):
        pass

class follow_up:
    id = 0x08
    timestamp = 0
    def __init__(self, ts):
        timestamp = ts

class delay_req:
    id = 0x01

class delay_res:
    id = 0x09
    timestamp = 0
    def __init__(self, ts):
        timestamp = ts



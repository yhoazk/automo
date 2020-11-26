#!/usr/bin/env python3

import time
import zmq
import random
from message_types import *

context = zmq.Context()

print("Connecting to hello world server")
# socket = context.socket(zmq.REQ) half duplex
socket = context.socket(zmq.PAIR)
#socket.connect("tcp://192.168.0.129:5555")
socket.connect("tcp://localhost:5555")

master_offset = random.randint(45, 200)

for request in range(10):
    ts_sync = time.time() + master_offset
    print(f"Send Sync message at {ts_sync}")
    socket.send(b"Hello")

    message = socket.recv()
    print(f"Received {message}")





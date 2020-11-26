#!/usr/bin/env python3

import time
import zmq

from message_types import *

context = zmq.Context()
# socket  = context.socket(zmq.REP) half duplex
socket  = context.socket(zmq.PAIR)
socket.bind("tcp://*:5555")

slave_offset = random.randint(20, 67)
while True:
    message = socket.recv()
    t2_ts = time.time() + slave_offset
    print(f"Message received at: {t2_ts}")

    message = socket.recv()

    time.sleep(0.1)
    t3_ts = time.time()
    socket.send(b"world")
    message = socket.recv()


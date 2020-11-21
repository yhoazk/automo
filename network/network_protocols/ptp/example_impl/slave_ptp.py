#!/usr/bin/env python3

import time
import zmq

context = zmq.Context()

print("Connecting to hello world server")
socket = context.socket(zmq.REQ)
#socket.connect("tcp://192.168.0.129:5555")
socket.connect("tcp://localhost:5555")

for request in range(10):
    print(f"Send message request {request}")
    socket.send(b"Hello")

    message = socket.recv()
    print(f"Received {message}")

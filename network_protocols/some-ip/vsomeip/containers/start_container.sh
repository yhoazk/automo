#!/usr/bin/bash

docker build -t someip/clean .
# Add the vsomeip code to the created volume
docker run -it --rm -v "$PWD/../vsomeip-master":/vsomeip someip/clean bash

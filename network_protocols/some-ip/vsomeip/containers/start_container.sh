#!/usr/bin/bash

docker build -t someip/clean .
docker run -it --r rm someip/clean

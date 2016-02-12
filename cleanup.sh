#!/bin/bash

docker rm -f `docker ps -a | grep slurm | awk '{print $1}'`

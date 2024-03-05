#!/bin/zsh

# The nohup command is used to run the process in the background 
# and it will keep running even after you've logged out.
nohup julia --threads 2 src/Server.jl > ./output.log 2>&1 &

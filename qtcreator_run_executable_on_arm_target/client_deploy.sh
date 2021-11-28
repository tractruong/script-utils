#!/bin/bash
#$1 user@hostip - should be setup ssh without password
#$2 app_name
#$3 path_to_executable
#$4 path_to_executable_on_target 
ssh $1 'echo "@killall $2" > /tmp/mypipe'
scp $3 $1:$4
ssh $1 'echo "@./$2 &" > /tmp/mypipe'


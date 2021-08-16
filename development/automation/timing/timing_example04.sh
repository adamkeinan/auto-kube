#!/bin/bash
START1="$(date +%s)"
sleep 2
sleep 2
START2="$(date +%s)"
sleep 3
echo "The 1st part of the code took: $[ $(date +%s) - ${START1} ]"
echo "The 2nd part of the code took: $[ $(date +%s) - ${START2} ]"
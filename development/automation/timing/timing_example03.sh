#!/bin/bash
START1="$(date +%s)"
sleep 2 
END1="$(date +%s)"
sleep 2
START2="$(date +%s)"
sleep 3
END2="$(date +%s)"
echo "The 1st part of the code took: $[ ${END1} - ${START1} ]"
echo "The 2nd part of the code took: $[ ${END2} - ${START2} ]"
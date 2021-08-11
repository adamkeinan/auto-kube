#!/bin/bash
START="$(date +%s)"
sleep 1 
DURATION=$[ $(date +%s) - ${START} ]
echo ${DURATION}
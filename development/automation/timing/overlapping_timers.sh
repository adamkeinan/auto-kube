#!/bin/bash
my_sleep_function(){
  sleep 1
}
OVERALL_START="$(date +%s)"
FUNCTION_START="$(date +%s)"
my_sleep_function
FUNCTION_END="$(date +%s)"
sleep 2
OVERALL_END="$(date +%s)"
echo "The function part of the code took: $[ ${FUNCTION_END} - ${FUNCTION_START} ] seconds to run"
echo "The overall code took: $[ ${OVERALL_END} - ${OVERALL_START} ] seconds to run"
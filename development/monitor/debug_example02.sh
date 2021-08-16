#!/bin/bash
VAR1="Hello linuxconfig.org readers!"
VAR2="------------------------------"
echo ${VAR1}
echo ${VAR2}


# EXECUTION:
$ bash -x ./test.sh + VAR1='Hello linuxconfig.org readers!' + VAR2=------------------------------ + echo Hello linuxconfig.org 'readers!' Hello linuxconfig.org readers! + echo ------------------------------ ------------------------------
$ $ bash -x ./test.sh 2>&1 | tee my_output.log ... same output ... $ cat my_output.log + VAR1='Hello linuxconfig.org readers!' + VAR2=------------------------------ + echo Hello linuxconfig.org 'readers!' Hello linuxconfig.org readers! + echo ------------------------------ ------------------------------

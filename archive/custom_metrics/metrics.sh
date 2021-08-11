#!bin/sh
## CPU and Memory Usage
## To keep to the principle of using minimal bootstrapping, I opted to use the top tool to collect CPU and Memory usage.

$ cpu_mem_usage=$(top -b -n 1 | grep -w -E "^ *$pid" | awk '{print $9 "," $10}')
$ top -b -n 1 # top command run in the batch mode once
$ grep -w -E "^ *$pid" # look for the entry for the process ID we are looking for
$ awk '{print $9 "," $10}' # get the CPU and memory usage values

# Thread Count
$ tcount=$(ps -o nlwp h $pid | tr -d ' ')
$ ps -o nlwp h $pid # print the number of light weight processes (threads) for the particular process (without the header — h)
# TCP Connection Count
$ tcp_cons=$(lsof -i -a -p $pid -w | tail -n +2 | wc -l)
$ lsof -i -a -p $pid -w # print all the Internet (ipv4 and ipv6) connections for the process suppressing any errors
$ tail -n +2 # Remove the header line from selection
$ wc -l # Count the number of lines



#!/bin/bash
#Script for killing HADOOP jobs running more than a given time"
#Time should be specified in hours
#usage sh kill_jobs.sh <TIME_IN_HOURS>

LOG=/tmp/job_log
declare -a LIST_APP JOB_TIME

if [[ ${1:-0} -eq 0 ]];then
    echo -e "Usage: $0 <TIME_IN_HOURS> \nexample: "$0 24" - for kill the jobs running more than 24 hours" ; exit 1
fi

TR_TIME=$(($1*60))
CURRENT_TIME=$(date +%s)
LIST_APP=($(yarn application -list 2>/dev/null | grep '^application\||RUNNING' | awk '{print $1}'))

for JOB in ${LIST_APP[@]}
do

    JOB_TIME=($(yarn application -status $JOB 2>/dev/null | grep 'Start-Time\|Finish-Time'| awk -F: '{print $NF}' | tr '\n' ' '))

    if [[ ${JOB_TIME[1]} -eq 0 ]];then

        DIFF=$((( $CURRENT_TIME - (${JOB_TIME[0]}/1000))/60))

        if [[ $DIFF -gt $TR_TIME ]];then

			yarn application -kill $JOB 2>/dev/null && echo "$JOB is running $DIFF mins -> KILLED" | tee -a $LOG

        fi
     fi

done

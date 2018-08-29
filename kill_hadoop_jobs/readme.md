# Kill all Hadoop jobs running more than a specified time


### Installing

Download kill_jobs.sh

```
wget https://github.com/renjithrp/automation_scripts/raw/master/kill_hadoop_jobs/kill_jobs.sh
```

Modify LOG location if needed

```
LOG=/tmp/job_log
```

Below example is to kill all the jobs running more than 24 hours 

```
sh kill_jobs.sh 24
```


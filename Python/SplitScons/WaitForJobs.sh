#!/bin/bash
# Checks if each submitted job has finished...
while read p; do
  # Get currently running jobs with my name
  RunningJobs=`qstat | grep lewisli | awk '{print $1}'`
  while :
  do
	if [[ $RunningJobs == *$p* ]]
	then
		echo $p "is still running";
		sleep 5
	else
		echo $p "is finished" 
		break
	fi
  done
done < $1

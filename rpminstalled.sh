#!/bin/bash
# Author Josh Cagle
# Organization University of Oregon

# Queries the rpm database and asks if the zabbix-2.2.0-1.el6.x86_64 package 
# is installed on the machine. 

installed=$(echo | rpm -q zabbix-2.2.0-1.el6.x86_64 | awk '{print $4}')
	if [[ $installed == "not" ]]
	then
	# By returning a 1 or a 0 will keep communication slim. 
		echo 0
	else 
		echo 1

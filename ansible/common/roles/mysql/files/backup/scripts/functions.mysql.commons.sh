#!/bin/bash

#-----------
# Get host name from login-path
# @param $1 MySQL login path
# @return host name
#-----------
function getHostFromLoginPath() {
	# Initialize parameters
	MYSQL_LOGINPATH=$1

	# Get host name from login-path
	MYSQL_HOST=`mysql_config_editor print --login-path=${MYSQL_LOGINPATH} | grep host | awk '{ print $3 }'`

	# Return host name
	echo ${MYSQL_HOST}
}

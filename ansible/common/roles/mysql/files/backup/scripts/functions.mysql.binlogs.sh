#!/bin/sh

#-----------
# Get master binary log
# @param $1 MySQL login path
# @param $2 Error file
# @return master binary log
#-----------
function getMasterBinaryLog() {
	
	# Get parameters
	MYSQL_LOGINPATH=$1
	ERROR_FILE=$2

	# Get master binlog file
	MASTER_BINLOG=`mysql --login-path=${MYSQL_LOGINPATH} --raw --batch --silent --execute="show master status" 2>> ${ERROR_FILE} | awk '{ print $1 }'`

	# Check for error & return result
	if [ ${PIPESTATUS[0]} -gt 0 ] || [ -z "${MASTER_BINLOG}" ] 
	then
		echo ERROR
	else
		echo ${MASTER_BINLOG}
	fi
}


#-----------
# Get slave binary log
# @param $1 MySQL login path
# @param $2 Error file
# @return slave binary log
#-----------
function getSlaveBinaryLog() {

	# Get parameters
	MYSQL_LOGINPATH=$1
	ERROR_FILE=$2

	# Retrieving master binlog file
	SLAVE_BINLOG=`mysql --login-path=${MYSQL_LOGINPATH} --raw --batch --silent --execute="show slave status\G;" 2>> ${ERROR_FILE} | grep " Master_Log_File"| awk '{print $2}'` 


	# Check for error & return result
	if [ ${PIPESTATUS[0]} -gt 0 ] || [ -z "${SLAVE_BINLOG}" ]
	then
		echo ERROR
	else
		echo ${SLAVE_BINLOG}
	fi
}


#-----------
# Clean binary logs
# @param $1 MySQL login path
# @param $2 MySQL binlog to purge to
# @param $3 Error file
#-----------
function cleanBinaryLogs() {

	# Get parameters
	MYSQL_LOGINPATH=$1
	MYSQL_BINLOG=$2
	ERROR_FILE=$3

	# Purge bin logs
	mysql --login-path=${MYSQL_LOGINPATH} --execute="PURGE BINARY LOGS TO '$MYSQL_BINLOG';" 2>> ${ERROR_FILE}

	# Exit if error
	if [ $? -gt 0 ]
	then
		echo ERROR
	else
		echo OK
	fi
}


#-----------
# Flush binary logs without writing the query to bin logs
# @param $1 MySQL login path
# @param $2 MySQL binlog to purge to
# @param $3 Error file
#-----------
function flushBinaryLogs() {

	# Get parameters
        MYSQL_LOGINPATH=$1
        ERROR_FILE=$2

	# Flush binary logs
	mysql --login-path=${MYSQL_LOGINPATH} --execute="FLUSH NO_WRITE_TO_BINLOG BINARY LOGS;" 2>> ${ERROR_FILE}

	# Exit if error
        if [ $? -gt 0 ]
        then
                echo ERROR
        else
                echo OK
        fi
}

#!/bin/sh

#-----------
# Get the list of databases on a server
# @param $1 MySQL login path
# @param $2 Database list export path
# @param $3 Error file path
# @param $4 Path to the file containing databases exclusion list
# @return path of databases list
#-----------
function exportDatabasesList() {

        # Initialize parameters
        MYSQL_LOGINPATH=$1
	EXPORT_PATH=$2
	ERROR_FILE=$3

	# Export databases list
	mysql --login-path=${MYSQL_LOGINPATH} --raw --batch --skip-column-names --execute='SHOW DATABASES WHERE `Database` NOT LIKE "%schema" AND `Database` NOT LIKE "tmp_%"' 2>> ${ERROR_FILE} > ${EXPORT_PATH}/databaseList_${MYSQL_LOGINPATH}.lst

	# Exit if error
	if [ $? -gt 0 ]
	then
		echo ERROR

	else
		# Remove excluded databases
		if [ -z "$4" ]
		then
			echo "No databases excluded" > /dev/null
		else
			# Load exclusion list
			EXCLUDE_LIST=$4
	
			# Suppress exluded databases
			comm -23 --nocheck-order ${EXPORT_PATH}/databaseList_${MYSQL_LOGINPATH}.lst ${EXCLUDE_LIST} > ${EXPORT_PATH}/databaseList_${MYSQL_LOGINPATH}.tmp
		
			# Write final file
			rm -f ${EXPORT_PATH}/databaseList_${MYSQL_LOGINPATH}.lst
			mv ${EXPORT_PATH}/databaseList_${MYSQL_LOGINPATH}.tmp ${EXPORT_PATH}/databaseList_${MYSQL_LOGINPATH}.lst
		fi

		# Return export file
		local EXPORT_FILE=${EXPORT_PATH}/databaseList_${MYSQL_LOGINPATH}.lst
		echo ${EXPORT_FILE}
	fi
}


#-----------
# Backup a database on a server
# @param $1 MySQL login path
# @param $2 MySQL database to dump
# @param $3 Export path
# @param $4 Error file
# @return OK or ERROR
#-----------
function dumpDatabase() {

	# Initialize parameters
	MYSQL_LOGINPATH=$1
	MYSQL_DATABASE=$2
	EXPORT_PATH=$3
	ERROR_FILE=$4

	# Dump the database
	mysqldump --login-path=${MYSQL_LOGINPATH} --routines --triggers --skip-lock-tables --single-transaction --disable-keys --no-autocommit --quick --extended-insert --flush-logs --master-data=2 --log-error=${ERROR_FILE} ${MYSQL_DATABASE} | pigz > ${EXPORT_PATH}/dump_${MYSQL_DATABASE}.sql.gz

	# Check for error & return result
	if [ ${PIPESTATUS[0]} -gt 0 ]
	then
		echo ERROR
	else
		echo OK
	fi
}


#-----------
# Get binary log info (file & position) from a dump
# @param $1 The dump
# @return The infos
#-----------
function getDumpMasterBinlogInfos() {
	
	# Get parameters
	DUMP_FILE=$1

	echo `head ${DUMP_FILE} -n80 | grep "MASTER_LOG_POS"`
}


#-----------
# Get master binlog file at dump time
# @param $1 The dump
# @return The file 
#-----------
function getDumpMasterBinlogFile() {

	# Get parameters
	DUMP_FILE=$1

	# Get binlog file
	BINLOG_FILE=`head ${DUMP_FILE} -n80 | grep "MASTER_LOG_POS" | awk '{print $5}'`

	# Clean
	echo ${BINLOG_FILE%?}
}


#-----------
# Get master binlog pos at dump time
# @param $1 The dump
# @return The file 
#-----------
function getDumpMasterBinlogPosition() {

	# Get parameters
	DUMP_FILE=$1

	# Get binlog file
	BINLOG_POS=`head ${DUMP_FILE} -n80 | grep "MASTER_LOG_POS" | awk '{print $6}'`

	# Clean
	echo ${BINLOG_POS%?}
}



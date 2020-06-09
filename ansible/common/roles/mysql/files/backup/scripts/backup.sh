#!/bin/bash

#########
### DS MySQL BACKUP SCRIPT
### - Perform backup of MySQL databases
### - You can define databases to exclude in /backup/conf/exclude.lst:
###     - One database name per line
###     - /!\ databases must be in alphabetical order
### - Clean binary logs if asked
### Call: ./backup.sh [CLEAN_BINLOGS (optional)]
#########

# Load configuration
. /backup/conf/backup.conf

# Include backup utilities
. /backup/scripts/functions.filesystem.sh
. /backup/scripts/functions.mysql.commons.sh
. /backup/scripts/functions.mysql.dumps.sh
. /backup/scripts/functions.mysql.binlogs.sh

# Lock file
LOCK_FILE=/var/lock/subsys/backup

# Temporary log file
LOG_FILE_TMP=${BACKUP_PATH}/log/backup_${REPLICA_NAME}.log

# Create log file
touch ${LOG_FILE_TMP}

# Check if lock file exists
if [ -f ${LOCK_FILE} ]
then
	echo "Program is already running" >> ${LOG_FILE_TMP}
	exit 1
else
	# Create lock file
	touch ${LOCK_FILE}
fi

# Log - Backup start
echo "`date +%Y-%m-%d\ %H:%M:%S` - ---------------------------------------------" | tee -a ${LOG_FILE_TMP}
echo "`date +%Y-%m-%d\ %H:%M:%S` - Start backup of replica ${REPLICA_NAME}" | tee -a ${LOG_FILE_TMP}
echo "`date +%Y-%m-%d\ %H:%M:%S` - ---------------------------------------------" | tee -a ${LOG_FILE_TMP}

# Log clean files
echo "`date +%Y-%m-%d\ %H:%M:%S` - Start clean obsolete files" | tee -a ${LOG_FILE_TMP}

# Delete old data & logs files
deleteFilesOlderThan /backup/data/ *.gz ${RETENTION_POLICY} ${LOG_FILE_TMP}
deleteFilesOlderThan /backup/data/ *.lst ${RETENTION_POLICY} ${LOG_FILE_TMP}
deleteFilesOlderThan /backup/log/ *.log ${RETENTION_POLICY} ${LOG_FILE_TMP}
deleteFilesOlderThan /backup/log/ *.err ${RETENTION_POLICY} ${LOG_FILE_TMP}
deleteFilesOlderThan /backup/log/ *.pshgw ${RETENTION_POLICY} ${LOG_FILE_TMP}

# Log clean files
echo "`date +%Y-%m-%d\ %H:%M:%S` - End clean obsolete files" | tee -a ${LOG_FILE_TMP}

# Log clean files
echo "`date +%Y-%m-%d\ %H:%M:%S` - Start clean obsolete folders" | tee -a ${LOG_FILE_TMP}

# Delete old data & logs folders
deleteEmptyFolders /backup/data/ ${LOG_FILE_TMP}
deleteEmptyFolders /backup/log/ ${LOG_FILE_TMP}

# Log clean files
echo "`date +%Y-%m-%d\ %H:%M:%S` - End clean obsolete folders" | tee -a ${LOG_FILE_TMP}

# Get current date
BACKUP_DATE=`date +%Y%m%d`

# Get backup node
BACKUP_NODE=`getBackupNode`

# Construct path
BACKUP_PATH_DATA=${BACKUP_PATH}/data/${BACKUP_NODE}/${BACKUP_DATE}
BACKUP_PATH_LOG=${BACKUP_PATH}/log/${BACKUP_NODE}/${BACKUP_DATE}

# Create data & log dir
mkdir -p ${BACKUP_PATH_DATA}
mkdir -p ${BACKUP_PATH_LOG}

# Initialize files name
LOG_FILE=${BACKUP_PATH_LOG}/backup_${REPLICA_NAME}.log
ERR_FILE=${BACKUP_PATH_LOG}/backup_${REPLICA_NAME}.err
PUSH_STATUS_FILE=${BACKUP_PATH_LOG}/push_gateway_file.pshgw
echo -e "# TYPE mysql_backup_status gauge\n# HELP mysql_backup_status If backup is done correctly 1 is OK, 0 is Critical\n# TYPE mysql_backup_duration gauge\n# HELP mysql_backup_duration Duration of this backup\n# TYPE mysql_backup_size gauge\n# HELP mysql_backup_size Size of each database backup in kB\n# TYPE mysql_backup_last_success_timestamp_seconds gauge\n# HELP mysql_backup_last_success_timestamp_seconds The last timestamp of each backup of each database" > ${PUSH_STATUS_FILE}

# Move log file
cp --no-preserve=ownership ${LOG_FILE_TMP} ${LOG_FILE}
rm -f ${LOG_FILE_TMP}

# Log check if backup possible
echo "`date +%Y-%m-%d\ %H:%M:%S` - Check if backup is possible" | tee -a ${LOG_FILE}

# Check if backup is possible
BACKUP_POSSIBLE=`isBackupPossible ${BACKUP_NODE} ${MIN_AVAILABLE_SIZE}`

# Check if there's space enough to perform backup and return result
if [ "${BACKUP_POSSIBLE}" = true ]
then
	echo "`date +%Y-%m-%d\ %H:%M:%S` -     Backup is possible on ${BACKUP_NODE} (`getNodeFreeSpace ${BACKUP_NODE}`Go available)" | tee -a ${LOG_FILE}
else
	echo "`date +%Y-%m-%d\ %H:%M:%S` - Not enough space to perform backup on ${BACKUP_NODE} (`getNodeFreeSpace ${BACKUP_NODE}`Go available - Minimum is ${MIN_AVAILABLE_SIZE}Go)" >> ${ERR_FILE}
	echo "`date +%Y-%m-%d\ %H:%M:%S` -     Not enough space to perform backup on ${BACKUP_NODE} (`getNodeFreeSpace ${BACKUP_NODE}`Go available - Minimum is ${MIN_AVAILABLE_SIZE}Go)" | tee -a ${LOG_FILE}
	echo "`date +%Y-%m-%d\ %H:%M:%S` -     Exit..." | tee -a ${LOG_FILE} && exit 1
fi


# Log
echo "`date +%Y-%m-%d\ %H:%M:%S` - Export list of databases to backup" | tee -a ${LOG_FILE}

# Get database list
EXPORT_FILE=`exportDatabasesList ${MYSQL_BCKP_LOGINPATH} ${BACKUP_PATH_DATA} ${ERR_FILE} ${EXCLUDE_FILE}`

# Check if error
if [ ${EXPORT_FILE} = ERROR ]
then
	# Log error
	echo "`date +%Y-%m-%d\ %H:%M:%S` - Error during databases list export" >> ${ERR_FILE}
	echo "`date +%Y-%m-%d\ %H:%M:%S` -     Error during databases list export: ${EXPORT_FILE}" | tee -a ${LOG_FILE}
	echo "`date +%Y-%m-%d\ %H:%M:%S` -     Exit..." | tee -a ${LOG_FILE} && exit 1
else
	# Log list filename
	echo "`date +%Y-%m-%d\ %H:%M:%S` -     ${EXPORT_FILE}" | tee -a ${LOG_FILE}
fi

# Flush logs
echo "`date +%Y-%m-%d\ %H:%M:%S` - Flush binary logs on backup server" | tee -a ${LOG_FILE}
FLUSH_STATUS=`flushBinaryLogs ${MYSQL_BCKP_LOGINPATH} ${ERR_FILE}`

# Memorize binary log before the first dump
echo "`date +%Y-%m-%d\ %H:%M:%S` - Memorize binary log status before the first dump" | tee -a ${LOG_FILE}
BCKP_BINLOG_POSITION=`getMasterBinaryLog ${MYSQL_BCKP_LOGINPATH} ${ERR_FILE}`
echo "`date +%Y-%m-%d\ %H:%M:%S` -     Binary log before the first dump is ${BCKP_BINLOG_POSITION}" | tee -a ${LOG_FILE}

echo -e "# TYPE mysql_backup_master_binlog_file_number_start gauge\n# HELP mysql_backup_master_binlog_file_number_start The last master binlog file number before backup" >> ${PUSH_STATUS_FILE}
echo "mysql_backup_master_binlog_file_number_start{host=\"${INSTANCE_NAME}\",environment=\"prod\",component=\"mysql\",application=\"ds\"} ${BCKP_BINLOG_POSITION//[^0-9]/}" >> ${PUSH_STATUS_FILE}

# Log dumps start
echo "`date +%Y-%m-%d\ %H:%M:%S` - Start databases dump" | tee -a ${LOG_FILE}

# Export each database
while read MYSQL_DATABASE
do
	# Log start
	echo "`date +%Y-%m-%d\ %H:%M:%S` -     Start dump of ${MYSQL_DATABASE} database" | tee -a ${LOG_FILE}
	dump_start=$( date +%s)

	# Dump the database
	DUMP_STATUS=`dumpDatabase ${MYSQL_BCKP_LOGINPATH} ${MYSQL_DATABASE} ${BACKUP_PATH_DATA} ${ERR_FILE}`
	dump_end=$( date +%s)
	dump_duration=$(( $dump_end - $dump_start ))
	sleep 2 
	size_backup=$( du -sb "${BACKUP_PATH_DATA}/dump_${MYSQL_DATABASE}.sql.gz" | cut -f1 )
	echo "mysql_backup_duration{host=\"${INSTANCE_NAME}\",environment=\"prod\",component=\"mysql\",application=\"ds\",database=\"${MYSQL_DATABASE}\"} ${dump_duration}" >> ${PUSH_STATUS_FILE}
	echo "mysql_backup_size{host=\"${INSTANCE_NAME}\",environment=\"prod\",component=\"mysql\",application=\"ds\",database=\"${MYSQL_DATABASE}\"} ${size_backup}" >> ${PUSH_STATUS_FILE}
	
	# Exit if error
        if [ ${DUMP_STATUS} = ERROR ]
        then
                echo "`date +%Y-%m-%d\ %H:%M:%S` - Error during ${MYSQL_DATABASE} dump" >> ${ERR_FILE}
                echo "`date +%Y-%m-%d\ %H:%M:%S` -     Error during ${MYSQL_DATABASE} dump" | tee -a ${LOG_FILE}
		echo "mysql_backup_status{host=\"${INSTANCE_NAME}\",environment=\"prod\",component=\"mysql\",application=\"ds\",status=\"warning\",database=\"${MYSQL_DATABASE}\"} 0" >> ${PUSH_STATUS_FILE}
		echo "mysql_backup{instance=\"mysql04.dc1.ds.prod\" environement=\"prod\"  "
        else
		# Log end
		echo "`date +%Y-%m-%d\ %H:%M:%S` -     End dump of ${MYSQL_DATABASE} database" | tee -a ${LOG_FILE}
		echo "mysql_backup_status{host=\"${INSTANCE_NAME}\",environment=\"prod\",component=\"mysql\",application=\"ds\",status=\"ok\",database=\"${MYSQL_DATABASE}\"} 1" >> ${PUSH_STATUS_FILE}
		echo "mysql_backup_last_success_timestamp_seconds{host=\"${INSTANCE_NAME}\",environment=\"prod\",component=\"mysql\",application=\"ds\",database=\"${MYSQL_DATABASE}\"} $(date '+%s')" >> ${PUSH_STATUS_FILE}

	fi
done < ${EXPORT_FILE}

# Log dumps end
echo "`date +%Y-%m-%d\ %H:%M:%S` - End databases dump" | tee -a ${LOG_FILE}

echo -e "# TYPE mysql_backup_master_binlog_file_cleaning gauge\n# HELP mysql_backup_master_binlog_file_cleaning If the cleaning binlog is active 1 if not 0" >> ${PUSH_STATUS_FILE}

# Clean binlogs if asked
if [ $# -gt 0 ] && [ $1 = CLEAN_BINLOGS ]
then 
	# Get host names
	MYSQL_BCKP_SERVER=`getHostFromLoginPath ${MYSQL_BCKP_LOGINPATH}`
	MYSQL_REPL_SERVER=`getHostFromLoginPath ${MYSQL_REPL_LOGINPATH}`

	# Log clean binlogs start
	echo "`date +%Y-%m-%d\ %H:%M:%S` - Start clean binlogs ${MYSQL_BCKP_SERVER} > ${MYSQL_REPL_SERVER}" | tee -a ${LOG_FILE}

	# Get backup server master binlog
	BCKP_MASTER_BINLOG=`getMasterBinaryLog ${MYSQL_BCKP_LOGINPATH} ${ERR_FILE}`
	echo "mysql_backup_master_binlog_file_cleaning{host=\"${INSTANCE_NAME}\",environment=\"prod\",component=\"mysql\",application=\"ds\",beforebackup=\"${BCKP_BINLOG_POSITION}\",endbackup=\"${BCKP_MASTER_BINLOG}\"} 1" >> ${PUSH_STATUS_FILE}

        # Exit if error
        if [ ${BCKP_MASTER_BINLOG} = ERROR ]
        then
                echo "`date +%Y-%m-%d\ %H:%M:%S` - Impossible to get ${MYSQL_BCKP_SERVER} master binary log" >> ${ERR_FILE}
                echo "`date +%Y-%m-%d\ %H:%M:%S` -     Impossible to get ${MYSQL_BCKP_SERVER} master binary log" | tee -a ${LOG_FILE}
        else
                # Log end
                echo "`date +%Y-%m-%d\ %H:%M:%S` -     ${MYSQL_BCKP_SERVER} master binary log = ${BCKP_MASTER_BINLOG}" | tee -a ${LOG_FILE}
        fi

	# Get replica server slave binlog
	REPL_SLAVE_BINLOG=`getSlaveBinaryLog ${MYSQL_REPL_LOGINPATH} ${ERR_FILE}`

        # Exit if error
        if [ ${REPL_SLAVE_BINLOG} = ERROR ]
        then
                echo "`date +%Y-%m-%d\ %H:%M:%S` - Impossible to get ${MYSQL_REPL_SERVER} slave binary log" >> ${ERR_FILE}
                echo "`date +%Y-%m-%d\ %H:%M:%S` -     Impossible to get ${MYSQL_REPL_SERVER} slave binary log" | tee -a ${LOG_FILE}
        else
                # Log end
                echo "`date +%Y-%m-%d\ %H:%M:%S` -     ${MYSQL_REPL_SERVER} slave binary log = ${REPL_SLAVE_BINLOG}" | tee -a ${LOG_FILE}
        fi

	# Test if cleaning is OK
	if [ "${BCKP_MASTER_BINLOG}" != "${REPL_SLAVE_BINLOG}" ] || [ -z "${BCKP_MASTER_BINLOG}" ] || [ -z "${REPL_SLAVE_BINLOG}" ] || [ ${BCKP_MASTER_BINLOG} = ERROR ] || [ ${REPL_SLAVE_BINLOG} = ERROR ]
	then
		echo "`date +%Y-%m-%d\ %H:%M:%S` - ${MYSQL_BCKP_SERVER} and ${MYSQL_REPL_SERVER} are not in sync" >> ${ERR_FILE}
		echo "`date +%Y-%m-%d\ %H:%M:%S` -     ${MYSQL_BCKP_SERVER} and ${MYSQL_REPL_SERVER} are not in sync: do nothing" | tee -a ${LOG_FILE}
	else
		echo "`date +%Y-%m-%d\ %H:%M:%S` -     ${MYSQL_REPL_SERVER} and ${MYSQL_BCKP_SERVER} are in sync: cleaning ${MYSQL_BCKP_SERVER} binlogs up to ${BCKP_BINLOG_POSITION} file" | tee -a ${LOG_FILE}
		#CLEAN_BCKP=`cleanBinaryLogs ${MYSQL_BCKP_LOGINPATH} ${BCKP_MASTER_BINLOG} ${ERR_FILE}`
		CLEAN_BCKP=`cleanBinaryLogs ${MYSQL_BCKP_LOGINPATH} ${BCKP_BINLOG_POSITION} ${ERR_FILE}`
	
		if [ ${CLEAN_BCKP} = ERROR ]
		then
			echo "`date +%Y-%m-%d\ %H:%M:%S` - Impossible to clean ${MYSQL_BCKP_SERVER} binary logs" >> ${ERR_FILE}
			echo "`date +%Y-%m-%d\ %H:%M:%S` -     Impossible to clean ${MYSQL_BCKP_SERVER} binary logs" | tee -a ${LOG_FILE}
	        else
			echo "`date +%Y-%m-%d\ %H:%M:%S` -     Cleaning ${MYSQL_BCKP_SERVER} binary logs OK" | tee -a ${LOG_FILE}
		fi
	fi

        # Log clean binlogs end
        echo "`date +%Y-%m-%d\ %H:%M:%S` - End clean binlogs ${MYSQL_BCKP_SERVER} > ${MYSQL_REPL_SERVER}" | tee -a ${LOG_FILE}


        # Log clean binlogs start
        echo "`date +%Y-%m-%d\ %H:%M:%S` - Start clean binlogs ${MYSQL_REPL_SERVER} > ${MYSQL_BCKP_SERVER}" | tee -a ${LOG_FILE}

	# Get replica server master binlog
	REPL_MASTER_BINLOG=`getMasterBinaryLog ${MYSQL_REPL_LOGINPATH} ${ERR_FILE}`

        # Check for error
        if [ ${BCKP_MASTER_BINLOG} = ERROR ]
        then
                echo "`date +%Y-%m-%d\ %H:%M:%S` - Impossible to get ${MYSQL_REPL_SERVER} master binary log" >> ${ERR_FILE}
                echo "`date +%Y-%m-%d\ %H:%M:%S` -     Impossible to get ${MYSQL_REPL_SERVER} master binary log" | tee -a ${LOG_FILE}
        else
                # Log end
                echo "`date +%Y-%m-%d\ %H:%M:%S` -     ${MYSQL_REPL_SERVER} master binary log = ${REPL_MASTER_BINLOG}" | tee -a ${LOG_FILE}
        fi

	# Get backup server slave binlog
	BCKP_SLAVE_BINLOG=`getSlaveBinaryLog ${MYSQL_BCKP_LOGINPATH} ${ERR_FILE}`

        # Check for error
        if [ ${BCKP_SLAVE_BINLOG} = ERROR ]
        then
                echo "`date +%Y-%m-%d\ %H:%M:%S` - Impossible to get ${MYSQL_BCKP_SERVER} slave binary log" >> ${ERR_FILE}
                echo "`date +%Y-%m-%d\ %H:%M:%S` -     Impossible to get ${MYSQL_BCKP_SERVER} slave binary log" | tee -a ${LOG_FILE}
        else
                # Log end
                echo "`date +%Y-%m-%d\ %H:%M:%S` -     ${MYSQL_BCKP_SERVER} slave binary log = ${BCKP_SLAVE_BINLOG}" | tee -a ${LOG_FILE}
        fi

	# Test if cleaning is OK
	if [ "${REPL_MASTER_BINLOG}" != "${BCKP_SLAVE_BINLOG}" ] || [ -z "${REPL_MASTER_BINLOG}" ] || [ -z "${BCKP_SLAVE_BINLOG}" ] || [ ${REPL_MASTER_BINLOG} = ERROR ] || [ ${BCKP_SLAVE_BINLOG} = ERROR ]
	then
		echo "`date +%Y-%m-%d\ %H:%M:%S` - ${MYSQL_REPL_SERVER} and ${MYSQL_BCKP_SERVER} are not in sync" >> ${ERR_FILE}
		echo "`date +%Y-%m-%d\ %H:%M:%S` -     ${MYSQL_REPL_SERVER} and ${MYSQL_BCKP_SERVER} are not in sync: do nothing" | tee -a ${LOG_FILE}
	else
		echo "`date +%Y-%m-%d\ %H:%M:%S` -     ${MYSQL_REPL_SERVER} and ${MYSQL_BCKP_SERVER} are in sync: cleaning ${MYSQL_REPL_SERVER} binlogs up to ${REPL_MASTER_BINLOG} file" | tee -a ${LOG_FILE}
		CLEAN_REPL=`cleanBinaryLogs ${MYSQL_REPL_LOGINPATH} ${REPL_MASTER_BINLOG} ${ERR_FILE}`
	
		if [ ${CLEAN_REPL} = ERROR ]
		then
			echo "`date +%Y-%m-%d\ %H:%M:%S` - Impossible to clean ${MYSQL_REPL_SERVER} binary logs" >> ${ERR_FILE}
			echo "`date +%Y-%m-%d\ %H:%M:%S` -     Impossible to clean ${MYSQL_REPL_SERVER} binary logs" | tee -a ${LOG_FILE}
	        else
			echo "`date +%Y-%m-%d\ %H:%M:%S` -     Cleaning ${MYSQL_REPL_SERVER} binary logs OK" | tee -a ${LOG_FILE}
		fi
	fi

        echo "`date +%Y-%m-%d\ %H:%M:%S` - End clean binlogs ${MYSQL_REPL_SERVER} > ${MYSQL_BCKP_SERVER}" | tee -a ${LOG_FILE}
else
	
	echo "mysql_backup_master_binlog_file_cleaning{host=\"${INSTANCE_NAME}\",environment=\"prod\",component=\"mysql\",application=\"ds\",beforebackup=\"${BCKP_BINLOG_POSITION}\"} 0" >> ${PUSH_STATUS_FILE}
fi

END_BCKP_BINLOG_POSITION=`getMasterBinaryLog ${MYSQL_BCKP_LOGINPATH} ${ERR_FILE}`
echo -e "# TYPE mysql_backup_master_binlog_file_number_end gauge\n# HELP mysql_backup_master_binlog_file_number_end The last master binlog file number after backup" >> ${PUSH_STATUS_FILE}
echo "mysql_backup_master_binlog_file_number_end{host=\"${INSTANCE_NAME}\",environment=\"prod\",component=\"mysql\",application=\"ds\"} ${END_BCKP_BINLOG_POSITION//[^0-9]/}" >> ${PUSH_STATUS_FILE}

# Clean log files 
echo "`date +%Y-%m-%d\ %H:%M:%S` - Start cleaning" | tee -a ${LOG_FILE}

# Delete error file if empty
echo "`date +%Y-%m-%d\ %H:%M:%S` -     Clean error file" | tee -a ${LOG_FILE}
if [ ! -s ${ERR_FILE} ]
then
	rm -f ${ERR_FILE}
fi

# Delete lock file
echo "`date +%Y-%m-%d\ %H:%M:%S` -     Delete lock file" | tee -a ${LOG_FILE}
rm -f ${LOCK_FILE}

echo "`date +%Y-%m-%d\ %H:%M:%S` - End cleaning" | tee -a ${LOG_FILE}


# Log
cat  ${PUSH_STATUS_FILE} | curl --data-binary @- https://${PROMETHEUS_PUSHGATEWAY}/metrics/job/mysql_backup/instance/${INSTANCE_NAME}
 
echo "`date +%Y-%m-%d\ %H:%M:%S` - ---------------------------------------------" | tee -a ${LOG_FILE}
echo "`date +%Y-%m-%d\ %H:%M:%S` - End backup of replica ${REPLICA_NAME}" | tee -a ${LOG_FILE}
echo "`date +%Y-%m-%d\ %H:%M:%S` - ---------------------------------------------" | tee -a ${LOG_FILE}



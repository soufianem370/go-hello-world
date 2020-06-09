#!/bin/bash

#########
### DS MySQL BACKUP MONITORING SCRIPT
### - Check if backup of the day exists, contains as many file as databases and contains data
### - Check if errors have been detected
### - Check if cleaning as been done
### Call: ./monitoring.sh
#########


# Load configuration
. /backup/conf/backup.conf

# Initialize line break
BR="\n"

# Return codes
RETURN_OK=0
RETURN_WARNING=1
RETURN_CRITICAL=2
RETURN_UNKNOWN=3

# Set minimum size
MINIMUM_SIZE=1024

# Get current date
BACKUP_DATE=`date +%Y%m%d`

# Construct paths
BACKUP_PATH_DATA=${BACKUP_PATH}/data/
BACKUP_PATH_LOG=${BACKUP_PATH}/log/

# Lock file
LOCK_FILE=/var/lock/subsys/backup

# Get number of backup process running
COUNT_PROCESSES=$(( `ps -ef | grep backup.sh | wc -l` -1 ))

# Check if backup is running
if [ -f ${LOCK_FILE} ] &&  [ ${COUNT_PROCESSES} -gt 0 ]
then
	RES="Backup is running. Please check again later..."
	echo ${RES}
	exit ${RETURN_UNKNOWN}
elif [ -f ${LOCK_FILE} ] &&  [ ${COUNT_PROCESSES} -eq 0 ]
then
	RES="ERROR - Backup is not running but lock file still exists"
	echo -e ${RES}
	exit ${RETURN_CRITICAL}
else
	RES="OK - Lock file has been removed"
fi

# Check if backup of the day exists
BACKUP_EXISTS=`find ${BACKUP_PATH_DATA} -type d -name ${BACKUP_DATE} | wc -l`

if [ ${BACKUP_EXISTS} -eq 1 ]
then
	RES="OK - Backup of the day exists"${BR}${RES}
else 
	RES="ERROR - No backup today!"${BR}${RES}
	echo -e ${RES}
	exit ${RETURN_CRITICAL}
fi


# Initialize query
COUNT_DATABASES_QUERY="SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME NOT IN (\"information_schema\",\"performance_schema\""

# Check if exclude file has data or not
if [[ -s ${EXCLUDE_FILE} ]]
then
	# Get excludes
	EXCLUDES=`cat ${EXCLUDE_FILE} | paste -s -d',' | sed -r 's/,/\",\"/g'`
	
	# Append query
	COUNT_DATABASES_QUERY="${COUNT_DATABASES_QUERY},\"${EXCLUDES}\");"
else
	# Append query
	COUNT_DATABASES_QUERY="${COUNT_DATABASES_QUERY});"
fi

# Execute query
DATABASES_NUMBER=`mysql --host=${MYSQL_BCKP_SERVER} --port=${MYSQL_BCKP_PORT} --user=${MYSQL_BCKP_USER} --raw --batch --skip-column-names --execute="${COUNT_DATABASES_QUERY}"`

# Get the number of dumps
BACKUP_NUMBER=`find ${BACKUP_PATH_DATA}*/${BACKUP_DATE} -type f -name "*.sql.gz" | wc -l`

# Check if number of backups is coherent with number of databases
if [ ${BACKUP_NUMBER} -lt ${DATABASES_NUMBER} ]
then
	RES="ERROR - There is less backups (${BACKUP_NUMBER}) than databases to backup (${DATABASES_NUMBER})"${BR}${RES}
	echo -e ${RES}
	exit ${RETURN_CRITICAL}
else 
	RES="OK - Number of backups is coherent with the number of databases to backup"${BR}${RES}
fi


# Check each backup size
for FILE in `find ${BACKUP_PATH_DATA}*/${BACKUP_DATE} -type f -name "*.sql.gz"`
do
	BACKUP_SIZE=`wc -c <${FILE}`

	if [ ${BACKUP_SIZE} -le ${MINIMUM_SIZE} ]
	then
		RES="ERROR - ${FILE} size is smaller than minimum size. Backup is probably empty"${BR}${RES}
		echo -e ${RES}
		exit ${RETURN_CRITICAL}
	else
		RES="OK - ${FILE} size is coherent"${BR}${RES}
	fi
done


# Check if errors have been detected
ERROR_NUMBER=`find ${BACKUP_PATH_LOG}*/${BACKUP_DATE} -type f -name "*.err" | wc -l`

if [ ${ERROR_NUMBER} -gt 0 ]
then
	# Get error file
	ERROR_FILE=`find ${BACKUP_PATH_LOG}*/${BACKUP_DATE} -type f -name "*.err"`

	RES="ERROR - Errors occured during backup process:`cat ${ERROR_FILE} | awk -F' - ' '{ print echo " " $2 }' | paste -s -d','`"${BR}${RES}
	echo -e ${RES}
	exit ${RETURN_CRITICAL}
else
	RES="OK - No error during backup process"${BR}${RES}
fi


# Get the number of obsolete files
NUMBER_OBSOLETE_FILES=`find ${BACKUP_PATH_DATA} -type f -iname "*.sql.gz" -ctime +${RETENTION_POLICY} | wc -l`

if [ ${NUMBER_OBSOLETE_FILES} -gt 0 ]
then
	RES="WARNING - Some obsolete files are still remaining"${BR}${RES}
	echo  -e ${RES}
	exit ${RETURN_WARNING}
else 
	RES="OK - All obsolete files have been removed"${BR}${RES}
fi


# Get the number of obsolete folders
NUMBER_OBSOLETE_FOLDERS=`find ${BACKUP_PATH_DATA} -type d ! -name 'data' ! -name 'node1' ! -name 'node2' -ctime +${RETENTION_POLICY} | wc -l`

if [ ${NUMBER_OBSOLETE_FOLDERS} -gt 0 ]
then
	RES="WARNING - Some obsolete folders are still remaining"${BR}${RES}
	echo -e ${RES}
	exit ${RETURN_WARNING}
else 
	RES="OK - All obsolete folders have been removed"${BR}${RES}
fi

# Return OK
RES="OK - Backup is OK"${BR}${RES}
echo -e ${RES}
exit ${RETURN_OK}

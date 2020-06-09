#!/bin/bash

#-----------
# Delete files older than parameter
# @param $1 Search path
# @param $2 Files extension 
# @param $3 Files age
# @param $4 Log file
#-----------
function deleteFilesOlderThan() {

	# Get parameters
	FIND_PATH=$1
	FIND_NAME=$2
	FIND_AGE=$3
	LOG_FILE=$4
	
	# Delete files
	find ${FIND_PATH} -type f -iname "${FIND_NAME}" -ctime +$(( ${FIND_AGE}-2 )) -delete -print | tee -a ${LOG_FILE}
}

#-----------
# Delete folders older than parameters
# @param $1 Search path
# @param $2 Folders age
# @param $3 Log file
#-----------
function deleteFoldersOlderThan() {

        # Get parameters
        FIND_PATH=$1
        FIND_AGE=$2
        LOG_FILE=$3

        # Delete folders
        find ${FIND_PATH} -type d ! -name 'data' ! -name 'log' ! -name 'node1' ! -name 'node2' -ctime +$(( ${FIND_AGE}-2 )) -delete -print | tee -a ${LOG_FILE}
}

#-----------
# Delete empty folders
# @param $1 Search path
# @param $2 Log file
#-----------
function deleteEmptyFolders() {

	# Get parameters
	FIND_PATH=$1
	LOG_FILE=$2

	# Delete folders
	find ${FIND_PATH} -type d -empty ! -name 'data' ! -name 'log' ! -name 'node1' ! -name 'node2' -delete -print | tee -a ${LOG_FILE}
}

#-----------
# Get node on which disk space is greater
# @return the name of the node
#-----------
function getBackupNode() {

	# Get nodes disk usage
	BACKUP_NODE=$(df -Pk /backup/data/node? | tail -n+2 | awk '{ print $NF"|"$4 }' | sort -k2n -t '|' | tail -1 | cut -f1 -d '|' | cut -f4 -d '/' )

	# Return node
        echo ${BACKUP_NODE}
}


#-----------
# Get node free space in Gb
# @param $1 the name of the node
# @return free space
#-----------
function getNodeFreeSpace() {

        # Get parameters
        BACKUP_NODE=$1

        # Get node free space
        FREE_SPACE=$(( `df -Pk /backup/data/${BACKUP_NODE} | awk '{ getline; print $4 }'` /1024/1024))

	echo ${FREE_SPACE}
}


#-----------
# Get data free space in Gb
# @return free space
#-----------
function getDataFreeSpace() {

        # Get free space
        FREE_SPACE=$(( `df -Pk /data/ | awk '{ getline; print $4 }'` /1024/1024))

	echo ${FREE_SPACE}
}


#-----------
# Get data used space in Gb
# @return used space
#-----------
function getDataUsedSpace() {

        # Get free space
        USED_SPACE=$(( `df -Pk /data/ | awk '{ getline; print $3 }'` /1024/1024))

	echo ${USED_SPACE}
}


#-----------
# Get data total space in Gb
# @return free space
#-----------
function getDataTotalSpace() {

        # Get total space
        TOTAL_SPACE=$(( `df -Pk /data/ | awk '{ getline; print $2 }'` /1024/1024))

	echo ${TOTAL_SPACE}
}


#-----------
# Get file size in Gb
# @return file size
#-----------
function getFileSize() {

	# Get parameters
	FILE=$1

	# Get file size	
	FILE_SIZE=$(( `ls -l ${FILE} | awk '{print $5}'` /1024/1024))

	# Approximation if file < 1Gb
	if [ ${FILE_SIZE} -lt 1024 ]
	then
		FILE_SIZE=1024
	fi


	# Return size
	echo $(( ${FILE_SIZE} /1024 ))
}


#-----------
# Check if backup is possible on a node
# @param $1 the name of the node
# @return the result (true or false)
#-----------
function isBackupPossible() {

        # Get parameters
        BACKUP_NODE=$1
	MIN_SPACE=$2

        # Get node free space
        FREE_SPACE=$(( `df -Pk /backup/data/${BACKUP_NODE} | awk '{ getline; print $4 }'` /1024/1024))

	# Check if there's space enough to perform backup and return result
	if [ ${FREE_SPACE} -ge ${MIN_SPACE} ]
	then
	        echo true
	else
	        echo false
	fi
}


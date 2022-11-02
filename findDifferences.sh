#!/bin/bash

echo "Starting comparing..."
ME=$(basename $0)
ROOT=$(dirname $0)
if [[ ${ROOT} == "." ]]
then
	ROOT=${PWD}
fi

echo "Validating parameters..."
if [[ $# -eq 0 ]]
then
	echo "Usage: ${ME} <file list to compare>"
	echo -e "  For Example: ${ME} list.txt"
	echo -e "  list.txt file contains the list of files to be compared and has below content"
	echo -e "  $ cat list.txt"
	echo -e "  file1"
	echo -e "  file2"
	exit 1
fi

INFILE=$1
SRC_ROOT="SRC"
GIT_ROOT="GIT"
OUTFILE="DIFF_OUT"

echo "Creating outout file [ ${OUTFILE} ]"
C=$(ls -1tr ${OUTFILE}* | head -1)
COUNT=${C##*.}

if [[ ${COUNT} -gt 2 ]]
then
	COUNT=2
fi

if [[ ${COUNT} -eq 2 ]]
then
	let C=${COUNT}-1
	mv ${OUTFILE}.${C} ${OUTFILE}.${COUNT}
	mv ${OUTFILE} ${OUTFILE}.${C}
else
	mv ${OUTFILE} ${OUTFILE}.${C}
fi
rm -f "${OUTFILE}"
touch "${OUTFILE}"

exec < ${INFILE}
while read cFile
do
	echo -e "Checking file [${cFile}]...\c"
	diff ${SRC_ROOT}/${cFile} ${GIT_ROOT}/${cFile} > /dev/null
	RC=$?
	if [[ ${RC} -ne 0 ]]
	then
		echo "${SRC_ROOT}/${cFile} ${GIT_ROOT}/${cFile}" >> ${OUTFILE}
		echo "[NOT OK]"
	else
		echo "[  OK  ]"
	fi
done

if [[ ! -z ${OUTFILE} ]]
then
	echo
	echo "There are differences found."
        echo "File names are recorded in ${ROOT}/${OUTFILE}"
	echo
	exit 2
fi

exit 0

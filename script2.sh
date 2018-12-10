#!/bin/bash


#Functions

#clone
cloneproj() {
	asgncnt=$(($asgncnt+1)) # a counter for reporsitories
	name="repo$asgncnt"
	git clone -q "$line" "./assignments/$name" > /dev/null 2>&1
	if [ $? = 0 ] ; then    #if cloned
		echo "$1: Cloning OK" >&1
	else 
		echo "$1: Cloning FAILED" >&2
	fi
}


#Stats
printstats() {
	if [ $(find ./assignments/ -maxdepth 1 -type d | wc -l) -eq 1 ] ; then
		echo "No repositories cloned" >&2	
	else
	find ./assignments/* -maxdepth 0 -type d | while read -r dirc ; do
		echo "$(basename "$dirc:")" >&1
		dirnum=$(find ./$dirc -mindepth 1 -type d -not -path "./$dirc/.*"| wc -l)
		echo "Number of directories: $dirnum" >&1
		txtnum=$(find ./$dirc -type f -name "*.txt" -not -path "./$dirc/.*" | wc -l)
		echo "Number of txt files: $txtnum" >&1
		othernum=$(($(find ./$dirc -type f -not -path "./$dirc/.*" | wc -l)-$txtnum))
		echo "Number of other files: $othernum" >&1
		if [ $dirnum -eq 1 ] && [ $txtnum -eq 3 ] && [ $othernum -eq 0 ] && \
		[ $(find ./$dirc -type f -name "dataA.txt" | wc -l) -eq 1 ] && \
		[ $(find ./$dirc"/more" -type f -name "dataB.txt" | wc -l) -eq 1 ] && \
		[ $(find ./$dirc"/more" -type f -name "dataC.txt" | wc -l) -eq 1 ] ; then
			echo "Directory structure is OK." >&1
		else
			echo "Directory structure is NOT OK." >&2
		fi
	done
	fi
}


#Main
asgncnt=0;
if [ ! $# -eq 0 ] ; then
	#check and make assignments dir
	if [ ! -d ./assignments ]; then	
		mkdir ./assignments
	fi
	#extract tar.gz	
	inputfile=$1
	if [ ! -d ./uncompressed ] ; then
		mkdir ./uncompressed
	fi
	tar -xvzf "$1" -C "./uncompressed" > /dev/null
	#find all txt files	
	find ./uncompressed -name "*.txt" | while read -r filee ; do
		while read -r line ; do
		if [[ $line != https* ]] ; then
			continue;
		fi
			cloneproj $line
			break;
		done < "$filee"
	done
	printstats
fi

rm -rf uncompressed
rm -rf assignments

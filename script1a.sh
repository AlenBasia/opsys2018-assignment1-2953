#!/bin/bash


#Functions

downloadsite() {
	wget -q -O $filename $line
	if [ "$?" = 0 ] ; then
		echo "$line" " INIT" >&1
	else
		echo "$line" " FAILED" >&2
	fi
}

checkdiff() {
	filename2="$filename""2.html"	
	wget -q -O $filename2 $line
	if [ "$?" = 0 ]; then
		DIFFS=$(diff $filename $filename2) > /dev/null
		if [ "$DIFFS" != "" ]; then
			echo "$line" >&1
			cp "$filename2" "$filename" && rm "$filename2"		
		else
			rm "$filename2"
		fi
	#else	
	fi
}


#Main
#make directory for sites
sitesdirectory=./mysites
if [ ! -d $sitesdirectory ]; then
	mkdir $sitesdirectory
fi

#read sites file
if [ ! $# -eq 0 ] ; then 
	mysites="$1"
	while read -r line; do
		cd $sitesdirectory
		if [[ $line != \#* ]]; then
			filename=$line
			filename="${filename//\//}.html"
			if [ ! -f $filename ] ; then  #if not downloaded
				downloadsite
			else
				checkdiff		
			fi
		fi
		cd ..
	done < "$mysites"
else echo "No arguments supplied. You have to provide a file with websites." >&2
fi


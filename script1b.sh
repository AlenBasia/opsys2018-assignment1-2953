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

#read sites file
if [ ! $# -eq 0 ] ; then 
	mysites="$1"
	while read -r line; do
		if [[ $line != \#* ]]; then
			filename=$line
			filename="${filename//\//}.html"
			if [ ! -f $filename ] ; then  #if not downloaded
				downloadsite & continue		#thread
			else
				filename2="$filename""2.html"
				checkdiff & continue		#thread
				
			fi
		fi
	done < "$mysites"
	wait
else echo "No arguments supplied. You have to provide a file with websites." >&2
fi


# Usage:  ./prepare.sh [folder_with_gradebook*.zip] [/path/to/students.txt]
move_to_caseid() {
    #$1 is HW10
    #$2 is ted27
	mkdir $1/$2/
	for J in `find $1 -type f -name \*$2\*`; do
        # NOTE: Since the files for multiple attempts are lexicographically ordered, 
        #  newer attempts will override older attempts.
        BASENAME=`basename $J`
        ACTUAL_FILENAME=`echo $BASENAME | cut -d "_" -f 5-`
        TYPE=`file -bI $J | grep -o 'application/octet-stream'`
        if [[ -z $TYPE ]]; then
            # If the file isn't a binary blob, append the filename as a comment
            #   at the top of the file.
            if [[ -n $ACTUAL_FILENAME ]]; then
                echo "%"$BASENAME > $1/$2/$ACTUAL_FILENAME 
                cat $J >> $1/$2/$ACTUAL_FILENAME
            fi
            rm $J
        else
            # If the file IS a binary blob, just copy it to its proper place.
            mv $J $1/$2/$ACTUAL_FILENAME
        fi
	done
}

if [ $# -ne 2 ]; then
	echo "Usage:  ./prepare.sh [folder_with_gradebook*.zip] [/path/to/students.txt]"
	exit
fi

# First unzip the gradebook file...
unzip $1/gradebook*.zip -d $1 -q

# Then remove all files which aren't in students.txt
if [[ -f $2 ]]; then
    find $1 -type f | grep -v -F -f $2 | grep -v gradebook | xargs rm
fi

# Now move all students' files into their own folder.
for CASEID in `find $1 -type f | grep -v gradebook | cut -d "_" -f 2 | uniq`; do
    move_to_caseid $1 $CASEID &
done

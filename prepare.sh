# Usage:  ./prepare.sh [folder_with_gradebook*.zip] [/path/to/students.txt]

if [ $# -ne 2 ]; then
	echo "Usage:  ./prepare.sh [folder_with_gradebook*.zip] [/path/to/students.txt]"
	exit
fi

# First unzip the gradebook file...
unzip $1/gradebook*.zip -d $1

# Then remove all files which aren't in students.txt
if [[ -f $2 ]]; then
    find $1 -type f | grep -v -F -f $2 | grep -v gradebook | xargs rm
fi

# Now move all students' files into their own folder.
for CASEID in `find $1 -type f | grep -v gradebook | cut -d "_" -f 2 | uniq`; do
	mkdir $1/$CASEID/
	for J in `find $1 -type f -name \*$CASEID\*`; do
		BASENAME=`basename $J`
		ACTUAL_FILENAME=`echo $BASENAME | cut -d "_" -f 5-`
        if [[ -n $ACTUAL_FILENAME ]]; then
            echo "%"$BASENAME > $1/$CASEID/$ACTUAL_FILENAME 
            cat $J >> $1/$CASEID/$ACTUAL_FILENAME
        fi
		rm $J
	done
done

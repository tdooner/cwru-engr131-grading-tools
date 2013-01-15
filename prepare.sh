# Usage:  ./prepare.sh [folder_with_gradebook*.zip] [/path/to/students.txt]

move_to_caseid() {
    #$1 is HW10
    #$2 is ted27
    mkdir $1/$2/
    for J in `find $1 -type f -name \*$2\*`; do
        # NOTE: Since the files for multiple attempts are lexicographically
        # ordered, newer attempts will override older attempts.
        BASENAME=`basename $J`
        ACTUAL_FILENAME=`echo $BASENAME | cut -d "_" -f 5-`
        if [[ -n $ACTUAL_FILENAME ]]; then
            mv $J $1/$2/$ACTUAL_FILENAME
        else
            rm $J
        fi
    done
    # If there are files in $1/everyone, symlink them in everyone's directory.
    if [[ -d $1/everyone ]]; then
        for J in `ls $1/everyone/`; do
            # If the file was included by the student, use the vanilla version
            # anyway.
            ln -fs ../everyone/$J $1/$2/$J
        done
    fi
}

if [ $# -ne 2 ]; then
    echo "Usage:  ./prepare.sh [folder_with_gradebook*.zip] [/path/to/students.txt]"
    exit
fi

# First unzip the gradebook file...
unzip -q -d $1 $1/gradebook*.zip

# Then remove all files which aren't in students.txt
if [[ -f $2 ]]; then
    find $1 -type f | grep -v -F -f $2 | grep -v gradebook | grep -v /everyone/ | xargs rm
fi

# Now move all students' files into their own folder.
for CASEID in `find $1 -type f | grep -v gradebook | grep -v /everyone/ | cut -d "_" -f 2 | uniq`; do
    move_to_caseid $1 $CASEID &
done

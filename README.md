Tom's ENGR131 Grading Tools
===========================
A small suite of tools that I wrote to make grading go a bit faster.

File Acquisition
-------------------------
Using these tools makes grading MATLAB downloaded from Blackboard minimally painful. Here is how to use the script.

1. Create a list `students.txt` with your students' CaseIDs, one per line.
2. On Blackboard, go to Grade Center and find the desired assignment to grade.
3. On the _Assignment File Download_ screen, download a .zip with all students in it (Show All > Select All)
4. Download the file (gradebook[assignment\_name].zip) into a new directory alongside `prepare.sh`. For instance, here is my folder heirarchy, each folder containing the gradebook zip file for that assignment:
    Shiny:TA tom$ ls
    HW1
    HW2
    HW3
    HW4
    HW5
    HW6
    HW7
    HW8
    HW9
    Lab2
    Lab3
    Lab4
    Lab5
    Lab6
    Lab7
    Lab8
    Lab9
    cheat.py
    prepare.sh
    students.txt
5. Run `./prepare.sh [AssignmentFolder] [/path/to/students.txt]` (e.g. `./prepare.sh HW8 students.txt`)
6. All files for each person have been extracted and grouped. In MATLAB you can step through the directories with ease and look at all the files.

Cheating Detection
-------------------------
After running through the file acquisition process, simply run `python cheat.py [AssignmentFolder]`.

#### Arguments to cheat.py
* *Argument 1 (required)*: Folder that all the files have been extracted to (see _File Acquisition_)
* Argument 2: Threshold to use for file similarity in fractional form. (e.g. 0.9 for 90% similar)
* Argument 3: Regexp for files to skip. For example if `neuron.m` is provided by the instructor, you can ignore it with a regex similar to `[nN]euron\.m`

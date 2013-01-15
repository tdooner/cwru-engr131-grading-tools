Tom's ENGR131 Grading Tools
===========================
A small suite of tools that I wrote to make grading go a bit faster.

File Acquisition
-------------------------
Using these tools makes grading MATLAB downloaded from Blackboard minimally painful. Here is how to use the script.

1. Create a list `students.txt` with your students' CaseIDs, one per line.
2. On Blackboard, go to Grade Center and find the desired assignment to grade.
3. On the _Assignment File Download_ screen, download a .zip with all students in it (Show All > Select All)
4. Move the downloaded file (gradebook[assignment\_name].zip) into a new directory alongside `prepare.sh`. For instance, here is my folder heirarchy, each folder containing the gradebook zip file for that assignment:

```10073 Case 2011-2012/TA  » tree
.
├── HW1
│   ├── gradebook_ENGR_131_HW\ 1.zip
├── HW2
│   ├── gradebook_ENGR_131_HW\ 2.zip
│   ├── everyone
│   │   ├── audio.wav
│   │   ├── digital.wav
│   │   ├── is.wav
│   │   ├── madhava.m
│   │   └── monteCarlo.m
├── cheat.py
├── cheat.sh
├── prepare.sh
└── students.txt```

5. (Optionally) Create a folder `everyone` alongside the gradebook*.zip file. All files in `everyone` will be symlinked in every student's folder. Use this for files that are included with the assignment.
6. Run `./prepare.sh [AssignmentFolder] [/path/to/students.txt]` (e.g. `./prepare.sh HW8 students.txt`). If you don't want to limit the files to those in students.txt, pass in `/dev/null` for students.txt.
7. All files for each person have been extracted and grouped. In MATLAB you can step through the directories with ease and look at all the files.

Cheating Detection
-------------------------
After running through the file acquisition process, simply run `python cheat.py [AssignmentFolder]`.

#### Arguments to cheat.py
* *Argument 1 (required)*: Folder that all the files have been extracted to (see _File Acquisition_)
* Argument 2: Threshold to use for file similarity in fractional form. (e.g. 0.9 for 90% similar)
* Argument 3: Regexp for files to skip. For example if `neuron.m` is provided by the instructor, you can ignore it with a regex similar to `[nN]euron\.m`

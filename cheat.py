#!/usr/bin/env python
# Arg 1: Path to folders with Case IDs (e.g. HW8)
# Arg 2: Threshold to use
# Arg 3: Regexp to ignore in filenames

from difflib import SequenceMatcher
import os, os.path
import sys
import re

if len(sys.argv) > 2:
    threshold = float(sys.argv[2])
else:
    threshold = 0.75

def valid_files(file_list):
    if len(sys.argv) > 3:
        return [x for x in file_list if (re.search("\.m$", x) != None and re.search(sys.argv[3], x) == None)]
    else:
        return [x for x in file_list if (re.search("\.m$", x) != None)]

class Comparer:
    def __init__(self, root_dir):
        self.root_dir = root_dir
        self.case_ids = [x for x in os.listdir(root_dir) if (re.match("^[a-z]{3}[0-9]*$", x) != None) ]

    def compare_two_people(self, first_id, second_id):
        first = valid_files( os.listdir( os.path.join(self.root_dir, first_id) ))
        second = valid_files( os.listdir( os.path.join(self.root_dir, second_id) ))
        for i in first:
            i_path = os.path.join( self.root_dir, first_id, i )
            for j in second:
                j_path = os.path.join( self.root_dir, second_id, j )
                # Remove empty strings from the code and also linebreaks.
                a = [i for sublist in filter(None, [x.strip().split(" ") for x in open(i_path).readlines()]) for i in sublist]
                b = [i for sublist in filter(None, [x.strip().split(" ") for x in open(j_path).readlines()]) for i in sublist]
                similar = SequenceMatcher(None, a,b).ratio()
                if similar >= threshold:
                    print "Found {0} percent similarity in {1} {2}".format(similar,i_path,j_path)

    def run(self):
        for n,i in enumerate(self.case_ids):
            sys.stderr.write("{0} ".format(n))
            for j in self.case_ids[n+1:]:
                #print "Comparing {0} {1}".format(i,j)
                self.compare_two_people(i, j)

if __name__ == '__main__':
    c = Comparer(sys.argv[1])
    c.run()

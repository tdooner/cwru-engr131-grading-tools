from tempfile import mkdtemp, mkstemp
from time import sleep
import os.path
from os import listdir, remove
import subprocess
import glob

NUM_SKIP_LINES = 11
MATLAB_PATH = "/Applications/MATLAB_R2011a.app/bin/matlab"
MATLAB_ARGS = ['-nodesktop', '-nosplash']

class MATLABRunner:
    def __init__(self):
        pass

    def run_matlab(self, matlab_str, path=os.path.abspath(__file__)):
        '''
        Runs an arbitrary MATLAB string of commands, e.g.
            run_matlab('disp("hi"); disp("hi again");')

        Optionally accepts a path to append to the MATLABPATH, so arbitrary
        user functions can be used.
        '''
        matlab_str = matlab_str + "; exit;"
        cmd = [MATLAB_PATH] + MATLAB_ARGS + ['-r', matlab_str]
        status, out, err = self.execute_command(cmd,
                timeout=90,
                options={'MATLABPATH': path})
        if status == 0:
            actual_output = out.split("\n")[(NUM_SKIP_LINES-1):]
            return ("\n".join(actual_output), err)
        else:
            raise MATLABException(err)
            return None

    def publish_matlab(self, matlab_str):
        '''
        Runs a given MATLAB string through MATLAB's publish() function. Use
        this to capture graphical output.
            publish_matlab("x=-1:0.1:1; y=sin(x); plot(x,y);")
        '''
        tmp_dir = mkdtemp()
        m_file_name = mkstemp(suffix=".m", dir=tmp_dir)[1]
        m_file = open(m_file_name, "w")
        m_file.write(matlab_str)
        m_file.close()
        matlab_str = "publish('" + m_file_name + "')"
        out, err = self.run_matlab(matlab_str, path=tmp_dir)

        # Now, deal with the output:
        images = glob.glob(os.path.join(
            tmp_dir,
            'html',
            os.path.basename(m_file_name).split(".")[0] + '_*.png'))
        return {
            'images': images,
            'm_file': m_file_name,
            'stdout': out,
            'stderr': err
        }

    def execute_command(self, cmd, timeout=0, options={}):
        """
        Run an arbitrary command with an optional timeout (in seconds).
        """
        print "Running " + " ".join(cmd)
        for k,v in options.items():
            print "ENV['{0}']={1}".format(k,v)
        p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=options)
        # If no timeout is desired, wait for the command to complete.
        if timeout == 0:
            p.wait()
            return (p.stdout.read(), p.stderr.read())
        # If a timeout is given, give up on execution after that amount of time.
        for i in range(0,timeout):
            print i
            status = p.poll()
            if status != None:
                return (status, p.stdout.read(), p.stderr.read())
            sleep(1)
        p.kill()
        raise TimeoutException(p.stderr.read())

class MATLABException(Exception):
    def __init__(self, error_string):
        print "MATLAB Error Occurred: " + error_string

class TimeoutException(Exception):
    def __init__(self, error_string):
        print "MATLAB Timeout Occurred: " + error_string

if __name__ == '__main__':
    mlr = MATLABRunner()
    #print mlr.run_matlab("disp('hi')")
    res = mlr.publish_matlab("x=-1:0.1:1;y=sin(x);plot(x,y);");
    print res

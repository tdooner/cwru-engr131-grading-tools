from tempfile import mkdtemp, mkstemp
from time import sleep
import os.path
from os import listdir, remove
import subprocess

NUM_SKIP_LINES = 11
MATLAB_PATH = "/Applications/MATLAB_R2011a.app/bin/matlab"
MATLAB_ARGS = ['-nodesktop', '-nosplash']

class MATLABRunner:
    def __init__(self):
        pass

    def run_matlab(self, matlab_str, path=os.path.abspath(__file__)):
        matlab_str = matlab_str + "; exit;"
        cmd = [MATLAB_PATH] + MATLAB_ARGS + ['-r', matlab_str]
        status, out, err = self.execute_command(cmd, timeout=60, options={'MATLABPATH': path})
        print "Got " + str(len(out.split("\n"))) + " lines on stdout"
        print "Got " + str(len(err.split("\n"))) + " lines on stderr"
        if status == 0:
            actual_output = out.split("\n")[(NUM_SKIP_LINES-1):]
            return "\n".join(actual_output)
        else:
            raise MATLABException(err)
            return out

    def publish_matlab(self, matlab_str):
        tmp_dir = mkdtemp()
        m_file_name = mkstemp(suffix=".m", dir=tmp_dir)[1]
        m_file = open(m_file_name, "w")
        m_file.write(matlab_str)
        m_file.close()
        matlab_str = "publish('" + m_file_name + "')"
        print m_file_name
        print self.run_matlab(matlab_str, path=tmp_dir)
        print listdir(tmp_dir)
        os.remove(m_file_name)

    def execute_command(self, cmd, timeout=0, options={}):
        """
        Run an arbitrary command with an optional timeout (in seconds)
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
    print mlr.publish_matlab("x=-1:0.1:1;y=sin(x);plot(x,y);");

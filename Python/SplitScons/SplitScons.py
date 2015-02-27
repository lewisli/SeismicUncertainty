import sys
import getopt
import string

class Usage(Exception):
    def __init__(self, msg):
        self.msg = msg

def createPBSfile(name,email,nodes,ppn,time,nodetype=None):
    '''
    Where we actually create our pbs job files. Modify this to change this to fit
    your cluster, or changes to Mio and Ra.
    Modified for sw121.         
    '''

    pbs_dirt = 'pbs'

    lines = []
    lines.append('#!/bin/tcsh')
    print 'nodes: ',nodes

    lines.append('#PBS -l nodes=%d:ppn=%d' % (nodes,ppn))
    lines.append('#PBS -e %s/%s.err' % (pbs_dirt,name))
    lines.append('#PBS -o %s/%s.out' % (pbs_dirt,name))
    lines.append('#PBS -l naccesspolicy=singlejob')
    lines.append('#PBS -N %s' % name)
    lines.append('#PBS -j oe')
    lines.append('#PBS -l walltime=%d:00:00' % time)
    lines.append('#PBS -V')
    lines.append('#PBS -q %s' % nodetype)
    lines.append('#PBS -W x="PARTITION:sw121"')
    if email:
        lines.append('#PBS -m a')
        lines.append('#PBS -M %s' % email)
    lines.append('#-----------')
    lines.append('setenv SCONS_OVERRIDE 1')
    lines.append('cd $PBS_O_WORKDIR')
    lines.append('%s -f %s/SConstruct-%s' % ('scons', pbs_dirt,name))
    file = open('%s/%s' % (pbs_dirt,name),'w')
    text = string.join(lines,'\n')
    file.write(text)
    file.close()



def main(argv=None):
    
    if argv is None:
        argv = sys.argv
	InputSConstruct = []
    else:
	InputSConstruct = argv

    createPBSfile('TestJob','lewisli@stanford.edu',1,8,2,nodetype='default')
    print InputSConstruct


if __name__ == "__main__":
    main(sys.argv[1:])

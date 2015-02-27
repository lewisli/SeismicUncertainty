import sys
import getopt
import string

class Usage(Exception):
    def __init__(self, msg):
        self.msg = msg

class SConstructGenerator:
    def __init__(self, par):
        self.par = par
        
        # Compute Shot Parameters
        self.computeShotParameters() 

        # Write first serial section
        self.serialSection1()

        # Write first parallel section
        self.parallelSection1()
 
    def computeShotParameters(self):
        self.par['nmig']=self.par['mignsx']*self.par['mignsy']

        xshot=range(self.par['migosx'],self.par['migosx']+self.par['mignsx']*self.par['migdsx'],self.par['migdsx'])
        yshot=range(self.par['migosy'],self.par['migosy']+self.par['mignsy']*self.par['migdsy'],self.par['migdsy'])


        self.nlist=[]
        self.xlist=[]
        self.ylist=[]

        for isx in range(self.par['mignsx']):
            for isy in range(self.par['mignsy']):
                xline = 9+2*(xshot[isx]-1)
                yline = 9+2*(yshot[isy]-1)

                N=1+20+4*(yline-1)+(20+4*(xline-1))*267
                self.nlist.append(N);

                x=self.par['osx']+(xline-1)*self.par['dsx']
                y=self.par['osy']+(yline-1)*self.par['dsy']            
                
                self.ylist.append(y)
                self.xlist.append(x) 

        self.klist=len(self.nlist);

    def serialSection1(self):
        SerialJobName = self.par['jobname'] + 'Serial1'
        f = open('SConstructSerial1','r')
        serial1=f.read()
        f.close()
        f = open('pbs/SConstruct-'+SerialJobName,'w')
        f.write(serial1)
        f.write('\n')
        f.close()

        self.createPBSfile(SerialJobName,'lewisli@stanford.edu',1,8,2,'default')

    def parallelSection1(self):

        for k in range(2):
            ParallelJobName = self.par['jobname'] + 'Parallel_1_' + str(k)
            f = open('pbs/SConstruct-'+ParallelJobName,'w')

            ktag = '-%06d' % self.nlist[k]
            ktagstr = str(ktag)

            lines = []
            lines.append('from rsf.proj import *')
            lines.append('import dbhash')
            lines.append('proj = Project()')    

            lines.append(
                'Flow([ "data'+ktagstr+ '","head'+ktagstr+'"],None, "segyread tape=/data/groups/scrf/data/Seismic/SHOTS/SOURCE_0' 
                    + str(self.nlist[k]) + '.sgy format=5 tfile=${TARGETS[1]}|'+
                     'put label1=' + str(self.par['lt']) +  ' unit1=' + str(self.par['ut']) + 
                     ' n2=' + str(self.par['nry']) + ' o2=' + str(self.par['ory']) + ' d2=' + str(self.par['dry']) + ' label2=' + str(self.par['lry']) 
                     + ' unit2=' + str(self.par['ury']) +
                     ' n3=' + str(self.par['nrx']) + ' o3=' + str(self.par['orx']) + ' d3=' + str(self.par['drx']) + ' label3=' + str(self.par['lrx']) 
                     + ' unit3=' + str(self.par['urx']) + '|' +
                     ' window n1=' + str(self.par['nt']) + ' j2=' + str(self.par['jy']) + ' j3=' + str(self.par['jx']) + ' | '  
                     ' transp plane=23 |' +
                     ' window f1=250 | pad beg1=250 |' +
                     ' bandpass flo=3 fhi=15")'
               )

            lines.append(
                'Result("dcut'+ktagstr + '","data'+ktagstr + '",' + '"window n3=1 min3=0 | grey title="" pclip=99")')

            text = string.join(lines,'\n')
            f.write(text)
           
            f.close()

            self.createPBSfile(ParallelJobName,'lewisli@stanford.edu',1,8,2,'default')


        
    def createPBSfile(self,name,email,nodes,ppn,time,nodetype=None):
        '''
        Where we actually create our pbs job files. Modify this to change this to fit
        your cluster, or changes to Mio and Ra.
        Modified for sw121.         
        '''

        pbs_dirt = 'pbs'

        lines = []
        lines.append('#!/bin/tcsh')
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
        file.write('\n')
        file.close()


def main(argv=None):
    
    if argv is None:
        argv = sys.argv
        InputSConstruct = []
    else:
    	InputSConstruct = argv
    
    par = dict( nt=2000,   ot=0, dt=0.008, lt='t',   ut='s',
                nx=1167,   ox=0, dx=0.03,  lx='x',   ux='km',
                ny=1333,   oy=0, dy=0.03,  ly='y',   uy='km',
                nz=1501,   oz=0, dz=0.01,  lz='z',   uz='km',
                osx=3.050, dsx=0.6,  lsx='sx', usx='km', # source x
                osy=3.025, dsy=0.6,  lsy='sy', usy='km', # source y
                nrx=661,   drx=0.03, lrx='rx', urx='km', # receiver x
                nry=661,   dry=0.03, lry='ry', ury='km'  # receiver y
        )

    par['orx']=-(par['nrx']-1)/2*par['drx']
    par['ory']=-(par['nry']-1)/2*par['dry']

    par['jx']=1
    par['jy']=1
    par['jz']=2
    par['nzmig']=600

    par['mignsx']=8
    par['migosx']=8
    par['migdsx']=1

    par['mignsy']=8
    par['migosy']=3
    par['migdsy']=1

    par['jobname']= 'SampleTest'
    SGeneratorObj = SConstructGenerator(par)

if __name__ == "__main__":
    main(sys.argv[1:])

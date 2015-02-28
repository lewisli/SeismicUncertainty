import sys
import getopt
import string
import math

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

        # Write split migration section
        self.parallelSection2()

        # Write sum split migration section
        self.serialSection2()

        # Write stack cwn
        self.serialSection3()
 
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

        for k in range(self.par['TestNum']):

            ktag = '-%06d' % self.nlist[k]
            ktagstr = str(ktag)

            ParallelJobName = self.par['jobname'] + ktagstr + '_Base'
            f = open('pbs/SConstruct-'+ParallelJobName,'w')


            lines = []
            lines.append('from rsf.proj import *')
            lines.append('import dbhash')
            lines.append('proj = Project()')    
            lines.append('proj.SConsignFile("' + ParallelJobName + '.sconsign.dbhash", dbhash)')

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

            # Get reciever data in frequency
            lines.append('Flow("rfrq' + ktagstr +'","data'+ ktagstr + '","fft1 inv=n opt=n | window squeeze=n n1=' + str(self.par['nw']) + 
            ' min1=1 j1=2 | transp plane=12 | transp plane=23 | put label1=x label2=y label3=w label4=e o2=' + str(self.par['ory']) + 
            ' d2=' + str(self.par['dry']) + ' unit1=km label1=x unit2=km label2=y")')

            # Tape data in space
            lines.append('Flow("rtap'+ktagstr + '",["rfrq'+ktagstr+'","taper"],' + """ '''pad beg1=""" + str(self.par['nxpad']) + ' n1out=' 
                + str(self.par['nmx']) + ' beg2=' + str(self.par['nypad']) + ' n2out=' + str(self.par['nmy']) 
                + """|math t=${SOURCES[1]} output="input*t" | put o1=""" 
                + str(self.xlist[k]-self.par['hmx']*self.par['drx']*self.par['jx']) + " o2=" 
                + str(self.ylist[k]-self.par['hmy']*self.par['dry']*self.par['jy']) + """ ''') """)

            # Tape data in space
            lines.append('Flow("stap'+ktagstr + '",["sfrq","taper"],' + """ '''pad beg1=""" + str(self.par['nxpad']) + ' n1out=' 
                + str(self.par['nmx']) + ' beg2=' + str(self.par['nypad']) + ' n2out=' + str(self.par['nmy']) 
                + '|math t=${SOURCES[1]} output="input*t" | put o1=' 
                + str(self.xlist[k]-self.par['hmx']*self.par['drx']*self.par['jx']) + ' o2=' 
                + str(self.ylist[k]-self.par['hmy']*self.par['dry']*self.par['jy']) + """ ''') """)

            lines.append('Flow("dfs'+ ktagstr + '",["stap' + ktagstr +'", "slod"], "wei verb=y irun=dtm causal=n slo=${SOURCES[1]} --readwrite=y verb=y nrmax=' 
                + str(self.par['nrmax']) + ' dtmax=5e-05 eps=0.1 tmx=32 tmy=32 causal=n")')
            lines.append('Flow("dfr'+ ktagstr + '",["rtap' + ktagstr +'", "slod"], "wei verb=y irun=dtm causal=n slo=${SOURCES[1]} --readwrite=y verb=y nrmax=' 
                + str(self.par['nrmax']) + ' dtmax=5e-05 eps=0.1 tmx=32 tmy=32 causal=y")')
         
         
            text = string.join(lines,'\n')
            f.write(text)
           
            f.close()

            self.createPBSfile(ParallelJobName,'lewisli@stanford.edu',1,8,0.5,'default')

    def parallelSection2(self):
        for k in range(self.par['TestNum']):
            for s in range(self.par['cigsplit']):
                ktag = '-%06d' % self.nlist[k]
                ktagstr = str(ktag)

                ParallelJobName = self.par['jobname'] + ktagstr + '_cic_' + str(s) 

                f = open('pbs/SConstruct-'+ParallelJobName,'w')


                lines = []
                lines.append('from rsf.proj import *')
                lines.append('import dbhash')
                lines.append('proj = Project()')    
                lines.append('proj.SConsignFile("' + ParallelJobName + '.sconsign.dbhash", dbhash)')

                lines.append('Flow("cic' + ktagstr + '_' + str(s) + '", ["dfs' + ktagstr + '","dfr' + ktagstr + '","slow"], ' + 
                 """ '''weilewis verb=y irun=cic dat=${SOURCES[1]} slo=${SOURCES[2]} splitindex=""" 
                 + str(s) + " cigsplit=" + str(self.par['cigsplit']) 
                 + " --readwrite=y verb=y nrmax=5 dtmax=5e-05 eps=0.1 tmx=32 tmy=32" 
                 + """ ''') """ )

                text = string.join(lines,'\n')
                f.write(text)
           
                f.close()

                self.createPBSfile(ParallelJobName,'lewisli@stanford.edu',1,8,2,'default')

    def serialSection2(self):
        for k in range(self.par['TestNum']):
            ktag = '-%06d' % self.nlist[k]
            ktagstr = str(ktag)
            SerialJobName = self.par['jobname'] + ktagstr + '_cwn'
            f = open('pbs/SConstruct-'+SerialJobName,'w')
            cic_split_list = []

            for s in range(self.par['cigsplit']):
                cic_split_list.append("'cic" + ktagstr + '_' + str(s) + "'")


            text = '[' + string.join(cic_split_list,',') + ']'

            lines = []
            lines.append('from rsf.proj import *')
            lines.append('import dbhash')
            lines.append('proj = Project()')    
            lines.append('proj.SConsignFile("' + SerialJobName + '.sconsign.dbhash", dbhash)')

            lines.append('Flow("cic' + ktagstr + '",' + text + """,'''add scale=1,1 ${SOURCES[1:-1]}''')"""  )
            lines.append('Flow("cwn' + ktagstr + '",["cic' + ktagstr + '", "sxy", "syx"],' +
            """ ''' remap1 pattern=${SOURCES[1]} order=1 |
            transp |
            remap1 pattern=${SOURCES[2]} order=1 |
            transp
            ''')"""  )

            lines.append('Result("ccut' + ktagstr + '",' + '"cwn' + ktagstr + '",' + 
            """ '''  grey
            title=""
            pclip=100 gainpanel=a
            min1=0 max1=15 label1=z unit1=km
            min2=0 max2=34.98 label2=x unit2=km
            screenratio=0.428816 screenht=5.84262 wantscalebar=n
            parallel2=n labelsz=6 labelfat=3 titlesz=12 titlefat=3 pclip=99.9 screenratio=0.375 screenht=5.0 min2=16 max2=32 max1=6
            ''')""")

            outputText = string.join(lines,'\n')
            
            f.write(outputText)
            f.close()

            self.createPBSfile(SerialJobName,'lewisli@stanford.edu',1,1,0.5,'default')

    def serialSection3(self):
        # Peform CIC stack

        SerialJobName = self.par['jobname'] + '_cstk'
        f = open('pbs/SConstruct-'+SerialJobName,'w')
        cstk_list = []
        for k in range(self.par['TestNum']):
            ktag = '-%06d' % self.nlist[k]
            ktagstr = str(ktag)
            cstk_list.append('"cic' + ktagstr + "'")

        text = '[' + string.join(cstk_list,',') + ']'

        lines=[]
        lines.append('from rsf.proj import *')
        lines.append('import dbhash')
        lines.append('proj = Project()')    
        lines.append('proj.SConsignFile("' + SerialJobName + '.sconsign.dbhash", dbhash)')

        lines.append('Flow("cstk",' + text + """,''' cat axis=4 space=n ${SOURCES[1:-1]} |
        transp plane=34 | transp plane=23 | stack ''') """)

        lines.append("""Result("cstk",
        '''transp plane=23 | transp plane=12 | tpow tpow=2 |
        window min1=0 max1=11.98 min2=5 max2=34.94 min3=0 max3=29.94 |
        byte gainpanel=a pclip=99.0 |
        grey3 title="" framelabel=n parallel2=n
        label1=z unit1=km
        label2=x unit2=km
        label3=y unit3=km
        frame1=300 frame2=250 frame3=250
        flat=y screenratio=0.700067 screenht=9.80094 point1=0.285782 point2=0.5
        xll=1.5 yll=1.5
        parallel2=n labelsz=6 labelfat=3 titlesz=12 titlefat=3  frame1=475 frame2=250 frame3=258 parallel2=n format1=%3.0f format2=%3.0f format3=%3.0f
        ''')""")

        lines.append("""Result("ccut","cstk",
        '''window n2=1 min2=15.5 | transp |
        grey
        title=""
        pclip=100 gainpanel=a
        min1=0 max1=15 label1=z unit1=km
        min2=0 max2=34.98 label2=x unit2=km
        screenratio=0.428816 screenht=5.84262 wantscalebar=n
         parallel2=n labelsz=6 labelfat=3 titlesz=12 titlefat=3 pclip=99.0 screenratio=0.375 screenht=5.0 min2=16 max2=32 max1=6
        ''')"""
        )

        for k in range(self.par['TestNum']):
            ktag = '-%06d' % self.nlist[k]
            ktagstr = str(ktag)
            kstr = str(k)

            lines.append("Result('cwn"+ktagstr + '","cwn-byt",' + 
            """ ''' window n4=1 f4 =""" + kstr +  """| transp plane=23 | transp plane=12 |
            window min1=0 max1=11.98 min2=5 max2=34.94 min3=0 max3=29.94 |

            grey3 title="" framelabel=n parallel2=n
            label1=z unit1=km
            label2=x unit2=km
            label3=y unit3=km
            frame1=300 frame2=250 frame3=250
            flat=y screenratio=0.700067 screenht=9.80094 point1=0.285782 point2=0.5
            xll=1.5 yll=1.5
             parallel2=n labelsz=6 labelfat=3 titlesz=12 titlefat=3  frame1=475 frame2=250 frame3=258 parallel2=n format1=%3.0f format2=%3.0f format3=%3.0f
            ''')""")

        outputText = string.join(lines,'\n')
           
        f.write(outputText)
        f.close()

        self.createPBSfile(SerialJobName,'lewisli@stanford.edu',1,1,1.5,'default')

       
    def createPBSfile(self,name,email,nodes,ppn,time,nodetype=None):
        '''
        Where we actually create our pbs job files. Modify this to change this to fit
        your cluster, or changes to Mio and Ra.
        Modified for sw121.         
        '''

        # Allow for sub hour timing
        hours = int(math.floor(time))
        minPercent = time-hours
        minutes = int(round(minPercent*60))

        pbs_dirt = 'pbs'

        lines = []
        lines.append('#!/bin/tcsh')
        lines.append('#PBS -l nodes=%d:ppn=%d' % (nodes,ppn))
        lines.append('#PBS -e %s/%s.err' % (pbs_dirt,name))
        lines.append('#PBS -o %s/%s.out' % (pbs_dirt,name))
        lines.append('#PBS -l naccesspolicy=singlejob')
        lines.append('#PBS -N %s' % name)
        lines.append('#PBS -j oe')
        lines.append('#PBS -l walltime=%d:%d:00' % (hours,minutes))
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

    par['nypad']=70/par['jy']
    par['nxpad']=70/par['jx']
    par['hmx']=((par['nry']-1)/2/par['jy']+par['nypad'])
    par['hmy']=((par['nry']-1)/2/par['jy']+par['nypad'])
    par['nmx']=par['hmx']*2
    par['nmy']=par['hmy']*2


    par['mignsx']=8
    par['migosx']=8
    par['migdsx']=1

    par['mignsy']=8
    par['migosy']=3
    par['migdsy']=1

    # migration parameters
    par['nw']=160
    par['ow']=1
    par['jw']=2

    par['nrmax']=5
    par['tmx']=32
    par['tmy']=32
    par['verb']='y'

    par['nypad']=70/par['jy']
    par['nxpad']=70/par['jx']


    par['jobname'] = 'SampleTest'
    par['cigsplit'] = 4

    # For testing how many shots to run
    par['TestNum'] = 1

    SGeneratorObj = SConstructGenerator(par)

if __name__ == "__main__":
    main(sys.argv[1:])

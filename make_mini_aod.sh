input_file=$1
n_events_pileup=$2
n_events=$3
where_to_start=$4
lumi_number=$5
output_dir=$6
hadron_fragment=$7

echo date
date

echo pwd
pwd

echo \$input_file
echo $input_file

echo \$n_events_pileup
echo $n_events_pileup

echo \$n_events
echo $n_events

echo \$output_dir
echo $output_dir

echo \$where_to_start
echo $where_to_start

echo \$lumi_number
echo $lumi_number

echo \$hadron_fragment
echo $hadron_fragment

cd /afs/cern.ch/work/a/anlevin/mc_production/CMSSW_6_2_0_patch1/src/;
eval `scramv1 runtime -sh`;
cd -; 

echo "begin step 1"

cmsDriver.py step1 --filein file:$input_file --mc --eventcontent LHE --datatier GEN --conditions START62_V1::All --step NONE --python_filename step1.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n $n_events --customise_commands process.source.skipEvents\ =\ cms.untracked.uint32\($where_to_start\)\\nprocess.source.firstLuminosityBlock\ =\ cms.untracked.uint32\($lumi_number\) --fileout file:step1_output.root

cmsRun step1.py

echo "end step 1"

echo "ls -lh"
ls -lh

cmsDriver.py Configuration/GenProduction/python/ThirteenTeV/MinBias_13TeV_pythia8_cfi.py --mc --eventcontent RAWSIM --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1 --datatier GEN-SIM --conditions POSTLS162_V1::All --step GEN,SIM --magField 38T_PostLS1 --geometry Extended2015 --python_filename minbias.py --no_exec -n $n_events_pileup --customise Configuration/GenProduction/randomizeSeeds.randomizeSeeds --fileout file:pileup.root

cmsRun minbias.py

cd /afs/cern.ch/work/a/anlevin/mc_production/CMSSW_6_2_4/src;
eval `scramv1 runtime -sh`;
cd -;

echo "begin step 2"

cmsDriver.py $hadron_fragment --filein file:step1_output.root --fileout file:step2_output.root --mc --eventcontent RAWSIM --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --conditions POSTLS162_V1::All --step GEN,SIM --magField 38T_PostLS1 --geometry Extended2015 --python_filename step2.py --no_exec -n -1 --customise Configuration/GenProduction/randomizeSeeds.randomizeSeeds

cmsRun step2.py

echo "end step 2"

echo "ls -lh"
ls -lh

cd /afs/cern.ch/work/a/anlevin/mc_production/CMSSW_7_2_0/src/
eval `scramv1 runtime -sh`;
cd -;

echo "begin step 3"

cmsDriver.py step1 --filein file:step2_output.root --fileout file:step3_output.root --pileup_input file:pileup.root --mc --eventcontent RAWSIM --inputEventContent REGEN --pileup Phys14_50ns_PoissonOOT --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --conditions PHYS14_25_V1 --step GEN:fixGenInfo,DIGI,L1,DIGI2RAW,HLT:GRun --magField 38T_PostLS1 --python_filename step3.py --no_exec -n -1

#cmsDriver.py step3 --filein file:step2_output.root --fileout file:step3_output.root --pileup_input file:pileup.root --mc --eventcontent RAWSIM --pileup AVE_20_BX_25ns --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --conditions POSTLS170_V5::All --step DIGI,L1,DIGI2RAW,HLT:2013,RAW2DIGI,L1Reco --magField 38T_PostLS1 --geometry DBExtendedPostLS1 --python_filename step3.py --no_exec -n -1 --customise Configuration/GenProduction/randomizeSeeds.randomizeSeeds

cmsRun step3.py

echo "end step 3"


echo "ls -lh"
ls -lh

echo "begin step 4"

cmsDriver.py step4 --filein file:step3_output.root --fileout file:step4_output.root --mc --eventcontent AODSIM --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --conditions PHYS14_25_V1 --step RAW2DIGI,L1Reco,RECO,EI --magField 38T_PostLS1 --python_filename step4.py --no_exec -n -1

#cmsDriver.py --filein file:step3_output.root --fileout file:step4_output.root --mc --eventcontent AODSIM --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --conditions POSTLS170_V5::All --step RAW2DIGI,L1Reco,RECO,EI --magField 38T_PostLS1 --geometry DBExtendedPostLS1 --python_filename step4.py --no_exec -n -1 --customise Configuration/GenProduction/randomizeSeeds.randomizeSeeds

cmsRun step4.py

echo "end step 4"

echo "ls -lh"
ls -lh

#cd /afs/cern.ch/work/a/anlevin/mc_production/CMSSW_7_0_6_patch1/src/;
#eval `scramv1 runtime -sh`;
#cd -;

echo "begin step 5"

cmsDriver.py step3 --filein file:step4_output.root --fileout file:step5_output.root --mc --eventcontent MINIAODSIM --runUnscheduled --datatier MINIAODSIM --conditions PHYS14_25_V1 --step PAT --python_filename step5.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n -1

#cmsDriver.py step5 --filein file:step4_output.root --fileout file:step5_output.root --mc --eventcontent MINIAODSIM --runUnscheduled --datatier MINIAODSIM --conditions PLS170_V7AN1::All --step PAT --python_filename step5.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n -1 --customise Configuration/GenProduction/randomizeSeeds.randomizeSeeds

cmsRun step5.py

echo "end step 5"

echo "ls -lh"
ls -lh

echo "dumping configuration files"
echo ""

for file in `ls | grep "\.py" | grep -v pyc`; do echo "begin dumping file $file"; echo "";  cat $file; echo ""; echo "finished dumping file $file"; done

if ! cat *py | grep  Pythia6HadronizerFilter >& /dev/null; then
    echo "no hadronizer in the configuration files, exiting"
    exit
fi

/afs/cern.ch/project/eos/installation/0.3.84-aquamarine/bin/eos.select cp step5_output.root ${output_dir}step5_output_$where_to_start.root

echo date
date

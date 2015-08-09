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

cd /afs/cern.ch/work/a/anlevin/mc_production/CMSSW_7_1_15_patch1/src/
eval `scramv1 runtime -sh`;
cd -; 

echo "begin step 1"

cmsDriver.py $hadron_fragment --fileout file:step1_output.root --mc --eventcontent RAWSIM --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --inputCommands 'keep *','drop LHEXMLStringProduct_*_*_*' --conditions MCRUN2_71_V1::All --beamspot NominalCollision2015 --step GEN,SIM --magField 38T_PostLS1 --filein file:$input_file -n $n_events --customise_commands process.source.skipEvents\ =\ cms.untracked.uint32\($where_to_start\)\\nprocess.source.firstLuminosityBlock\ =\ cms.untracked.uint32\($lumi_number\);

echo "finished step 1"

cd /afs/cern.ch/work/a/anlevin/mc_production/CMSSW_7_1_13/src/
eval `scramv1 runtime -sh`;
cd -; 

echo "begin pileup step"

cmsDriver.py Configuration/GenProduction/python/FSQ-RunIIWinter15GS-00001-fragment.py --fileout file:pileup.root --mc --eventcontent RAWSIM --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --conditions MCRUN2_71_V1::All --beamspot NominalCollision2015 --step GEN,SIM --magField 38T_PostLS1 -n $n_events_pileup --customise Configuration/GenProduction/randomizeSeeds.randomizeSeeds

echo "end pileup step"

cd /afs/cern.ch/work/a/anlevin/mc_production/CMSSW_7_4_1_patch1/src/
eval `scramv1 runtime -sh`;
cd -; 

echo "begin step 2"

cmsDriver.py step2 --filein file:step1_output.root --fileout file:step2_output.root --pileup_input file:pileup.root --mc --eventcontent RAWSIM --pileup 2015_25ns_Startup_PoissonOOTPU --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --conditions MCRUN2_74_V9 --step DIGI,L1,DIGI2RAW,HLT:@frozen25ns --magField 38T_PostLS1 -n -1

echo "finished step 2"

echo "begin step 3"

cmsDriver.py step3 --filein file:step2_output.root --fileout file:step3_output.root --mc --eventcontent AODSIM,DQM --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM,DQMIO --conditions MCRUN2_74_V9 --step RAW2DIGI,L1Reco,RECO,EI,DQM:DQMOfflinePOGMC --magField 38T_PostLS1 -n -1 

echo "finished step 3"

echo "begin step 4"

cmsDriver.py step4 --filein file:step3_output.root --fileout file:step4_output.root --mc --eventcontent MINIAODSIM --runUnscheduled --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --conditions MCRUN2_74_V9 --step PAT -n -1

echo "finished step 4"

/afs/cern.ch/project/eos/installation/0.3.84-aquamarine/bin/eos.select cp step4_output.root ${output_dir}step4_output_$where_to_start.root

echo date
date

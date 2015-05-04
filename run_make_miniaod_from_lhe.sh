input_file=/afs/cern.ch/work/a/anlevin/data/lhe/13_tev/wpwpjj_qed_4_qcd_0_v3.lhe
output_dir=/eos/cms/store/user/anlevin/data/MINIAOD/wpwp_v3/
echo \$input_file
echo $input_file

echo \$output_dir
echo $output_dir

#hadron_fragment=Configuration/GenProduction/python/FourteenTeV/hadronizer_no_matching.py
#hadron_fragment=Configuration/GenProduction/python/EightTeV/Hadronizer_TuneZ2star_8TeV_generic_LHE_pythia_tauola_cff.py
hadron_fragment=Configuration/GenProduction/python/ThirteenTeV/Hadronizer_TuneZ2star_13TeV_generic_LHE_pythia_tauola_cff.py
echo \$hadron_fragment
echo $hadron_fragment

nevents=`cat $input_file  | grep "<event>" | wc -l`

echo \$nevents
echo $nevents

if((nevents==0));
    then
    echo "no events in lhe file, exiting";
    exit;
fi

if ! /afs/cern.ch/project/eos/installation/0.3.84-aquamarine/bin/eos.select ls $output_dir >& /dev/null
    then
    echo "output directory does not exist, exiting"
    exit
fi

outputdirsize=`/afs/cern.ch/project/eos/installation/0.3.84-aquamarine/bin/eos.select ls $output_dir | wc -l`

if((outputdirsize!=0))
    then
    echo "output directory is not empty, exiting"
    exit
fi


max_events=20000
where_to_start=1

if((nevents<max_events))
    then
    echo "nevents < maxevents, exiting"
    exit
fi

sleep 15

while((where_to_start<=max_events)); do
    echo $where_to_start
    bsub -q 1nd "bash make_mini_aod.sh $input_file 300 100 $where_to_start $where_to_start $output_dir $hadron_fragment"
    where_to_start=$(($where_to_start+100))
done

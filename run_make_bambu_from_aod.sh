input_dir=/store/user/anlevin/data/AOD/wpwp_14_tev_qed_4_qcd_0_no_higgs_long_madspin_v3/
output_dir=/eos/cms/store/user/anlevin/data/BAMBU/14_tev/wpwp_14_tev_qed_4_qcd_0_no_higgs_long_madspin_v3/

echo \$input_dir
echo $input_dir

echo \$output_dir
echo $output_dir

if echo $input_dir | grep "/eos/cms/" >& /dev/null
    then 
    echo "input dir should start with /store/user/, exiting"
    exit
fi

if ! /afs/cern.ch/project/eos/installation/0.3.15/bin/eos.select ls $output_dir >& /dev/null
    then
    echo "output directory does not exist, exiting"
    exit
fi

outputdirsize=`/afs/cern.ch/project/eos/installation/0.3.15/bin/eos.select ls $output_dir | wc -l`

if((outputdirsize!=0))
    then
    echo "output directory is not empty, exiting"
    exit
fi

sleep 15

for file in `/afs/cern.ch/project/eos/installation/0.3.15/bin/eos.select ls $input_dir`
  do
  bsub -q 8nh "bash make_bambu_from_aod.sh $input_dir/$file $output_dir"
done

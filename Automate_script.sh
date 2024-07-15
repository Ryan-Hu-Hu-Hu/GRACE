#!/bin/bash
echo '####################Translational Module Start#################### '
eval "$(conda shell.bash hook)"
export PATH=$PATH:/home/ncku2/Programs/hh-suite/build/bin
export PATH=$PATH:/home/ncku2/Programs/CCMpred/bin
export PATH=$PATH:/home/ncku2/Programs/usearch
export PATH=$PATH:/home/ncku2/Programs/TMHMM/bin
#echo $PATH

conda activate SE3nv
DIRECTORY=$(pwd)

if [ ! -d "$DIRECTORY/data/RFdiffusion_result" ]; then 
	mkdir -p "$DIRECTORY/data/RFdiffusion_result" 
fi

if [ ! -d "$DIRECTORY/data/ProteinMPNN_result" ]; then 
	mkdir -p "$DIRECTORY/data/ProteinMPNN_result"
fi

if [ ! -d "$DIRECTORY/data/CLEAN_result" ]; then 
	mkdir -p "$DIRECTORY/data/CLEAN_result"
fi

if [ ! -d "$DIRECTORY/data/solubility_result" ]; then 
	mkdir -p "$DIRECTORY/data/solubility_result"
fi

if [ ! -d "$DIRECTORY/data/finalresult" ]; then 
	mkdir -p "$DIRECTORY/data/finalresult"
fi

rm -r $DIRECTORY/data/RFdiffusion_result/*
rm -r $DIRECTORY/data/ProteinMPNN_result/*
rm -r $DIRECTORY/data/solubility_result/*
rm -r $DIRECTORY/helper_scripts/seqs/*
rm -r $DIRECTORY/helper_scripts/seq_result/*

echo 'conda env SE3nv activated.'
echo '###############RFdiffusion backbone generation###############'
########Add arguments here############

RFdiffusionPath=$(find $HOME -type d -name RFdiffusion)

$RFdiffusionPath/scripts/run_inference.py 'contigmap.contigs=[1-10/A5-7/1-20/A57-58/1-3/A60-73/5-20/A89-99/1-20/A104-108/1-20/A113-123/1-10/A130-135/1-10/A141-148/1-20/A170-173/1-10/A187-188/1-10/A197-207/1-5/A209-212/1-20/A240-246/1-20]'  inference.output_prefix=$DIRECTORY/data/RFdiffusion_result/dCA inference.num_designs=10 inference.input_pdb=$RFdiffusionPath/PDB/1heb.pdb inference.ckpt_override_path=$RFdiffusionPath/models/ActiveSite_ckpt.pt

conda deactivate
echo 'conda env SE3nv deactivated'

#############Run Datatype transformation script here###################
rm $DIRECTORY/helper_scripts/Fixed_positions.txt
python $DIRECTORY/helper_scripts/Activesite_position_calculator.py
#######################################################################

conda activate mlfold
echo 'conda env mlfold activated.'
echo '####################ProteinMPNN sequence reverse generation####################'
########Add arguments here############
ProteinMPNNPath=$(find $HOME -type d -name ProteinMPNN)

python $ProteinMPNNPath/helper_scripts/parse_multiple_chains.py --input_path $DIRECTORY/data/RFdiffusion_result/ --output_path $DIRECTORY/data/ProteinMPNN_result/dCA.jsonl

python $ProteinMPNNPath/helper_scripts/assign_fixed_chains.py --input_path $DIRECTORY/data/ProteinMPNN_result/dCA.jsonl --output_path $DIRECTORY/data/ProteinMPNN_result/dCA_assigned.jsonl --chain_list "A"

python $ProteinMPNNPath/helper_scripts/make_fixed_positions_dict.py --position_list "1" --chain_list "A" --input_path $DIRECTORY/data/ProteinMPNN_result/dCA.jsonl --output_path $DIRECTORY/data/ProteinMPNN_result/dCA_fixed_pos.jsonl

#############Run Datatype transformation script here###################
python $DIRECTORY/helper_scripts/Fixposition_replacer.py
#######################################################################

python  $ProteinMPNNPath/protein_mpnn_run.py --jsonl_path  $DIRECTORY/data/ProteinMPNN_result/dCA.jsonl --chain_id_jsonl  $DIRECTORY/data/ProteinMPNN_result/dCA_assigned.jsonl --fixed_positions_jsonl  $DIRECTORY/data/ProteinMPNN_result/updated_dCA_fixed_pos.jsonl --out_folder $DIRECTORY/data/ProteinMPNN_result/ --num_seq_per_target 10 --sampling_temp "1.2" --seed 0 --batch_size 1 --save_score 0 --save_probs 0

conda deactivate
echo 'conda env mlfold deactivated'

cp -r  $DIRECTORY/data/ProteinMPNN_result/seqs/ $DIRECTORY/helper_scripts/

#############Run Datatype transformation script here###################
python $DIRECTORY/helper_scripts/ProteinMPNN_to_CLEAN_datatransform.py
#######################################################################


conda activate clean
echo 'conda env clean activated.'
echo '####################CLEAN screening####################'
########Add arguments here############

CLEANPath=$(find $HOME -type d -name CLEAN-main)
cd $CLEANPath/app/
cp $DIRECTORY/helper_scripts/seq_result/dCA.csv ./data/
cp $DIRECTORY/helper_scripts/CLEAN_execute.py .
python  ./CLEAN_execute.py
cp $CLEANPath/app/results/dCA_maxsep.csv $DIRECTORY/data/CLEAN_result/
cp $CLEANPath/app/data/dCA.fasta  $DIRECTORY/data/solubility_result
cd $DIRECTORY

conda deactivate
echo 'conda env clean deactivated'


conda activate soluprot
echo 'conda env soluport activated.'
echo '####################SoDoPe solubility screening####################'
########Add arguments here############

SoDoPePath=$(find $HOME -type d -name SoDoPe)
cd $DIRECTORY/data/solubility_result/
python3 $SoDoPePath/swi.py -f "./dCA.fasta"

conda deactivate
echo 'conda env soluprot deactivated'


conda activate soluprot
echo 'conda env soluprot activated.'
echo '####################SoluPort solubility screening####################'
########Add arguments here############

SoluProtPath=$(find $HOME -type d -name SoluProt)
python $SoluProtPath/soluprot-1.0.1.0/soluprot.py --i_fa ./dCA.fasta --o_csv ./SoluPort_predicted.csv --tmp_dir ./soluprot_tmp --usearch $HOME/Programs/usearch/usearch11.0.667_i86linux32 --tmhmm $HOME/Programs/TMHMM/bin/tmhmm --model $SoluProtPath/soluprot-1.0.1.0/data/grad_clf_v1_tc.pkl

conda deactivate
echo 'conda env soluprot deactivated'

conda activate netsolp
echo 'conda env NetSolP activated.'
echo '####################NetSolP solubility screening####################'
########Add arguments here############

NetsolPPath=$(find $HOME -type d -name NetsolP)
python $NetsolPPath/predict.py --FASTA_PATH ./dCA.fasta --OUTPUT_PATH ./NetSolP_predicted.csv --MODELS_PATH $NetsolPPath/models --MODEL_TYPE ESM1b --PREDICTION_TYPE S

conda deactivate
echo 'conda env NetSolP deactivated'
cd $DIRECTORY
#############Run Datatype transformation script here###################
rm -r $DIRECTORY/helper_scripts/SPOT_Contact_inputs/*
python $DIRECTORY/helper_scripts/SPOT_Contact_input_preprocess.py
#######################################################################


conda activate py2.7
echo 'conda env py2.7 activated.'
echo '####################GraphSol solubility screening####################'
########Add arguments here############
SPOTContactPath=$(find $HOME -type d -name 'SPOT\-Contact_local')
cd $SPOTContactPath/SPOT\-Contact\-Helical\-New
cd $SPOTContactPath

#rm -r  $SPOTContactPath/SPOT\-Contact\-Helical\-New/inputs/*
#rm -r  $SPOTContactPath/SPOT\-Contact\-Helical\-New/outputs/*
cp $DIRECTORY/helper_scripts/SPOT_Contact_inputs/dCA* $SPOTContactPath/SPOT\-Contact\-Helical\-New/inputs/

cd $SPOTContactPath/SPOT\-Contact\-Helical\-New/
./run_spotcontacthelical_dCA.sh

conda deactivate
echo 'conda env py2.7 deactivated'


conda activate GraphSol
echo 'conda env GraphSol activated.'
########Add arguments here############
#GraphSolPath=$(find $HOME -type d -name 'GraphSol')
GraphSolPath=$HOME/Programs/GraphSol
PPSolPath=$HOEM/Programs/PPSol
cd $DIRECTORY
python $DIRECTORY/helper_scripts/GraphSol_preprocess.py
#cd $GraphSolPath/Predict/Data/
cd $PPSolPath/Predict/Data/
#rm -r ./source/*
#rm -r ./upload/*
#cd $GraphSolPath/Predict
cd $PPSolPath/Predict
#cp $DIRECTORY/helper_scripts/SPOT_Contact_inputs/input.fasta $GraphSolPath/Predict/Data/upload/
#cp $SPOTContactPath/SPOT\-Contact\-Helical\-New/inputs/* $GraphSolPath/Predict/Data/source
#cp $SPOTContactPath/SPOT\-Contact\-Helical\-New/outputs/* $GraphSolPath/Predict/Data/source
cp $DIRECTORY/helper_scripts/SPOT_Contact_inputs/dCA.fasta $PPSolPath/Predict/Data/upload/
cp $SPOTContactPath/SPOT\-Contact\-Helical\-New/inputs/dCA* $PPSolPath/Predict/Data/source
cp $SPOTContactPath/SPOT\-Contact\-Helical\-New/outputs/dCA* $PPSolPath/Predict/Data/source
python predict_dCA.py

#mv $GraphSolPath/Predict/Result/result.csv $GraphSolPath/Predict/Result/GraphSol_predict.csv
#mv  $GraphSolPath/Predict/Result/GraphSol_predict.csv $DIRECTORY/data/solubility_result/
mv $PPSolPath/Predict/Result/dCA_result.csv $GraphSolPath/Predict/Result/PPSol_dCA_predict.csv
mv  $PPSolPath/Predict/Result/PPSol_predict.csv $DIRECTORY/data/solubility_result/
conda deactivate
echo 'conda env GraphSol deactivate'
echo '####################Translational Module Finished####################'

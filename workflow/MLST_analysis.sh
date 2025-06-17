#!/bin/bash

# MLST_analysis.sh
# genotyping of BTB genomes through Multi-Locus Sequence Typing (MLST) and core genome MLST.

set -e # exit if a command fails
set -u  # Flag unset variables as errors

# ==== Create Output Directory for Results ====
HOME=$(pwd)
ENV_NAME_seqtyping="seqtyping"
ENV_NAME_chewie="chewie"
OUTPUT_RESULTS="./results"
SAMPLE_CONTIGS=$OUTPUT_RESULTS/"Skesa_contigs"
MLST_DIR=$OUTPUT_RESULTS/"MLST_cgMLST"
cgMLST_DIR=$MLST_DIR/"cgMLST_results"
THREADS=8

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Create Output Directory for Results ====
mkdir -p "$cgMLST_DIR"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_seqtyping"

# ==== Process assembly files ====
echo "STEP 8a: MLST genotyping using pubMLST database"

# ==== Run MLST on assemblies ====
cd $SAMPLE_CONTIGS
mlst --csv *.clean.assembly.fasta > BTB_ssemblies_mlst.csv;
mlst --nopath *.clean.assembly.fasta > BTB_assemblies_mlst.txt;

mv *_mlst.txt $HOME/$MLST_DIR
mv *_mlst.csv $HOME/$MLST_DIR
cd $HOME

echo "MLST sequence typing complete. Results in $MLST_DIR"

# ==== Deactivate conda environment ====
conda deactivate

# ==== Activate conda environment ====
conda activate "$ENV_NAME_chewie"

# ==== Process assembly files ====
echo "STEP 8b: cgMLST genotyping using Chewbacca"

# ==== Run cgMLST on assemblies ====
mkdir -p $cgMLST_DIR/BTB_genomes
cp $SAMPLE_CONTIGS/*.fasta $cgMLST_DIR/BTB_genomes

cd $cgMLST_DIR
chewBBACA.py CreateSchema -i BTB_genomes/ -o MTB_alleles --n MTB_schema --cpu 8
chewBBACA.py AlleleCall -i BTB_genomes/ -g MTB_alleles/MTB_schema/ -o MTB_cgmlst --cpu 8
chewBBACA.py SchemaEvaluator -g MTB_alleles/MTB_schema/ -o MTB_cgmlst_report/ --cpu 8 --loci-reports
chewBBACA.py AlleleCallEvaluator -i MTB_cgmlst -g MTB_alleles/MTB_schema/ -o MTB_Int_reports --cpu 8
chewBBACA.py ExtractCgMLST -i MTB_cgmlst/results_alleles.tsv -o MTB_cgmlst_loci

cd $HOME
echo "cgMLST sequence typing complete. Results in $cgMLST_DIR"

# ==== Deactivate conda environment ====
conda deactivate
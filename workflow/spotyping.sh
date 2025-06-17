#!/bin/bash

# spotyping.sh
# in-sillico spoligotyping using fastq.gz file

set -e # exit if a command fails
#set -u  # Flag unset variables as errors

# ==== Create Output Directory for Results ====
HOME=$(pwd)
ENV_NAME_spotype="spotype"
INPUT_DIR="./demo"
OUTPUT_RESULTS="./results"
REF="./reference"
SPOLIGO_DIR=$OUTPUT_RESULTS/"spoligotyping"
THREADS=8

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Create Output Directory for Results ====
mkdir  -p "$SPOLIGO_DIR"

# ==== Run Spotyping ====
echo "STEP 1d: Spoligotyping"

conda activate "$ENV_NAME_spotype"

for sample in $(ls $INPUT_DIR/*_1.fastq.gz | rev | cut -c 12- | rev | uniq); do
 SpoTyping.py ${sample}_1.fastq.gz ${sample}_2.fastq.gz -o $SPOLIGO_DIR/${sample##*/}.spo.out;
 mv *.xls $SPOLIGO_DIR/
done

# ==== combine all spoligo results into one file ====
cat $SPOLIGO_DIR/*.spo.out > $OUTPUT_RESULTS/spoligo_results.spo.out

# ==== Merge SB numbers with Spoligo pattern ====
join -j 2 -o 1.1,1.2,2.1 <(sort -k2 $OUTPUT_RESULTS/spoligo_results.spo.out) <(sort -k2 $REF/Mbovis.org-database_23042025.txt) > $OUTPUT_RESULTS/all.samples.Mbovis.SBs.txt

echo "STEP 1d: Spoligotyping complete. Results in $SPOLIGO_DIR"

# ==== Deactivate conda environment ====
conda deactivate

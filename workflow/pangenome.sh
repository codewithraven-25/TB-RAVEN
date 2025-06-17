#!/bin/bash

# pangenome.sh
# Predict pangenome profiles of BTB genomes

set -e # exit if a command fails
set -u  # Flag unset variables as errors

# ==== Create Output Directory for Results ====
HOME=$(pwd)
ENV_NAME_panaroo="Panaroo"
OUTPUT_RESULTS="./results"
TRIMMED_DIR="./Trimmed_Reads"
SAMPLE_CONTIGS=$OUTPUT_RESULTS/"Skesa_contigs"
ANNOTATION_DIR=$OUTPUT_RESULTS/"Annotation"
Pangenome_DIR=$OUTPUT_RESULTS/"Pangenome"
THREADS=8

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Create Output Directory for Results ====
mkdir -p "$Pangenome_DIR"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_panaroo"

# ==== Process assembly files ====
echo "STEP 10: Pangenome analysis"

# ==== Copy all .gff files to Pangenome Directory ====
for SAMPLE in "$SAMPLE_CONTIGS"/*.clean.assembly.fasta; do
 BASENAME=$(basename "$SAMPLE" .clean.assembly.fasta)
 cp $ANNOTATION_DIR/${BASENAME}_prokka/${BASENAME}.gff $HOME/$Pangenome_DIR;
done

# ==== Run Panaroo ====
cd $Pangenome_DIR
panaroo -i *.gff -o panaroo_results --clean-mode moderate --alignment core --core_threshold 1.00 --remove-invalid-genes --core_entropy_filter 0.5 --aligner mafft

cd $HOME

echo "Pangenome analysis complete. Results in $Pangenome_DIR"

# ==== Deactivate conda environment ====
conda deactivate
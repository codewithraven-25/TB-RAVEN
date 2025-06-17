#!/bin/bash

# gene_annotation.sh
# annotate BTB genomes

set -e # exit if a command fails
set -u  # Flag unset variables as errors

# ==== Create Output Directory for Results ====
HOME=$(pwd)
ENV_NAME_prokka="prokka_env"
OUTPUT_RESULTS="./results"
SAMPLE_CONTIGS=$OUTPUT_RESULTS/"Skesa_contigs"
ANNOTATION_DIR=$OUTPUT_RESULTS/"Annotation"
THREADS=8

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Create Output Directory for Results ====
mkdir -p "$ANNOTATION_DIR"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_prokka"

# ==== Process FASTQ files ====
echo "STEP 9: Gene annotation using Prokka for bacterial genomes"

# ==== Run Prokka on assemblies ====
for SAMPLE in "$SAMPLE_CONTIGS"/*.clean.assembly.fasta; do
 BASENAME=$(basename "$SAMPLE" .clean.assembly.fasta)
 prokka ${SAMPLE} --outdir $ANNOTATION_DIR/${BASENAME}_prokka --prefix ${BASENAME} -genus Mycobacterium --species bovis --addgenes --rfam --kingdom Bacteria --norrna --notrna --metagenome;
done

echo "Gene annotation complete. Results in $ANNOTATION_DIR"

# ==== Deactivate conda environment ====
conda deactivate

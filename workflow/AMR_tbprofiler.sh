#!/bin/bash

# AMR_tbprofiler.sh
# Predict antimicrobial resistance related to BTB genomes

set -e # exit if a command fails
set -u  # Flag unset variables as errors

# ==== Create Output Directory for Results ====
HOME=$(pwd)
ENV_NAME_tbprofiler="TB_profiler"
OUTPUT_RESULTS="./results"
TRIMMED_DIR="./Trimmed_Reads"
SAMPLE_CONTIGS=$OUTPUT_RESULTS/"Skesa_contigs"
REF="./reference"
AMR_RESULTS_ctgs=$OUTPUT_RESULTS/"Tbprofiler_amr_ctgs"
AMR_RESULTS_reads="./Tbprofiler_amr_reads"
THREADS=8

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Create Output Directory for Results ====
mkdir -p "$AMR_RESULTS_ctgs" "$AMR_RESULTS_reads"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_tbprofiler"

# ==== Process assembly files ====
echo "STEP 7: Detecting AMR in Mycobacterium bovis genomes"

# ==== Run TB-Profiler using assemblies ====
cp "$SAMPLE_CONTIGS"/*.fasta $AMR_RESULTS_ctgs
cd $AMR_RESULTS_ctgs
for SAMPLE in *.clean.assembly.fasta; do
 BASENAME=$(basename "$SAMPLE" .clean.assembly.fasta)
 tb-profiler profile --fasta ${SAMPLE} -p ${BASENAME} --threads 8 --txt;
done

rm *.fasta
cd $HOME

# ==== Run TB-Profiler using short-reads ====
cd $TRIMMED_DIR
for R1 in *_trim.R1.fastq.gz; do
  # derive sample name
  R2="${R1/_trim.R1.fastq.gz/_trim.R2.fastq.gz}"
  #[[ -f "$R2"]] || { echo "Missing R2 for $R1"; continue; }
  
  # Extract sample name
  BASENAME=$(basename "$R1" | sed 's/_trim.R1\.fastq\.gz//')
 tb-profiler profile -1 $R1 -2 $R2 -p ${BASENAME} --no-trim --threads 8 --txt;
done

cd $HOME

mv $TRIMMED_DIR/vcf $AMR_RESULTS_reads --force
mv $TRIMMED_DIR/bam $AMR_RESULTS_reads --force
mv $TRIMMED_DIR/results $AMR_RESULTS_reads --force
mv $AMR_RESULTS_reads $OUTPUT_RESULTS

echo "TB-Profiler AMR analysis complete. Results in $AMR_RESULTS_ctgs"

# ==== Deactivate conda environment ====
conda deactivate
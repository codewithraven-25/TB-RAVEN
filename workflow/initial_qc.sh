#!/bin/bash

# Initial_qc.sh
# Count the number of reads in a fastq.gz  file and write it to a text file
# Run fastqc on fastqc files inside a conda environment
# Run multiqc to summarise fastqc results inside a conda environment

set -e # exit if a command fails
#set -u  # Flag unset variables as errors

HOME=$(pwd)
ENV_NAME_qc="qc"
ENV_NAME_multiqc="multiqc"
ENV_NAME_spotype="spotype"
INPUT_DIR="./demo"
RAW_READCOUNT_FILE="raw_read_count.txt"
OUTPUT_RESULTS="./results"
REF="./reference"
FASTQC_RAW_DIR=$OUTPUT_RESULTS/"fastqc_raw_results"
SPOLIGO_DIR=$OUTPUT_RESULTS/"spoligotyping"
THREADS=8

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Create Output Directory for Results ====
mkdir -p "$OUTPUT_RESULTS"

# ==== Create the output file (or clear any existing files) ====
#echo -e "Filename\tRead_Count" > "$RAW_READCOUNT_FILE"

# ==== Count Raw Reads ====
echo "STEP 1a: Count reads in each fastq file"

for file in "$INPUT_DIR"/*.fastq.gz; do
    echo "Counting reads in the $file..."
    name=$(basename "$file")
    count=$(zcat "$file" | wc -l)
    reads=$((count/4))
    echo -e "$name\t$reads" >> "$OUTPUT_RESULTS/$RAW_READCOUNT_FILE"
done

echo "Reads counts copied to $RAW_READCOUNT_FILE"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_qc"

# ==== Check FastQC installation ====
if ! command -v fastqc &> /dev/null; then
  echo "FastQC is not installed in the conda environment '$ENV_NAME_qc'."
  exit 1
fi

# ==== Create Output Directory ====
mkdir -p "$FASTQC_RAW_DIR"

# ==== Run FastQC ====
echo "STEP 1b: Initial QC- fastqc"

for file in "$INPUT_DIR"/*.fastq.gz; do
    echo "Processing: $file"
    fastqc "$file" -o "$FASTQC_RAW_DIR" --threads "$THREADS"
    #mv $INPUT_DIR/*.zip $FASTQC_RAW_DIR
    #mv $INPUT_DIR/*.html $FASTQC_RAW_DIR
done

echo "STEP 1b: Initial QC- fastqc complete. Results in $FASTQC_RAW_DIR"

# ==== Deactivate conda environment ====
conda deactivate

# ==== Run MultiQC ====
echo "STEP 1c: Initial QC- MultiQC"
conda activate "$ENV_NAME_multiqc"

multiqc "$FASTQC_RAW_DIR" -o $FASTQC_RAW_DIR
cp $FASTQC_RAW_DIR/multiqc_report.html $OUTPUT_RESULTS/raw_multiqc_report.html

#mv "$FASTQC_RAW_DIR" "$OUTPUT_RESULTS" --force
echo "STEP 1c: Initial QC- multiqc complete. Results in $OUTPUT_RESULTS"

# ==== Deactivate conda environment ====
conda deactivate


#!/bin/bash

# fastp_trim.sh
# trim and filter high quality reads in a fastq.gz file
# Run fastqc on fastqc files inside a conda environment
# Run multiqc to summarise fastqc results inside a conda environment

set -e # exit if a command fails
set -u  # Flag unset variables as errors

# ==== Create Output Directory for Results ====
HOME=$(pwd)
ENV_NAME_qc="qc"
ENV_NAME_multiqc="multiqc"
INPUT_DIR="./demo"
OUTPUT_RESULTS="./results"
TRIMMED_DIR="./Trimmed_Reads"
TRIMMED_READCOUNT_FILE="trimmed_read_count.txt"
FASTQC_DIR=$OUTPUT_RESULTS/"fastqc_trimmed_results"
FASTP_DIR=$OUTPUT_RESULTS/"Fastp_output"
THREADS=8

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Create Output Directory for Results ====
mkdir -p "$TRIMMED_DIR" "$FASTQC_DIR" "$FASTP_DIR"

# ==== Create the output file (or clear any existing files) ====
#echo -e "Filename\tReads_Count" > "$TRIMMED_READCOUNT_FILE"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_qc"

# ==== Process FASTQ files ====
echo "STEP 4: Fastp processing"

for r1 in "$INPUT_DIR"/*_1.fastq.gz; do
  # derive sample name
  r2="${r1/_1.fastq.gz/_2.fastq.gz}"
  #[[ -f "$r2"]] || { echo "Missing r2 for $r1"; continue; }
  
  # Extract sample name
  sample=$(basename "$r1" | sed 's/_1\.fastq\.gz//')

  # output trimmed files
  trimmed_1="$TRIMMED_DIR/${sample}_trim.R1.fastq.gz"
  trimmed_2="$TRIMMED_DIR/${sample}_trim.R2.fastq.gz"
  HTML_out="$FASTP_DIR/${sample}_fastp.html"
  JSON_out="$FASTP_DIR/${sample}_fastp.json"

  echo "Processing sample: $sample"
  
  # ==== Run Fastp ====
  fastp -i "$r1" -I "$r2" -o "$trimmed_1" -O "$trimmed_2" --trim_front1 5 --trim_front2 5 \
  --trim_tail1 5 --trim_tail2 5 \
  --cut_right --cut_tail \
  --detect_adapter_for_pe \
  --dedup \
  --overrepresentation_analysis \
  --length_required 50 \
  --qualified_quality_phred 20 --unqualified_percent_limit 20 \
  --n_base_limit 5 --average_qual 25 \
  --html "$HTML_out" --json "$JSON_out" \
  --thread "$THREADS" 
done

echo "STEP 4: Fastp read processing complete. Results in $TRIMMED_DIR"

# ==== Run FastQC on trimmed reads ====
echo "STEP 5: Run Fastqc - trimmed reads"

for file in "$TRIMMED_DIR"/*.fastq.gz; do
    echo "Processing: $file"
    fastqc "$file" -o "$FASTQC_DIR" --threads "$THREADS"
done

conda deactivate

echo "STEP 5: Trimmed QC- fastqc complete. Results in $FASTQC_DIR"

# ==== Run MultiQC ====
conda activate "$ENV_NAME_multiqc"
echo "STEP 6: Generating MultiQC Report"

multiqc "$FASTQC_DIR" -o $FASTQC_DIR

cp $FASTQC_DIR/multiqc_report.html $OUTPUT_RESULTS/trimmed_multiqc_report.html

echo "STEP 6: MultiQC complete. Results in $FASTQC_DIR"


# ==== Move output directories to results ====
#mv "$FASTP_DIR" "$OUTPUT_RESULTS"
#mv "$TRIMMED_DIR" "$OUTPUT_RESULTS"
#mv "$FASTQC_DIR" "$OUTPUT_RESULTS" --force

# ==== Count Reads ====
echo "STEP 6: Count trimmed reads"
r1_count=$(zcat "$trimmed_1" | wc -l)
r2_count=$(zcat "$trimmed_2" | wc -l)
echo -e "$sample\t$((r1_count/4))\t$((r2_count/4))" >> "$OUTPUT_RESULTS/$TRIMMED_READCOUNT_FILE"

# ==== Deactivate conda environment ====
conda deactivate



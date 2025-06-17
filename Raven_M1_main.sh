#!/bin/bash

# raven_M1_pipeline.sh
# Module 1 pipeline handles data QC, trimming and filetring, variant calling, SNP filtering, SNP-distance calculation and phylogenetic tree construction.

set -euo pipefail # for pipeline errors

# ==== Load config File ====
source config.env

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/bin/activate

# ==== STEP 1: Initial QC ====
echo "Step 1: Count reads in each fastq file"
bash ./workflow/initial_qc.sh "$INPUT_DIR" "$RAW_READCOUNT_FILE"

# ==== STEP 2: Fastp-Trim ====
echo "Step 2: Run Fastp"
bash ./workflow/fastp_trim.sh "$INPUT_DIR" "$TRIMMED_DIR" "$THREADS"

# ==== STEP 3: Variant Calling ====
echo "Step 3: Run vSNP3"
bash ./workflow/variant_calling.sh "$TRIMMED_DIR" "$THREADS"

# ==== STEP 4: Genome Assembly ====
echo "Step 4: Run Shovill/Skesa assembler"
bash ./workflow/reads_assembly.sh "$TRIMMED_DIR" "$OUTPUT_RESULTS" "$THREADS"

# ==== additional STEP: in-sillico Spoligotyping ====
echo "Step additional: Run Spotyping"
bash ./workflow/spotyping.sh "$INPUT_DIR" "$OUTPUT_RESULTS" "$THREADS"

echo "Raven_M1_pipeline completed successfully"

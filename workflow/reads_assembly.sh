#!/bin/bash

# reads_assembly.sh
# genome assembly of high quality reads in a fastq.gz file

set -e # exit if a command fails
set -u  # Flag unset variables as errors

# ==== Create Output Directory for Results ====
HOME=$(pwd)
ENV_NAME_assembly="assembly"
ENV_NAME_qc="qc"
OUTPUT_RESULTS="./results"
TRIMMED_DIR="./Trimmed_Reads"
ASSEMBLY=$OUTPUT_RESULTS/"Assembly"
SAMPLE_CONTIGS=$OUTPUT_RESULTS/"Skesa_contigs"
QUAST_RESULTS=$SAMPLE_CONTIGS/"quast_with_reference"
REF="./reference"
THREADS=8

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Create Output Directory for Results ====
mkdir -p "$ASSEMBLY" "$SAMPLE_CONTIGS" "$QUAST_RESULTS"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_assembly"

# ==== Run - Shovill / Skesa assembler ====
echo "STEP 4: Genome assembly using Shovill"

for R1 in "$TRIMMED_DIR"/*_trim.R1.fastq.gz; do
 # specify R2 from R1
 R2="${R1/_trim.R1.fastq.gz/_trim.R2.fastq.gz}"

 # Extract sample names
 SAMPLE=$(basename "$R1"| sed 's/_trim.R1\.fastq\.gz//')

 # specify output folder
 SAMPLE_OUT="$ASSEMBLY"/"${SAMPLE}"
 mkdir -p "$SAMPLE_OUT"

 shovill --namefmt contig%05d_"${SAMPLE}" --outdir "$SAMPLE_OUT" --R1 "$R1" --R2 "$R2" --minlen 150 --gsize 4.2M --assembler skesa --cpus "$THREADS" --force;
done

# ==== Rename contig files by SAMPLEID ====

for R1 in "$TRIMMED_DIR"/*_trim.R1.fastq.gz; do
 SAMPLE=$(basename "$R1"| sed 's/_trim.R1\.fastq\.gz//')
 cp "$ASSEMBLY"/${SAMPLE}/contigs.fa "$SAMPLE_CONTIGS"/${SAMPLE}.skesa.fa;
done

# ==== Deactivate conda environment ====
conda deactivate

# ==== Compute assembly stats ====
echo "Computing assembly stats"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_qc"

cd "$SAMPLE_CONTIGS"
statswrapper.sh *.fa format=6 > assembly_stats_contigs_skesa.txt
# cp assembly_stats_contigs_skesa.txt "$OUTPUT_RESULTS"

# ==== Cleaning and Polishing Assemblies ====
echo "cleaning and filtering assemblies"

# ==== filterout contigs < 150bp ====
for SAMPLE in *.skesa.fa; do
 BASENAME=$(basename "$SAMPLE" .skesa.fa)
 reformat.sh in=${BASENAME}.skesa.fa out=${BASENAME}.filtered.polished.fa minlength=150 --overwrite;
done

# === Rename scaffolds by the name of sample (remove anything after the first space in the FastaID) ====
for SAMPLE in *.filtered.polished.fa; do
 BASENAME=$(basename "$SAMPLE" .filtered.polished.fa)
 reformat.sh in=${BASENAME}.filtered.polished.fa out=${BASENAME}.clean.assembly.fasta trd=t --overwrite;
done

# ==== Compaute assembly stats - all polished assembies at once ====
statswrapper.sh *.clean.assembly.fasta format=6 > assembly_stats_cleaned_contigs_skesa.txt
# cp assembly_stats_cleaned_contigs_skesa.txt "$OUTPUT_RESULTS"

# ==== Remove unwanted fasta files ====
rm *.fa

cd "$HOME"

#mv "$FASTQC_RAW_DIR" "$OUTPUT_RESULTS" --force
echo "STEP 4: Genome assembly complete. Results in $SAMPLE_CONTIGS"

# ==== Deactivate conda environment ====
conda deactivate


# ==== Evaluating genome Assembly - QUAST statistics (with a Reference)
echo "evaluating assemblies"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_assembly"

cd "$SAMPLE_CONTIGS"
for SAMPLE in *.clean.assembly.fasta; do
 BASENAME=$(basename "$SAMPLE" .clean.assembly.fasta)
 quast.py ${BASENAME}.clean.assembly.fasta -r ../../$REF/AF2122_97_Mbovis.fasta -g ../../$REF/AF2122_97_Mbovis.gff --min-contig 250 --circos --gene-finding --output-dir ./quast_with_reference/${BASENAME};
done

# ==== Deactivate conda environment ====
conda deactivate
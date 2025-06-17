#!/bin/bash

# variant_calling_assembly.sh
# detect SNPs in an isolate using contigs by comparing it with M. bovis AF2122/97 reference genome.

set -e # exit if a command fails
set -u  # Flag unset variables as errors

# ==== Create Output Directory for Results ====
HOME=$(pwd)
ENV_NAME_snippy="snippy_env"
ENV_NAME_gubbins="gubbins"
ENV_NAME_trees="trees"
OUTPUT_RESULTS="./results"
SAMPLE_CONTIGS=$OUTPUT_RESULTS/"Skesa_contigs"
REF="./reference"
VARIANTS=$OUTPUT_RESULTS/"Snippy_variants"
THREADS=8

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Create Output Directory for Results ====
mkdir -p "$VARIANTS"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_snippy"

# ==== Run Snippy - Variant Calling ====
echo "STEP 6: Snippy variant calling"

for SAMPLE in "$SAMPLE_CONTIGS"/*.clean.assembly.fasta; do
 BASENAME=$(basename "$SAMPLE" .clean.assembly.fasta)
 snippy --cpus 16 --outdir $VARIANTS/${BASENAME}_ctgs_snps --ref $REF/AF2122_97_Mbovis.gbk --report --ctgs ${SAMPLE} --force;
done

# === Generate snp-based alignment using Snippy ====
#NOTE: remove contaminated assemblies before snippy-core. If not snippy will only create the full alignment not the snp alignment.
for SAMPLE in "$SAMPLE_CONTIGS"/*.clean.assembly.fasta; do
 BASENAME=$(basename "$SAMPLE" .clean.assembly.fasta)
 snippy-core --prefix BTB_demo  --mask ./$REF/Mbovis_AF212297_repeat_regions.bed --ref ./$REF/AF2122_97_Mbovis.gbk $VARIANTS/*_ctgs_snps;
done

mv BTB_demo* $VARIANTS

# ==== Clean the alignment ====
snippy-clean_full_aln $VARIANTS/BTB_demo.full.aln > $VARIANTS/BTB_demo.clean.full.aln

# ==== Deactivate conda environment ====
conda deactivate

# ==== Activate conda environment ====
conda activate "$ENV_NAME_gubbins"

# ==== Run Gubbins - Remove recombinats and build tree using raxml ====
echo "STEP 6b: Building maximum likelihood tree using Gubbins"
cd $VARIANTS
run_gubbins.py --prefix gubbins.cleaned.raxml --tree-builder raxmlng --model GTR BTB_demo.clean.full.aln --threads 16

cd $HOME

echo "Snippy varint calling and tree construction complete. Results in $VARIANTS"

# ==== Deactivate conda environment ====
conda deactivate

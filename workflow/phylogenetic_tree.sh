#!/bin/bash

# phylogenetic_tree.sh
# Filter out low-quality SNPs and build maximum likehood tree using core SNP alignment through IQ-tree. detect SNPs in an isolate by comparing it with reference genome M. bovis AF2122/97 reference genome.

HOME=$(pwd)
ENV_NAME_gubbins="gubbins"
ENV_NAME_trees="trees"
OUTPUT_RESULTS="./results"
INPUT_DIR="./Trimmed_Reads"
REF="./reference"
VSNP3_RESULTS="./results/vSNP3_output"

THREADS=8

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Run ParseSNP ====
echo "STEP 5: ParseSNP.py removes SNPs in repeat regions of the M.bovis genome"
# Before Processing follow the steps below.
# 1. Download a copy of the all_vcf_sorted vcf table from $VSNP_RESULTS/$step_2/all_vcf
# 2. Copy the content (do not include MQ) and transposed the content into a new excel sheel. 
# 3. Label columns appropriately where Refrence position as POS and roof as REF. Remove genomeID LTxxxxxxx from POS.
# 4. Name the new file: Mbovis_[date]_all_vcf_snp_table.csv eg. Mbovis_01062025_all_vcf_snp_table.csv
# 5. Upload the file to the all_vcf folder $VSNP_RESULTS/$step_2/all_vcf

conda deactivate
cd $VSNP3_RESULTS/step_2/all_vcf

for file in *_snp_table.csv; do
 python ../../../../$REF/parseSNPtable3.py -s $file -m filter,aln -x ../../../../$REF/AF2122_97_repeat_regions_coords.tsv;
done

cd $HOME

echo "STEP 5: SNP filtering complete. Results in $VSNP3_RESULTS/step_2/all_vcf"

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Run Snp-sites and SNP-dists ====
echo "STEP 5: Extract core SNP positions and compute SNP distances"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_trees"

# ==== Run SNP-Sites ====
#SNP_align=(*_var_regionFiltered.mfasta)

cd $VSNP3_RESULTS/step_2/all_vcf
for file in *_var_regionFiltered.mfasta; do
 snp-sites -c -o "core"_"$file" "$file";
done

for file in core_*_var_regionFiltered.mfasta; do
 snp-dists "$file" > "$file"_"snp.dist.txt";
done

echo "STEP 5: SNP-sites and SNP-dists calculation complete. Results in $VSNP3_RESULTS/step_2/all_vcf"

# ==== Deactivate conda environment ====
conda deactivate

# ==== Run IQ-Tree (RaxML Tree) ====
echo "STEP 5: Build a phylogenetic tree based on core SNP alignment"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_trees"

for file in core_*_var_regionFiltered.mfasta; do
 iqtree -s $file -T $THREADS -m GTR+F+ASC+R4 -alrt 1000 -bb 1000 -wsr -redo;
done

# ==== Deactivate conda environment ====
conda deactivate
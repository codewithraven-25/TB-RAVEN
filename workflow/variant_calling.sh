#!/bin/bash

# variant_calling.sh
# detect SNPs in an isolate using short-reads by comparing it with M. bovis AF2122/97 reference genome.

HOME=$(pwd)
ENV_NAME_vsnp3="vsnp3"
TRIMMED_DIR="./Trimmed_Reads"
OUTPUT_RESULTS="./results"
REF="./reference"
VSNP3_RESULTS=$OUTPUT_RESULTS/"vSNP3_output"

THREADS=8

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/etc/profile.d/conda.sh

# ==== Create Output Directory for Results ====
mkdir -p "$VSNP3_RESULTS"

# ==== Activate conda environment ====
conda activate "$ENV_NAME_vsnp3"

# ==== Run vSNP3 - Step 1 ====
echo "STEP 3: Variant Calling - vSNP3"

# ==== Copy trimmed reads to vSNP3 Directory ====
mkdir -p $VSNP3_RESULTS/step_1
cp $TRIMMED_DIR/*.gz $VSNP3_RESULTS/step_1

cd $VSNP3_RESULTS/step_1

# ==== Renaming fastq files for vSNP3 Process ====
for file in *.R*.fastq.gz; do
    base=$(basename "$file")
    # replace underscore(_) with hypen(-)
    # replace the priod (.) wih dash (-)
    # remove _trim
    newname=$(echo "$base" \
        | sed -E 's/_trim//; s/([0-9]+)\.([0-9]+)/\1-\2/; s/_/-/g' \
        | sed -E 's/.R([12])\.fastq\.gz/_R\1.fastq.gz/')
    echo "Renaming: $file to a newname"
    mv "$file" "$newname"
done

# ==== split fastqs into folders by its name ====
for fastq in *.fastq.gz; do 
 name=$(echo $fastq | sed 's/[._].*//'); mkdir -p $name; mv -v $fastq $name/;
done

# ==== Run vSNP3-step1 ====
NUM_PER_CYCLE=6; starting_dir=$(pwd);
for dir in ./*/; do (echo "starting: $dir"; cd ./$dir;
vsnp3_step1.py -r1 *_R1.fastq.gz -r2 *_R2.fastq.gz -r ../../../../$REF/AF2122_97_Mbovis.fasta -spoligo;
cd $starting_dir) & let count+=1; [[ $((count%NUM_PER_CYCLE)) -eq 0 ]] && wait; cd $HOME; done

echo "vSNP3 - step 1 complete. Results in $VSNP3_RESULTS Step 1 directory"

# ==== Run vSNP3 - step2 ====
cd $VSNP3_RESULTS
mkdir -p step_2

# ==== Copy all zc.vcf to Step2 Directory ====
cp ./step_1/BTB-*/align*/*_zc.vcf ./step_2

# ==== Run vSNP3-step2 ====
cd step_2
vsnp3_step2.py -a -t ../../../$REF/AF2122_97_Mbovis.fasta -y 60 -w 300

echo "vSNP3 - step 2 complete. Results in $VSNP3_RESULTS/$step_2"

# ==== Deactivate conda environment ====
conda deactivate

# ==== Return to Home Directory ====
cd $HOME

# ==== Move output directories to results ====
#mv "$VSNP3_RESULTS" "$OUTPUT_RESULTS"
# tb-RAVEN.v02
A simple bash-based pipeline for Mycobacterium bovis whole genome data analysis using anaconda (Conda).

## Requirements
- Conda
- Git

## Setup
git clone https;//github.com/butterbee/tb-RAVEN.v02.git
cd tb-RAVEN.v02
conda env create -f environment.yml
conda activate tb-RAVEN

## Features
Quality control with FastQC and MultiQC <BR>
in-sillico spoligotyping using Spotyping <BR>
Read trimming and filtering using Fastp <BR>
denovo assembly of short reads using Shovil/SKESA assembler <BR>
Variant calling using short-reads with VSNP3 <BR>
Variant calling using denovo assemblies with Snippy <BR>
Phylogenetic tree construction with RAxML and IQ-TREE <BR>
SNP distance calculation using SNP-dists <BR>
Gene annotation with Prokka <BR>
Sequence typing using MLST and Chewbacca <BR>
AMR indexing of genomes and reads using TB profiler <BR>
Pangenome analysis with Panaroo


## Usage
RAVEN Module 1: Performs a complete analysis of whole genome sequencing short reads, including quality control, variant calling, phylogenetic tree constraction and denovo assembly. 

RAVEN Module 2: Performs a complete analysis of denovo assemblies, including variant calling, phylogenetic tree constraction, gene annotation, sequence typing, AMR indexing and pangenome analysis. 


## Steps
To perform Module 1: ./Raven_M1_main.sh  or bash Raven_M1_main.sh
To perform Module 2: ./Raven_M2_main.sh  or bash Raven_M2_main.sh

## Citation
if you use this pipeline, please cite the underlyting tools and the this repository.

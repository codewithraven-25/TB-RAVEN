#!/bin/bash

# raven_M2_pipeline.sh
# Module 2 pipeline handles variant calling, phylogenetic tree constraction, gene annotation, sequence typing, AMR indexing and pangenome analysis.

set -euo pipefail # for pipeline errors

# ==== Load config File ====
source config.env

# ==== Activate Conda Environment ====
# conda path (adjust the path based on your system)
source /hdd/FastData0/apps/anaconda/bin/activate

# ==== STEP 5: Phylogenetic Tree Construction====
echo "Step 5: Run IQtree"
bash ./workflow/phylogenetic_tree.sh

# ==== STEP 6: Variant Calling - Assemblies ====
echo "Step 6: Run Snippy on assemblies and detect variants"
bash ./workflow/variant_calling_assembly.sh

# ==== STEP 7: AMR Detection ====
echo "Step 7: Run TB-Profiler on assembled genomes"
bash ./workflow/AMR_tbprofiler.sh

# ==== STEP 8: Sequence Typing ====
echo "Step 8: Run mlst and Chewbacca"
bash ./workflow/MLST_analysis.sh

# ==== STEP 9: Gene annotation Analysis ====
echo "Step 9: Run Prokka for gene annotation"
bash ./workflow/gene_annotation.sh

# ==== STEP 10: Pangenome Analysis ====
echo "Step 10: Run Panaroo for Pangenomes"
bash ./workflow/pangenome.sh

echo "Raven_M2_pipeline completed successfully"

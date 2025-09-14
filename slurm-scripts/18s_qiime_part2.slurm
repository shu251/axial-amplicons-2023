#!/bin/bash
##ENVIRONMENT SETTINGS; CHANGE WITH CAUTION
#SBATCH --export=NONE        #Do not propagate environment
#SBATCH --get-user-env=L     #Replicate login environment

##NECESSARY JOB SPECIFICATIONS
#SBATCH --job-name=18S-qiime2
#SBATCH --time=72:00:00            # 72 hours
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24        # 32 threads
#SBATCH --mem=340GB               # lots of memory, but never the maximum (which is 384G)
#SBATCH --output=18S-qiime2_part2-log.%j

module load QIIME2/2024.10-Amplicon

biom convert \
        -i /scratch/group/hu-lab/qiime-axial-2023_18S_16S/18S_output_axial_2023/feature-table.biom \
        -o /scratch/group/hu-lab/qiime-axial-2023_18S_16S/18S_output_axial_2023/axial-2023-18s-asv-table.tsv \
        --to-tsv


echo "assign taxonomy"

qiime feature-classifier classify-consensus-vsearch \
        --i-query /scratch/group/hu-lab/deepsea-18S-merged-outputs/deepsea-18s-merged-seqs-05022025.qza \
        --i-reference-reads /scratch/group/hu-lab/databases/PR2/pr2_version_5.0.0_seqs.qza \
        --i-reference-taxonomy /scratch/group/hu-lab/databases/PR2/pr2_version_5.0.0_tax.qza \
        --output-dir /scratch/group/hu-lab/deepsea-18S-merged-outputs/merged-taxonomy-0.9_0.8_PR2-5.0.0 \
        --p-threads $SLURM_CPUS_PER_TASK \
        --p-maxaccepts 10 \
        --p-perc-identity 0.90 \
        --p-min-consensus 0.80

echo "taxonomy assigned, convert output"

qiime tools export \
        --input-path /scratch/group/hu-lab/deepsea-18S-merged-outputs/merged-taxonomy-0.9_0.8_PR2-5.0.0/classification.qza \
        --output-path /scratch/group/hu-lab/deepsea-18S-merged-outputs/merged-taxonomy-0.9_0.8_PR2-5.0.0/taxonomy-merged-05022025

echo "assign taxonomy - for SILVA"

qiime feature-classifier classify-consensus-vsearch \
        --i-query /scratch/group/hu-lab/deepsea-18S-merged-outputs/deepsea-18s-merged-seqs-05022025.qza \
        --i-reference-reads /scratch/group/hu-lab/databases/silva/silva-138-99-seqs.qza \
        --i-reference-taxonomy /scratch/group/hu-lab/databases/silva/silva-138-99-tax.qza \
        --output-dir /scratch/group/hu-lab/deepsea-18S-merged-outputs/merged-taxonomy-0.9_0.8_SILVA-138 \
        --p-threads $SLURM_CPUS_PER_TASK \
        --p-maxaccepts 10 \
        --p-perc-identity 0.90 \
        --p-min-consensus 0.80

echo "taxonomy assigned, convert output - for SILVA"

qiime tools export \
        --input-path /scratch/group/hu-lab/deepsea-18S-merged-outputs/merged-taxonomy-0.9_0.8_SILVA-138/classification.qza \
        --output-path /scratch/group/hu-lab/deepsea-18S-merged-outputs/merged-taxonomy-0.9_0.8_SILVA-138/taxonomy-merged-SILVA-05032025

#!/bin/bash
##ENVIRONMENT SETTINGS; CHANGE WITH CAUTION
#SBATCH --export=NONE        #Do not propagate environment
#SBATCH --get-user-env=L     #Replicate login environment

##NECESSARY JOB SPECIFICATIONS
#SBATCH --job-name=16S-qiime2
#SBATCH --time=72:00:00            # 72 hours
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16        # 32 threads
#SBATCH --mem=340GB               # lots of memory, but never the maximum (which is 384G)
#SBATCH --output=16S-qiime2-log.%j

# Load qiime2
module load QIIME2/2024.10-Amplicon

echo "import sequences"

qiime tools import \
 --type 'SampleData[PairedEndSequencesWithQuality]' \
 --input-path /scratch/group/hu-lab/qiime-axial-2023_18S_16S/manifest-axial-prok \
 --output-path /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-input-16s.qza \
 --input-format PairedEndFastqManifestPhred33V2

qiime demux summarize \
	--i-data /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-input-16s.qza \
	--o-visualization /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-input-16s.qzv

echo "Use cutadapt to remove primer sequences"

qiime cutadapt trim-paired \
	--i-demultiplexed-sequences /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-input-16s.qza \
	--p-cores $SLURM_CPUS_PER_TASK \
	--p-front-f GTGYCAGCMGCCGCGGTAA \
	--p-front-r GGACTACNVGGGTWTCTAAT \
	--p-error-rate 0.1 \
	--p-overlap 3 \
	--p-match-adapter-wildcards \
	--o-trimmed-sequences /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-input-trimmed-16s.qza

qiime demux summarize \
	--i-data /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-input-trimmed-16s.qza \
	--o-visualization /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-input-trimmed-16s.qzv

qiime dada2 denoise-paired \
	--i-demultiplexed-seqs /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-input-trimmed-16s.qza \
	--p-trunc-len-f 250 \
	--p-trunc-len-r 225 \
	--p-max-ee-f 2 \
	--p-max-ee-r 2 \
	--p-min-overlap 10 \
	--p-pooling-method independent \
	--p-n-reads-learn 1000000 \
	--p-n-threads $SLURM_CPUS_PER_TASK \
	--p-chimera-method pooled \
	--o-table /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-trimmed-asv-table-16s.qza \
	--o-representative-sequences /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-trimmed-asv-ref-seq-16s.qza \
	--o-denoising-stats /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-trimmed-asv-dada2stats-16s.qza

echo "dada2 step completed"

qiime tools export \
        --input-path /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-trimmed-asv-table-16s.qza \
        --output-path /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/

biom convert \
        -i /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/feature-table.biom \
        -o /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/axial-2023-16s-asv-table.tsv \
        --to-tsv

echo "asv table is prepped"

qiime metadata tabulate \
        --m-input-file /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-trimmed-asv-dada2stats-16s.qza \
        --o-visualization /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-trimmed-asv-dada2stats-16s.qzv


echo "assign taxonomy"

qiime feature-classifier classify-consensus-vsearch \
        --i-query /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/pe-trimmed-asv-ref-seq-16s.qza \
        --i-reference-reads /scratch/group/hu-lab/databases/silva/silva-138-99-seqs.qza \
        --i-reference-taxonomy /scratch/group/hu-lab/databases/silva/silva-138-99-tax.qza \
        --output-dir /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/taxonomy-0.9_0.8_SILVA \
        --p-threads $SLURM_CPUS_PER_TASK \
        --p-maxaccepts 10 \
        --p-perc-identity 0.90 \
        --p-min-consensus 0.80

qiime tools export \
        --input-path /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/taxonomy-0.9_0.8_SILVA/search_results.qza \
        --output-path /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/taxonomy-0.9_0.8_SILVA/tax-result-SILVA-16s

qiime tools export \
        --input-path /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/taxonomy-0.9_0.8_SILVA/classification.qza \
        --output-path /scratch/group/hu-lab/qiime-axial-2023_18S_16S/16S_output_axial_2023/taxonomy-0.9_0.8_SILVA/

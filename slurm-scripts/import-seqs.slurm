#!/bin/bash
##ENVIRONMENT SETTINGS; CHANGE WITH CAUTION
#SBATCH --export=NONE        #Do not propagate environment
#SBATCH --get-user-env=L     #Replicate login environment
  
##NECESSARY JOB SPECIFICATIONS
#SBATCH --job-name=import-q2     #Set the job name to "JobExample1"
#SBATCH --time=05:45:00            #Set the wall clock limit to 1hr and 30min
#SBATCH --ntasks=1                 #Request 1 task
#SBATCH --cpus-per-task=4	
#SBATCH --mem=2GB                #Request 2560MB (2.5GB) per node
#SBATCH --output=import-q2.%j    #Send stdout/err to "Example1Out.[jobID]"


module load QIIME2/2023.2

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path /home/skhu/axial-amplicons-2023/manifest \
  --output-path /scratch/user/skhu/axial-2023/paired-end-input.qza \
  --input-format PairedEndFastqManifestPhred33V2

qiime demux summarize \
  --i-data /scratch/user/skhu/axial-2023/paired-end-input.qza \
  --o-visualization /scratch/user/skhu/axial-2023/viz/paired-end-input.qzv

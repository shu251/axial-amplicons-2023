#!/bin/bash
##ENVIRONMENT SETTINGS; CHANGE WITH CAUTION
#SBATCH --export=NONE        #Do not propagate environment
#SBATCH --get-user-env=L     #Replicate login environment
  
##NECESSARY JOB SPECIFICATIONS
#SBATCH --job-name=run-multiqc     #Set the job name to "JobExample1"
#SBATCH --time=06:00:00            #Set the wall clock limit to 1hr and 30min
#SBATCH --ntasks=1                 #Request 1 task
#SBATCH --cpus-per-task=4	
#SBATCH --mem=2GB                #Request 2560MB (2.5GB) per node
#SBATCH --output=multi_qc.%j    #Send stdout/err to "Example1Out.[jobID]"

echo "run fastqc"

module load FastQC/0.12.1-Java-11

fastqc /scratch/group/hu-lab/data/microeuk-tag-seq/AxialSeamount-2023-18S_16S/*.fastq.gz -o /scratch/group/hu-lab/data/microeuk-tag-seq/AxialSeamount-2023-18S_16S/fastqc/

echo "run multiqc"

module load GCC/12.2.0
module load OpenMPI/4.1.4
module load MultiQC/1.14

multiqc /scratch/group/hu-lab/data/microeuk-tag-seq/AxialSeamount-2023-18S_16S/fastqc/

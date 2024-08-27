# Axial-amplicons-2023

## Aug 13, 2024

1.  Upload new 18S and 16S sequences from UGA
PATH: /scratch/group/hu-lab/data/microeuk-tag-seq/AxialSeamount-2023-18S_16S

2. Modify create.manifest script. Changed file paths

3. Run script to make manifest file.

## Aug 27

Had to re-download sequences from basespace, there was an issue with upper level directory.

Now, re-running manifest file creation and initial QC of sequences:

```
# Make the manifest file:

## Activate R on the HPRC
module load GCC/12.2.0
module load OpenMPI/4.1.4
module load R_tamu/4.3.1

## Run script

Rscript r-scripts/create-manifest.R

```

Run slurm jobs to do sequence QC:

```
# in `slurm-scripts`
sbatch import-seqs.slurm

sbatch multiqc.slurm
```

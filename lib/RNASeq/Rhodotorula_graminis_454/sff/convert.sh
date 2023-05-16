#!/usr/bin/bash -l
#SBATCH -p short -N 1 -c 2 --mem 8gb

module load parallel
module load biopython
pbzip2 -d *.bz2
parallel -j 2 sff2fastq.py {} ::: $(ls *.sff)
# pbzip2 *.sff

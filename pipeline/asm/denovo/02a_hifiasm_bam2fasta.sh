#!/usr/bin/bash -l
#SBATCH -p epyc --out logs/bam2fasta.%a.log

conda activate bam2fastx

IN=input/pacbio

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
	echo "no value for SLURM ARRAY - specify with -a or cmdline"
	exit
    fi
fi

mkdir -p $OUT
IFS=,
SAMPLES=samples.csv

tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ

do
    
    bam2fasta $IN/$STRAIN/$STRAIN.hifi_reads.bam -o $IN/$STRAIN/$STRAIN
    
done

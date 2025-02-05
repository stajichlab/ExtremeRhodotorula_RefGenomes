#!/usr/bin/bash -l
#SBATCH -p epyc --out logs/launch_hicanu.%a.log --job-name=hicanu

module load canu
IN=input/pacbio
OUT=asm/hicanu
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
    canu -p ${NAME} -d $OUT/${NAME} genomeSize=20m -pacbio-hifi $IN/$STRAIN/$STRAIN.fasta.gz
done

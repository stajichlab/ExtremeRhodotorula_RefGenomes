#!/usr/bin/bash -l
#SBATCH -p short --out logs/launch_canu.%a.log -a 1-5
module load canu
IN=input/nanopore
OUT=asm/canu
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
	echo "no value for SLURM ARRAY - specify with -a or cmdline"
    fi
fi

mkdir -p $OUT
IFS=,
SAMPLES=samples.csv

sed -n ${N}p $SAMPLES | while read STRAIN NANOPORE SUBPHYLUM PHYLUM
do
	canu -p ${STRAIN} -d $OUT/${STRAIN} genomeSize=20m -nanopore-raw $IN/$NANOPORE.fq.gz
done

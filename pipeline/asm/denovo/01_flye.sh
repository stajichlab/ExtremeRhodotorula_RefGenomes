#!/usr/bin/bash -l
#SBATCH -p short -C xeon -N 1 -c 24 --mem 96gb --out logs/flye.%a.log -a 1-5
module load Flye
IN=input/nanopore
OUT=asm/flye
hostname
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=2
fi
N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi


mkdir -p $OUT
IFS=,
SAMPLES=samples.csv

sed -n ${N}p $SAMPLES | while read STRAIN NANOPORE SUBPHYLUM PHYLUM
do
	flye --nano-hq $IN/$NANOPORE.fq.gz --out-dir $OUT/$STRAIN --threads $CPU --scaffold
done

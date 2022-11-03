#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 2 --mem 4gb --out logs/stats.log

module load AAFTF

IFS=,
SAMPLES=samples.csv
OUTDIR=genomes
for file in $(ls $OUTDIR/*.fasta)
do
    b=$(basename $file .fasta)
    STATS=$OUTDIR/$(basename $file .fasta).stats.txt
    if [ ! -s $STATS ]; then
	AAFTF assess -i $file -r $STATS
    fi
done

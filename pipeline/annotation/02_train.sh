#!/bin/bash -l
#SBATCH --nodes 1 --ntasks 24 --mem 128G --out logs/train.%a.log -J trainFun --time 96:00:00

MEM=128G
module load funannotate

#export PASAHOME=`dirname $(which Launch_PASA_pipeline.pl)`
RNADIR=lib/RNASeq
CPUS=$SLURM_CPUS_ON_NODE

if [ ! $CPUS ]; then
    CPUS=2
fi
SAMPLES=samples.csv
N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=$(wc -l $SAMPLES | awk '{print $1}')
if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPLES"
    exit
fi

INDIR=final_genomes
OUTDIR=annotation

IFS=,
tail -n +2 $SAMPLES | sed -n ${N}p | while read BASE SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do
    name=$BASE
    GENOME=$INDIR/$BASE.masked.fasta
    if [ -z $RNASEQ ]; then
	echo "No RNASeq for training, skipping $BASE"
    else
	FILES=( $(ls $RNADIR/${RNASEQ}) )
	ARGS=""
	if [ ${#FILES[@]} == 1 ]; then
	    ARGS="--single ${FILES[0]}"
	elif [ ${#FILES[@]} == 1 ]; then
	    ARGS="--left ${FILES[0]} --right ${FILES[1]}"
	else
	    echo "No RNASeq files found in '$RNADIR' for '$RNASEQ' - check RNASEQ column in $SAMPLES"
	    exit
	fi
	
	funannotate train -i $SORTED --cpus $CPUS --memory $MEM \
		    --species "$SPECIES" --strain $STRAIN \
		    -o $OUTDIR/$BASE --jaccard_clip $ARGS \
		    --max_intronlen 1000
    fi
done

#!/usr/bin/bash -l
#SBATCH -p epyc --mem=128gb --out logs/launch_hifiasm.%a.log --job-name=hifiasm

module load hifiasm

IN=input/pacbio
OUT=asm/hifiasm

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
    
    hifiasm -o $OUT/$NAME -t16 -l0 $IN/$STRAIN/$STRAIN.fasta.gz 2> ./logs/$NAME.pacbio.log #for Homozygous Genome Assembly, such as 2A2, and haploid
    #hifiasm -o $OUT/$NAME -t16 $IN/$STRAIN/$STRAIN.fasta.gz #Assemble heterozygous genomes with built-in duplication purging
done

#using this step to transfer the `prefix`.p_ctg.gfa to `prefix`.p_ctg.fa
#awk '/^S/{print ">"$2;print $3}' Rhodotorula_mucilaginosa_DBVPG_3855.bp.p_ctg.gfa > Rhodotorula_mucilaginosa_DBVPG_3855.bp.p_ctg.fa

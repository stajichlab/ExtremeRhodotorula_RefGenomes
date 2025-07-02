#!/usr/bin/bash -l
#SBATCH -p batch --mem=128gb --out logs/launch_hifiasm.%a.trio.log --job-name=hifiasm_trio

module load hifiasm

IN=input/pacbio
OUT=/bigdata/stajichlab/shared/projects/Rhodotorula/Ref_genomes/asm/hifiasm/Rhodotorula_mucilaginosa_DBVPG_3855_tri

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
YAK=/bigdata/stajichlab/shared/projects/Rhodotorula/Ref_genomes/asm/hifiasm/Rhodotorula_mucilaginosa_DBVPG_3855_tri

tail -n +2 $SAMPLES | sed -n ${N}p | while read NAME SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do
    
    #hifiasm -o $OUT/$NAME -t16 -l3 $IN/$STRAIN/$STRAIN.fasta.gz 2> ./logs/$NAME.pacbio.log #for Homozygous Genome Assembly, such as 2A2, and haploid
    #hifiasm -o $OUT/$NAME -t16 $IN/$STRAIN/$STRAIN.fasta.gz #Assemble heterozygous genomes with built-in duplication purging
    #hifiasm -o $OUT/$NAME.l0 -t16 -l0 --primary $IN/$STRAIN/$STRAIN.fasta.gz #Assemble heterozygous genomes with one parental genome
    hifiasm -o $OUT/$NAME -t 32 -1 $YAK/2510.yak $IN/$STRAIN/$STRAIN.fasta.gz 
done

#using this step to transfer the `prefix`.p_ctg.gfa to `prefix`.p_ctg.fa
#awk '/^S/{print ">"$2;print $3}' Rhodotorula_mucilaginosa_DBVPG_3855.bp.p_ctg.gfa > Rhodotorula_mucilaginosa_DBVPG_3855.bp.p_ctg.fa

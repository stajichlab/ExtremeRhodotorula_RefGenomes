#!/bin/bash -l
#SBATCH --nodes 1 -c 16 --mem 16G -p epyc --out logs/busco.%a.log -J busco

# for augustus training
# set to a local dir to avoid permission issues and pollution in global
module unload miniconda3
#module load busco
module load busco/5.4.3
#export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
export AUGUSTUS_CONFIG_PATH=$(realpath /bigdata/stajichlab/xinzhanl/Ref_genomes_XZLiu/lib/augustus/3.3/config/)

module load workspace/scratch
which augustus
CPU=${SLURM_CPUS_ON_NODE}

if [ ! $CPU ]; then
     CPU=2
fi
export NUMEXPR_MAX_THREADS=$CPU

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi
GENOMEFOLDER=genomes
EXT=fasta
LINEAGE=basidiomycota_odb10
OUTFOLDER=BUSCO
SEED_SPECIES=ustilago
IN=/bigdata/stajichlab/shared/projects/Rhodotorula/Ref_genomes/genomes/

IFS=,
SAMPLES=samples.csv
tail -n +2 $SAMPLES | sed -n ${N}p | while read BASE SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do
   busco -m genome -l $LINEAGE -c $CPU -o ${BASE}.hicanu.sorted.fasta --out_path ${OUTFOLDER} --offline --augustus_species $SEED_SPECIES \
	  --in $IN/${BASE}.hicanu.sorted.fasta --download_path $BUSCO_LINEAGES
   #busco -m genome -l $LINEAGE -c $CPU -o ${BASE}.hifiasm.sorted --out_path ${OUTFOLDER} --offline --augustus_species $SEED_SPECIES \
	  #--in $IN/${BASE}.hifiasm.sorted.fasta --download_path $BUSCO_LINEAGES
done
#!/bin/bash -l
#SBATCH --nodes 1 -c 16 --mem 16G -p short --out Public_genomes/logs/busco.%a.log -J busco -a 1

pushd Public_genomes
# for augustus training
# set to a local dir to avoid permission issues and pollution in global
module unload miniconda3
#module load busco
module load busco/5.4.3
#export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)

module load workspace/scratch
which augustus
CPU=${SLURM_CPUS_ON_NODE}
N=${SLURM_ARRAY_TASK_ID}
if [ ! $CPU ]; then
     CPU=2
fi
export NUMEXPR_MAX_THREADS=$CPU
GENOMEFOLDER=genomes
EXT=fasta
LINEAGE=basidiomycota_odb10
OUTFOLDER=BUSCO
SEED_SPECIES=ustilago
GENOMEFILE=$(ls $GENOMEFOLDER/*.${EXT} | sed -n ${N}p)
#LINEAGE=$(realpath $LINEAGE)

echo "GENOMEFILE is $GENOMEFILE"
NAME=$(basename $GENOMEFILE .$EXT)
GENOMEFILE=$(realpath $GENOMEFILE)
if [ -d "$OUTFOLDER/${NAME}" ];  then
    echo "Already have run $NAME in folder busco - do you need to delete it to rerun?"
    exit
else
  busco -m genome -l $LINEAGE -c $CPU -o ${NAME} --out_path ${OUTFOLDER} --offline --augustus_species $SEED_SPECIES \
	  --in $GENOMEFILE --download_path $BUSCO_LINEAGES
fi

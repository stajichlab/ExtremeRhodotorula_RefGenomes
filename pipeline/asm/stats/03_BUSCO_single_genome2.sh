#!/bin/bash -l
#SBATCH --nodes 1 -c 16 --mem 16G -p short --out logs/busco.%a.log -J busco

# for augustus training
# set to a local dir to avoid permission issues and pollution in global
module unload miniconda3
#module load busco
module load busco/5.4.3
#export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.5/config
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.5/config)

module load workspace/scratch
which augustus

GENOMEFOLDER=genomes
EXT=fasta
LINEAGE=/bigdata/operations/pkgadmin/srv/projects/db/BUSCO/v10/lineages/basidiomycota_odb10
OUTFOLDER=BUSCO
SAMPLEFILE=samples.csv
SEED_SPECIES=ustilago
GENOMEFILE=genomes/Rhodotorula_paludigena_Y12923.canu.fasta

echo "GENOMEFILE is $GENOMEFILE"
NAME=$(basename $GENOMEFILE .$EXT)

if [ -d "$OUTFOLDER/${NAME}" ];  then
    echo "Already have run $NAME in folder busco - do you need to delete it to rerun?"
    exit
else
  busco -m genome -l $LINEAGE -c 8 -o Rhodotorula_paludigena_Y12923.canu.fasta --out_path ${OUTFOLDER} --offline --augustus_species $SEED_SPECIES --in $GENOMEFILE --download_path $BUSCO_LINEAGES
fi

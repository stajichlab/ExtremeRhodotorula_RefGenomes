#!/bin/bash
#SBATCH --nodes 1 --ntasks 16 --mem 64G -p intel --out logs/update.%a.log

module unload perl
module unload miniconda2
module unload miniconda3
module load anaconda3
module load funannotate
module unload perl
module unload python
source activate funannotate

CPUS=$SLURM_CPUS_ON_NODE

if [ ! $CPUS ]; then
 CPUS=2
fi

funannotate update -i funannotate_1/DAOM_BR117 --cpus $CPUS --species "Spizzelomyces punctatus" --name DAOM_BR117 --strain DAOM_BR117 --no_normalize_reads


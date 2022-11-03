#!/usr/bin/bash -l
#SBATCH -p short
pushd Public_genomes
perl ../scripts/asm_stats.pl > asm_stats.tsv

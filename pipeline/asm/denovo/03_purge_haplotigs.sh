#!/usr/bin/bash -l
#SBATCH -p short -N 1 -c 24 --mem 96gb --out logs/purge_haplotigs.11.log

module load purge_haplotigs
module load minimap2
module load samtools

MEM=96
INDIR=/bigdata/stajichlab/shared/projects/Rhodotorula/Ref_genomes/asm/hicanu/Rhodotorula_mucilaginosa_DBVPG_3855/
READDIR=/bigdata/stajichlab/shared/projects/Rhodotorula/Ref_genomes/input/pacbio/DBVPG_3855/
OUTDIR=/bigdata/stajichlab/shared/projects/Rhodotorula/Ref_genomes/asm/purge_haplotigs/

HIFIASM=$INDIR/Rhodotorula_mucilaginosa_DBVPG_3855.contigs.fasta
NANOPOREREADS=$READDIR/DBVPG_3855.fasta.gz
BAMFILE=$OUTDIR/Rhodotorula_mucilaginosa_DBVPG_3855.aligned.bam

minimap2 -t 4 -ax map-pb $HIFIASM $NANOPOREREADS --secondary=no | samtools sort -m 1G -o $BAMFILE -T tmp.ali
purge_haplotigs  hist  -b $BAMFILE  -g $HIFIASM  [ -t 8 ]
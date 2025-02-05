#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 2 --mem 4gb --out logs/stats.log

module load AAFTF

IFS=,
SAMPLES=samples.csv
INDIR=asm
OUTDIR=genomes

mkdir -p $OUTDIR

tail -n +2 $SAMPLES | sed -n ${N}p | while read BASE SPECIES STRAIN NANOPORE ILLUMINA SUBPHYLUM PHYLUM LOCUS RNASEQ
do
    rsync -a $INDIR/hifiasm/$BASE.bp.p_ctg.fa $OUTDIR/$BASE.hifiasm.fasta
    rsync -a $INDIR/hicanu/$BASE/$BASE.contigs.fasta $OUTDIR/$BASE.hicanu.fasta
    
    awk '/^>/ {print ">tig" ++i; next} {print}' $OUTDIR/$BASE.hicanu.fasta > $OUTDIR/$BASE.hicanu.clean.fasta
    mv $OUTDIR/$BASE.hicanu.clean.fasta $OUTDIR/$BASE.hicanu.fasta
    
    for type in hifiasm hicanu
    do
	
  QUERY=$OUTDIR/$BASE.$type.fasta
  SORTED=$OUTDIR/$BASE.$type.sorted.fasta
	STATS=$OUTDIR/$BASE.$type.sorted.stats.txt
	
 
	if [[ -s $QUERY ]]; then
	   
		if [[ ! -s $SORTED || $QUERY -nt $SORTED ]]; then
			AAFTF sort -i $QUERY -o $SORTED
		fi
		if [[ ! -s $STATS || $SORTED -nt $STATS ]]; then
      AAFTF assess -i $SORTED -r $STATS
		fi
	fi
    done
done

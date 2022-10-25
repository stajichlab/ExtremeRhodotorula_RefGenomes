#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 2 --mem 4gb --out logs/stats.log

module load AAFTF

IFS=,
SAMPLES=samples.csv
INDIR=asm
OUTDIR=genomes

mkdir -p $OUTDIR
cat $SAMPLES | while read STRAIN NANOPORE ILLUMINA
do
    rsync -a $INDIR/canu/$STRAIN/$STRAIN.contigs.fasta $OUTDIR/$STRAIN.canu.fasta
    rsync -a $INDIR/flye/$STRAIN/assembly.fasta $OUTDIR/$STRAIN.flye.fasta
    if [ -d $INDIR/NECAT/$STRAIN/$STRAIN/6-bridge_contigs ]; then
	rsync -a $INDIR/NECAT/$STRAIN/$STRAIN/6-bridge_contigs/polished_contigs.fasta $OUTDIR/$STRAIN.necat.fasta
    fi

    for type in canu flye 
    do
	if [ -f  $INDIR/pilon/$STRAIN/$type.pilon.fasta ];  then
		AAFTF sort -i $INDIR/pilon/$STRAIN/$type.pilon.fasta -o $OUTDIR/$STRAIN.$type.pilon.fasta
		AAFTF assess -i OUTDIR/$STRAIN.$type.pilon.sorted.fasta -r $OUTDIR/$STRAIN.$type.pilon.stats.txt
	fi
	STATS=$OUTDIR/$STRAIN.$type.stats.txt
	QUERY=$OUTDIR/$STRAIN.$type.fasta
	if [[ -s $QUERY ]]; then
	    if [[ ! -s $STATS || $QUERY -nt $STATS ]]; then
		AAFTF assess -i $QUERY -r $STATS
	    fi
	fi
	# copy medka
	polishtype=medaka
	QUERY=$INDIR/$polishtype/$STRAIN/$type.polished.fasta
	SORTED=$OUTDIR/$STRAIN.$type.$polishtype.sorted.fasta
	STATS=$OUTDIR/$STRAIN.$type.$polishtype.stats.txt
	if [ -f $QUERY ]; then
		if [[ ! -s $SORTED || $QUERY -nt $SORTED ]]; then
			AAFTF sort -i $QUERY -o $SORTED
		fi
		if [[ ! -s $STATS || $SORTED -nt $STATS ]]; then
                	AAFTF assess -i $SORTED -r $STATS
		fi
	fi
    done
done


#!/usr/bin/bash -l
#SBATCH -p short -c  2 --mem 2gb -N 1 -n 1 

module load ncbi-table2asn
if [ -z $(ls *.fsa) ]; then
	mv *.fa $(basename `ls *.fa` .scaffolds.fa).fsa
fi
SBT=$(ls *.sbt | head -n 1)
table2asn -l paired-ends -V v -M n -c ef -i *.fsa -o Aspergillus_niger_DFA-N.sqn -Z -t ${SBT} -euk  -j "[organism=Rhodototrula mucilaginosa] [strain=NRRL Y-2510T] [gcode=1]" -T -C UCR

#!/usr/bin/env python3
from Bio import SeqIO
import sys, os

inf=sys.argv[1]
out=os.path.splitext(inf)[0]+".fastq"
records = SeqIO.parse(inf, "sff")

count = SeqIO.write(records, out, "fastq-illumina")
print("Converted %i records" % count)

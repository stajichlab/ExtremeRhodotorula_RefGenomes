#!/usr/bin/bash -l
#SBATCH -p short --mem 25gb
pushd Public_genomes
bash scripts/get_ncbi_datasets.sh
./scripts/assembly_json_process.py --infile lib/ncbi_accessions.json --outfile lib/ncbi_accessions.csv
./scripts/add_taxonomy.py --infile lib/ncbi_accessions.csv --outfile lib/ncbi_accessions_taxonomy.csv

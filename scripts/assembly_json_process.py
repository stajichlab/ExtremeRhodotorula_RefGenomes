#!/usr/bin/env python3
import json, csv,sys, re
import argparse
import hashlib
parser = argparse.ArgumentParser(description="NCBI Datasets Genomes Process.",
                                 epilog="Generate by running. ./datasets summary genome taxon fungi > ncbi_accessions.json")
parser.add_argument('--infile', dest='infile', default="ncbi_accessions.json",
                    help='NCBI JSON processed from https://www.ncbi.nlm.nih.gov/datasets/docs/command-line-assembly/ datasets')
parser.add_argument('--outfile',dest='outfile',default="ncbi_accessions.csv",help="Output file for NCBI processing")

args = parser.parse_args()

with open(args.infile, "r",encoding="utf-8") as jsonin, open(args.outfile,"w",newline='') as outcsv:
    data = json.load(jsonin)
    outcsvtbl = csv.writer(outcsv,dialect="unix",quoting=csv.QUOTE_MINIMAL)
    outcsvtbl.writerow(['ACCESSION','SPECIES','STRAIN','NCBI_TAXID','BIOPROJECT','ASM_LENGTH','N50','ASM_NAME'])
    rows = {}
    print(data.keys())
    #for assembly in data["assemblies"]:
    for assembly in data["reports"]:
        category = ''
        print( assembly.keys() )
        if 'assembly_category' in assembly['assembly']:
            category = assembly['assembly_category']

        if category != 'representative genome':
            continue

        accession = assembly['current_accession']
        assembly_name= assembly['display_name']
        assembly_name = re.sub(r',','',assembly_name)
        assembly_name = re.sub(r'[\(\)\/]','_',assembly_name)
        assembly_name = re.sub(r' _V','_V',assembly_name)
        #print(seen)

        bioprojects = set()
        species = assembly['org']["sci_name"]
        strain  = ""
        if 'strain' in assembly['assembly_info']['org']:
            strain  = assembly['assembly_info']['org']["strain"]
        elif 'isolate' in  assembly['assembly_info']['org']:
            strain  = assembly['assembly_info']['org']["isolate"]
        strain = re.sub(r',\s+',';',strain)
        taxid   = assembly['assembly_info']['org']['tax_id']
        rank = ""
        if 'rank' in assembly['assembly_info']['org']:
            rank    = assembly['assembly_info']['org']['rank']
            if rank == "STRAIN":
                taxid = assembly['assembly_info']['org']['parent_tax_id']
                species = re.sub(' {}'.format(strain),'',species)
        elif species == "Fusarium vanettenii 77-13-4" or species == "Leptosphaeria biglobosa 'brassicae' group":
            taxid = assembly['assembly']['org']['parent_tax_id']
            species = re.sub(' {}'.format(strain),'',species)
        else:
            print("no rank for {}".format(species))
        n50     = assembly['assembly_info']['contig_n50']
        seqlength = assembly['assembly_info']['seq_length']
        for bioproject in assembly['assembly_info']['bioproject_lineages']:
            for proj,dat in bioproject.items():
                for acc in dat:
                    bioprojects.add( acc["accession_info"])
                #{'bioprojects': [{'accession': 'PRJNA588476', 'title': 'Coniothyrium minitans project'}]}
        #print("accession is {} bioprojects={}".format(accession,bioprojects))
        if species in rows:
            if accession.startswith("GCF_"):
                rows[species] = [accession,species,strain,taxid,";".join(bioprojects),seqlength,n50,assembly_name]
        else:
            rows[species] = [accession,species,strain,taxid,";".join(sorted(bioprojects)),seqlength,n50,assembly_name]

    for species in sorted(rows.keys()):
        outcsvtbl.writerow(rows[species])


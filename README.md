Instructions:

Check if you have Docker and Nextflow installed
```bash
nextflow --version
docker --version
```
Download Docker Image: This contains the environment for the Nextflow Pipeline

```bash
docker pull gbolden101/bulk-rna-pipeline:1.0
```
Run the Docker Image to Produce the Container

```bash
docker run gbolden101/bulk-rna-pipeline:1.0
```

Clone Git Repository for Nextflow Modules and Script

Check the Sample Sheet for CSV structure. You can either use the test data or your own

Download the Test Data or use your own
https://github.com/csoneson/rnaseqworkflow_exampledata

Required Inputs:
1. sample_sheet in CSV Format with columns sample_ID,fastq_1,fastq_2
2. reference genome
3. reference gtf
   
Complete the Command
```bash
nextflow run ./scripts/rna_bulk.nf \
    --sample_sheet ../test_sample_sheet.csv \
    --final_outdir test \
    --genome_fa ../reference_test/Homo_sapiens.GRCh38.dna.chromosome.1.1.10M.fa \
    --gtf ../reference_test/Homo_sapiens.GRCh38.93.1.1.10M.gtf \
    --trim false \
    -resume
```

#use -resume at the end of the command to use cached data
For example if a researcher wants trim their reads -resume will pick up with cached results

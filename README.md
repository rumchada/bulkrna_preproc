Instructions on how to run
Check if you have Docker and Nextflow installed

download docker Image
docker pull gbolden101/bulk-rna-pipeline:1.0

Clone Git Repository

If need be, use the test data
https://github.com/csoneson/rnaseqworkflow_exampledata

Complete the Command

nextflow run ./scripts/rna_bulk.nf \
            --sample_sheet ../test_sample_sheet.csv \
            --final_outdir test \
            --genome_fa ../reference_test/Homo_sapiens.GRCh38.dna.chromosome.1.1.10M.fa \
            --gtf ../reference_test/Homo_sapiens.GRCh38.93.1.1.10M.gtf \
            --trim false
            -resume


#use -resume to use cached data
For example if a researcher wants trim their reads -resume will pick up with cached result

Comand Staging Ground and Trial Notes

test_data_origins
https://github.com/csoneson/rnaseqworkflow_exampledata

Instructions for Runnning
conda env create bulk_rna


nextflow run ./scripts/rna_bulk.nf \
            --sample_sheet ../test_sample_sheet.csv \
            --final_outdir test \
            --genome_fa ../reference_test/Homo_sapiens.GRCh38.dna.chromosome.1.1.10M.fa \
            --gtf ../reference_test/Homo_sapiens.GRCh38.93.1.1.10M.gtf \
            --trim false
            -resume


#use -resume to use cached data
#for example if a researcher wants trim their reads -resume will pick up with cached result

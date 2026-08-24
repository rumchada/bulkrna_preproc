
// HAS BUGS DO NOT USE
//STAR Alignment
// Spliced Transcripts Aligner could not read the unzipped
// A little extra gzip commands will be needed in the script of ALIGN process
// crossing my finger Nextflow has built in infrastructure to not publish internal script directories

process ALIGN {
        publishDir "${params.final_outdir}", mode: "copy"

        input:
        tuple val(sample), val(read_type), path(reads)
        path "index_files"

        output:
        // in the feature counts I was seeing missmatched samples
        // It's ideal to keep them within a tuple
        // I did not know how much an issue read continuity would be within the pipeline
        tuple val(sample), path("alignment/${sample}_*.bam"), emit: bam_tuple

        script:
        // Another attribute I appreciate about next flow is
        // contextual directory calling
        // This was probably a thing in snakemake however
        
        //Current bug on Sat 8/22/26: Aligner does not see any reads in the intermediate file
        //checked the work/intermediate file and decompression is fine
        // we are using viral amplicon reads for SARS-CoV2 fastq files
        // we need their gtf/gff and
        // Got a new example set
        // tested with other dataset that's been tested already still nothing
        // FASTQ lines are divisible by 4, nothing is inherently wrong withi Nextflow pipeline
        
        if(read_type == "PE") {

        """
        mkdir -p intermediate_files

        gzip -d -c ${reads[0]} > ./intermediate_files/${sample}_R1.fastq
        gzip -d -c ${reads[1]} > ./intermediate_files/${sample}_R2.fastq

        mkdir -p alignment

        STAR --genomeDir index_files \
            --readFilesIn intermediate_files/${sample}_R1.fastq intermediate_files/${sample}_R2.fastq \
            --outFileNamePrefix alignment/${sample}_ \
            --outSAMtype BAM SortedByCoordinate \
            --outSAMunmapped Within \
            --outSAMattributes Standard
        """

        } else {
        """
        mkdir -p intermediate_files

        gzip -d -c ${reads[0]} > intermediate_files/${sample}_R1.fastq

        mkdir -p alignment

        STAR --genomeDir index_files \
            --readFilesIn intermediate_files/${sample}_R1.fastq \
            --outFileNamePrefix alignment/${sample}_ \
            --outSAMtype BAM SortedByCoordinate \
            --outSAMunmapped Within \
            --outSAMattributes Standard
        """

        }
    }
process HISAT_ALIGN {

    publishDir "${params.final_outdir}", mode: "copy"

    input:
    tuple val(sample), val(read_type), path(reads)
    path index_files
    path genome_fa

    output:
    tuple val(sample), path("alignment/${sample}.bam"), emit: bam_tuple

    script:
    //grab the genome name from the user provide referenc file
    def index_name = genome_fa.baseName

    if (read_type == "PE") {

        """
        mkdir -p intermediate_files
        mkdir -p alignment

        gzip -d -c ${reads[0]} > intermediate_files/${sample}_R1.fastq
        gzip -d -c ${reads[1]} > intermediate_files/${sample}_R2.fastq

        hisat2 \
            -x index_files/${index_name} \
            -1 intermediate_files/${sample}_R1.fastq \
            -2 intermediate_files/${sample}_R2.fastq \
            -S alignment/${sample}.sam

        samtools sort \
            -o alignment/${sample}.bam \
            alignment/${sample}.sam

        rm alignment/${sample}.sam
        """

    } else {

        """
        mkdir -p intermediate_files
        mkdir -p alignment

        gzip -d -c ${reads[0]} > intermediate_files/${sample}_R1.fastq

        hisat2 \
            -x index_files/${index_name} \
            -U intermediate_files/${sample}_R1.fastq \
            -S alignment/${sample}.sam

        samtools sort \
            -o alignment/${sample}.bam \
            alignment/${sample}.sam

        rm alignment/${sample}.sam
        """
    }
}
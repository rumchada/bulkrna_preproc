// sam to bam indexing
// not necessary for the RNA-Seq process
//could be used to show modularity and scaling into Variant Calling
process bam_index {
    publishDir "${params.final_outdir}", mode: "copy"

    input:
    tuple val(sample), val(read_type), path(reads)
    path bam

    output:
    path "alignment/${sample}_*.bam.bai"

    script:
    """
    samtools index ${bam}
    """
}
process flagstat {
    publishDir "${params.final_outdir}", mode: "copy"

    input:
    tuple val(sample), path(bam)

    output:
    path "align_qc/${sample}_flagstat.txt", emit: align_stats

    script:
    """
    mkdir -p align_qc

    samtools flagstat ${bam} > align_qc/${sample}_flagstat.txt
    """
}
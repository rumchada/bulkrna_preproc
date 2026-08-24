process featureCounts {
    publishDir "${params.final_outdir}", mode: "copy"

    input:
    tuple val(sample), path(bam)
    path gtf

    output:
    path "vector_counts/${sample}_counts.tsv", emit: counts

    script:
    //can't manually assign tsv or csv
    //moving into mv for a basic bash
    // this is for the Rscript currently in development
    """
    mkdir -p vector_counts

    featureCounts \
        -p \
        -t exon \
        -g gene_id \
        -a ${gtf} \
        -o vector_counts/${sample}_counts \
        ${bam}

    mv vector_counts/${sample}_counts vector_counts/${sample}_counts.tsv
    """
}
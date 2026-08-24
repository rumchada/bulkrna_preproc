process merge_counts {
    publishDir "${params.final_outdir}", mode: "copy"

    input:
    path r_script
    path vector_counts_path

    output:
    path "count_matrix.tsv"

    script:
    """
    Rscript ${r_script} count_matrix.tsv
    """
}
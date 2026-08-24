process FASTQC {

    publishDir "${params.final_outdir}", mode: 'copy'

    input:
    tuple val(sample), val(read_type), path(reads)

    output:
    path "fastqc_results/*"

    script:
    
    if (read_type == "PE") {
        """
        mkdir -p fastqc_results
        fastqc ${reads[0]} ${reads[1]} --outdir fastqc_results
        """
    }
    else {
        """
        mkdir -p fastqc_results
        fastqc ${reads[0]} --outdir fastqc_results
        """
    }
}
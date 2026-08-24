process trim {

     publishDir "${params.final_outdir}", mode: 'copy'

    input:
    tuple val(sample), val(read_type), path(raw_reads)

    output:
    //outputting a tuple would help lead this into the ALIGN process.
    // personal note: I am really liking emit function. SnakeMake would not allow a subrule tag to 
    // passed down
    tuple val(sample), val(read_type), path("cut_reads/*.fastq.gz"), emit: trimmed_reads
    path "cut_reads/*"

    script:
    // need to add cloud compatibility by Sun (Noted on Fri, 8/21/26)
    // -q quality trim threshold for x reads

    //paired end
    if (read_type == 'PE') {

    """
    mkdir -p cut_reads

    cutadapt -q ${params.quality} \
        --minimum-length ${params.min_length} \
        -o cut_reads/${sample}_R1_trimmed.fastq.gz \
        -p cut_reads/${sample}_R2_trimmed.fastq.gz \
        ${raw_reads[0]} ${raw_reads[1]}
    """

    //single end
    } else {

    """
    mkdir -p cut_reads

    cutadapt -q ${params.quality} \
        --minimum-length ${params.min_length} \
        -o cut_reads/${sample}_R1_trimmed.fastq.gz \
        ${raw_reads[0]}
    """
    }

}//end bracket : process trim 
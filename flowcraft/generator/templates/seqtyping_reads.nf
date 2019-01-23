if ( ! params.org{{ param_id }} && ! params.reference{{ param_id }} ){
  exit 1, "You must provide either --org{{ param_id }} or --reference{{ param_id }} parameters."
} else if( params.org{{ param_id }} && params.reference{{ param_id }} ) {
  exit 1, "You can only provide --org{{ param_id }} or --reference{{ param_id }} parameter. Provided value: '${params.org{{ param_id }}}' '${params.reference{{ param_id }}}'"
}


if ( params.org{{ param_id }} ){
  if ( params.org{{ param_id }}.toString().split(' ').size() != 2 ){
    exit 1, "--org{{ param_id }} parameter must have two words. Provided value: '${params.org{{ param_id }}}'"
  }
  org = "--org ${params.org{{ param_id }}}"
  header_name = "${params.org{{ param_id }}.toString().replaceFirst(/ /, "_")}"
} else {
  org = ""
  header_name = "reference"
}


if ( params.reference{{ param_id }} ){
  params.reference{{ param_id }}.tokenize().each{ entry ->
    if ( ! file(entry).exists() ){
      exit 1, "The reference file ${entry} does not exist. Provided value:  '${params.reference{{ param_id }}}'"
    }
  }
  reference = "--reference ${params.reference{{ param_id }}.tokenize().join(' ')}"
  reference_files = Channel.fromPath(params.reference{{ param_id }}.tokenize()).buffer(size:params.reference{{ param_id }}.tokenize().size())
} else {
  reference = ""
  reference_files = Channel.create()
  reference_files.bind( 'No reference file' )
}


if ( params.type_separator{{ param_id }}.toString().size() != 1 ){
  exit 1, "--type_separator{{ param_id }} parameter must be a single character. Provided value: '${params.type_separator{{ param_id }}}'"
}


if ( params.extra_seq{{ param_id }} ){
  if ( ! params.extra_seq{{ param_id }}.toString().isNumber() ){
    exit 1, "--{{ param_id }}extra_seq{{ param_id }} parameter must be a number. Provided value: '${params.extra_seq{{ param_id }}}'"
  }
  extra_seq = "--extraSeq ${params.extra_seq{{ param_id }}}"
} else {
  extra_seq = ""
}


if ( params.min_cov_presence{{ param_id }} ){
  if ( ! params.min_cov_presence{{ param_id }}.toString().isNumber() ){
    exit 1, "--min_cov_presence{{ param_id }} parameter must be a number. Provided value: '${params.min_cov_presence{{ param_id }}}'"
  }
  min_cov_presence = "--minCovPresence ${params.min_cov_presence{{ param_id }}}"
} else {
  min_cov_presence = ""
}


if ( params.min_cov_call{{ param_id }} ){
  if ( ! params.min_cov_call{{ param_id }}.toString().isNumber() ){
    exit 1, "--min_cov_call{{ param_id }} parameter must be a number. Provided value: '${params.min_cov_call{{ param_id }}}'"
  }
  min_cov_call = "--minCovCall ${params.min_cov_call{{ param_id }}}"
} else {
  min_cov_call = ""
}


if ( params.min_gene_coverage{{ param_id }} ){
  if ( ! params.min_gene_coverage{{ param_id }}.toString().isNumber() ){
    exit 1, "--min_gene_coverage{{ param_id }} parameter must be a number. Provided value: '${params.min_gene_coverage{{ param_id }}}'"
  }
  min_gene_coverage = "--minGeneCoverage ${params.min_gene_coverage{{ param_id }}}"
} else {
  min_gene_coverage = ""
}


if ( ! params.min_depth_coverage{{ param_id }}.toString().isNumber() ){
  exit 1, "--min_depth_coverage{{ param_id }} parameter must be a number. Provided value: '${params.min_depth_coverage{{ param_id }}}'"
}


if ( ! params.min_gene_identity{{ param_id }}.toString().isNumber() ){
  exit 1, "--min_gene_identity{{ param_id }} parameter must be a number. Provided value: '${params.min_gene_identity{{ param_id }}}'"
}


if ( params.bowtie_algo{{ param_id }}.toString().split(' ').size() != 1 ){
  exit 1, "--bowtie_algo{{ param_id }} parameter must only have one alignment mode. Provided value: '${params.bowtie_algo{{ param_id }}}'"
}


not_remove_consensus = params.not_remove_consensus{{ param_id }} ? not_remove_consensus = "--doNotRemoveConsensus" : ""



process seqtyping_reads_{{ pid }} {
    // Send POST request to platform
    {% include "post.txt" ignore missing %}

    tag { sample_id }
    errorStrategy { task.exitStatus == 120 ? 'ignore' : 'ignore' }
    publishDir path: "results/typing/seqtyping_reads/${header_name}/${sample_id}/", mode: 'symlink', overwrite: true, pattern: 'seq_typing.report*'

    input:
    set sample_id, file(fastq) from {{ input_channel }}
    file reference_files

    output:
    file "seq_typing.report*"
    {% with task_name="seqtyping_reads" %}
    {%- include "compiler_channels.txt" ignore missing -%}
    {% endwith %}

    script:
    """
    exit_code=0

    version_str="[{'program':'seq_typing.py','version':'\$(seq_typing.py --version | cut -d \' \' -f 2)'}]"
    echo \$version_str > .versions

    status='error'
    report_str="{'tableRow':[{'sample':'${sample_id}','data':[{'header':'type_${header_name}_seqtyping_reads','value':'NA','table':'typing'}]}]}"

    {
      seq_typing.py reads -f $fastq $org $reference -o ./ -j $task.cpus --typeSeparator ${params.type_separator{{ param_id }}} $extra_seq $min_cov_presence $min_cov_call $min_gene_coverage --minDepthCoverage ${params.min_depth_coverage{{ param_id }}} --minGeneIdentity ${params.min_gene_identity{{ param_id }}} --bowtieAlgo=\'${params.bowtie_algo{{ param_id }}}\' $not_remove_consensus
    } || {
      exit_code=\$?
    }

    if [ \$exit_code -eq 0 ]; then
      status='pass'

      type_found=\$(cat seq_typing.report.txt)

      report_str="{'tableRow':[{'sample':'${sample_id}','data':[{'header':'type_${header_name}_seqtyping_reads','value':'\$type_found','table':'typing'}]}]}"
    fi

    echo \$status > .status
    echo \$report_str > .report.json

    exit \$exit_code
    """
}

{{ forks }}

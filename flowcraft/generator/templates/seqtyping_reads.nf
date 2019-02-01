if ( ! params.org{{ param_id }} && ! params.reference{{ param_id }} ){
  exit 1, "You must provide either --org{{ param_id }} or --reference{{ param_id }} parameters."
} else if( params.org{{ param_id }} && params.reference{{ param_id }} ) {
  exit 1, "You can only provide --org{{ param_id }} or --reference{{ param_id }} parameter. Provided value: '${params.org{{ param_id }}}' '${params.reference{{ param_id }}}'"
}


if ( params.org{{ param_id }} ){
  if ( params.org{{ param_id }}.toString().split(' ').size() != 2 ){
    exit 1, "--org{{ param_id }} parameter must have two words. Provided value: '${params.org{{ param_id }}}'"
  }
  org_{{ pid }} = "--org ${params.org{{ param_id }}}"
  header_name_{{ pid }} = "${params.org{{ param_id }}.toString().replaceFirst(/ /, "_")}"
} else {
  org_{{ pid }} = ""
  header_name_{{ pid }} = "reference"
}


if ( params.reference{{ param_id }} ){
  params.reference{{ param_id }}.tokenize().each{ entry ->
    if ( ! file(entry).exists() ){
      exit 1, "The reference file ${entry} does not exist. Provided value:  '${params.reference{{ param_id }}}'"
    }
  }
  reference_{{ pid }} = "--reference ${params.reference{{ param_id }}.tokenize().join(' ')}"
  IN_reference_files_{{ pid }} = Channel.fromPath(params.reference{{ param_id }}.tokenize()).buffer(size:params.reference{{ param_id }}.tokenize().size())
} else {
  reference_{{ pid }} = ""
  IN_reference_files_{{ pid }} = file('.reference_files_{{ pid }}.file', hidden: true)
  IN_reference_files_{{ pid }}.text = 'No reference file'
  IN_reference_files_{{ pid }} = Channel.fromPath(IN_reference_files_{{ pid }})
}


if ( params.type_separator{{ param_id }}.toString().size() != 1 ){
  exit 1, "--type_separator{{ param_id }} parameter must be a single character. Provided value: '${params.type_separator{{ param_id }}}'"
}


if ( params.extra_seq{{ param_id }} ){
  if ( ! params.extra_seq{{ param_id }}.toString().isNumber() ){
    exit 1, "--{{ param_id }}extra_seq{{ param_id }} parameter must be a number. Provided value: '${params.extra_seq{{ param_id }}}'"
  }
  extra_seq_{{ pid }} = "--extraSeq ${params.extra_seq{{ param_id }}}"
} else {
  extra_seq_{{ pid }} = ""
}


if ( params.min_cov_presence{{ param_id }} ){
  if ( ! params.min_cov_presence{{ param_id }}.toString().isNumber() ){
    exit 1, "--min_cov_presence{{ param_id }} parameter must be a number. Provided value: '${params.min_cov_presence{{ param_id }}}'"
  }
  min_cov_presence_{{ pid }} = "--minCovPresence ${params.min_cov_presence{{ param_id }}}"
} else {
  min_cov_presence_{{ pid }} = ""
}


if ( params.min_cov_call{{ param_id }} ){
  if ( ! params.min_cov_call{{ param_id }}.toString().isNumber() ){
    exit 1, "--min_cov_call{{ param_id }} parameter must be a number. Provided value: '${params.min_cov_call{{ param_id }}}'"
  }
  min_cov_call_{{ pid }} = "--minCovCall ${params.min_cov_call{{ param_id }}}"
} else {
  min_cov_call_{{ pid }} = ""
}


if ( params.min_gene_coverage{{ param_id }} ){
  if ( ! params.min_gene_coverage{{ param_id }}.toString().isNumber() ){
    exit 1, "--min_gene_coverage{{ param_id }} parameter must be a number. Provided value: '${params.min_gene_coverage{{ param_id }}}'"
  }
  min_gene_coverage_{{ pid }} = "--minGeneCoverage ${params.min_gene_coverage{{ param_id }}}"
} else {
  min_gene_coverage_{{ pid }} = ""
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


if ( params.max_num_map_loc{{ param_id }} ){
  if ( ! params.max_num_map_loc{{ param_id }}.toString().isNumber() ){
    exit 1, "--max_num_map_loc{{ param_id }} parameter must be a number. Provided value: '${params.max_num_map_loc{{ param_id }}}'"
  }
  max_num_map_loc{{ pid }} = "--maxNumMapLoc ${params.max_num_map_loc{{ param_id }}}"
} else {
  max_num_map_loc{{ pid }} = ""
}


if ( ! (params.not_remove_consensus{{ param_id }} instanceof Boolean) ){
  exit 1, "--not_remove_consensus{{ param_id }} parameter must be true or false. Provided value: '${params.not_remove_consensus{{ param_id }}}'"
} else {
  not_remove_consensus_{{ pid }} = params.not_remove_consensus{{ param_id }} ? "--doNotRemoveConsensus" : ""
}


if ( ! (params.save_new_allele{{ param_id }} instanceof Boolean) ){
  exit 1, "--save_new_allele{{ param_id }} parameter must be true or false. Provided value: '${params.save_new_allele{{ param_id }}}'"
} else {
  save_new_allele{{ pid }} = params.save_new_allele{{ param_id }} ? "--saveNewAllele" : ""
}



process seqtyping_reads_{{ pid }} {
    // Send POST request to platform
    {% include "post.txt" ignore missing %}

    tag { sample_id }
    errorStrategy { task.exitStatus == 120 ? 'ignore' : 'ignore' }
    publishDir path: "results/typing/seqtyping/reads/${header_name_{{ pid }}}/seqtyping_reads_{{ pid }}/${sample_id}/", pattern: 'seq_typing.report*'

    input:
    set sample_id, file(fastq) from {{ input_channel }}
    each file(reference_files) from IN_reference_files_{{ pid }}
    val type_separator from Channel.value(params.type_separator{{ param_id }})
    val min_depth_coverage from Channel.value(params.min_depth_coverage{{ param_id }})
    val min_gene_identity from Channel.value(params.min_gene_identity{{ param_id }})
    val bowtie_algo from Channel.value(params.bowtie_algo{{ param_id }})

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
    report_str="{'tableRow':[{'sample':'${sample_id}','data':[{'header':'${header_name_{{ pid }}}_seqtyping_reads','value':'NA','table':'typing'}]}]}"

    {
      seq_typing.py reads -f $fastq $org_{{ pid }} $reference_{{ pid }} \
                          -s $sample_id -o ./ -j $task.cpus \
                          --typeSeparator $type_separator $extra_seq_{{ pid }} $min_cov_presence_{{ pid }} \
                          $min_cov_call_{{ pid }} $min_gene_coverage_{{ pid }} --minDepthCoverage $min_depth_coverage \
                          --minGeneIdentity $min_gene_identity --bowtieAlgo=\'$bowtie_algo\' $max_num_map_loc{{ pid }} \
                          $not_remove_consensus_{{ pid }} $save_new_allele{{ pid }}
    } || {
      exit_code=\$?
    }

    if [ \$exit_code -eq 0 ]; then
      status='pass'

      type_found=\$(cat seq_typing.report.txt)

      report_str="{'tableRow':[{'sample':'${sample_id}','data':[{'header':'${header_name_{{ pid }}}_seqtyping_reads','value':'\$type_found','table':'typing'}]}]}"
    fi

    echo \$status > .status
    echo \$report_str > .report.json

    exit \$exit_code
    """
}

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
  reference_{{ pid }} = "--blast ${params.reference{{ param_id }}.tokenize().join(' ')} --type nucl"
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


if ( params.min_gene_coverage{{ param_id }} ){
  if ( ! params.min_gene_coverage{{ param_id }}.toString().isNumber() ){
    exit 1, "--min_gene_coverage{{ param_id }} parameter must be a number. Provided value: '${params.min_gene_coverage{{ param_id }}}'"
  }
  min_gene_coverage_{{ pid }} = "--minGeneCoverage ${params.min_gene_coverage{{ param_id }}}"
} else {
  min_gene_coverage_{{ pid }} = ""
}


if ( ! params.min_gene_identity{{ param_id }}.toString().isNumber() ){
  exit 1, "--min_gene_identity{{ param_id }} parameter must be a number. Provided value: '${params.min_gene_identity{{ param_id }}}'"
}


process seqtyping_assembly_{{ pid }} {
    // Send POST request to platform
    {% include "post.txt" ignore missing %}

    tag { sample_id }
    errorStrategy { task.exitStatus == 120 ? 'ignore' : 'ignore' }
    publishDir path: "results/typing/seqtyping/assembly/${header_name_{{ pid }}}/seqtyping_assembly_{{ pid }}/${sample_id}/", pattern: 'seq_typing.report*'

    input:
    set sample_id, file(fasta) from {{ input_channel }}
    each file(reference_files) from IN_reference_files_{{ pid }}
    val type_separator from Channel.value(params.type_separator{{ param_id }})
    val min_gene_identity from Channel.value(params.min_gene_identity{{ param_id }})

    output:
    file "seq_typing.report*"
    {% with task_name="seqtyping_assembly" %}
    {%- include "compiler_channels.txt" ignore missing -%}
    {% endwith %}

    script:
    """
    exit_code=0

    version_str="[{'program':'seq_typing.py','version':'\$(seq_typing.py --version | cut -d \' \' -f 2)'}]"
    echo \$version_str > .versions

    status='error'
    report_str="{'tableRow':[{'sample':'${sample_id}','data':[{'header':'${header_name_{{ pid }}}_seqtyping_assembly','value':'NA','table':'typing'}]}]}"

    {
      seq_typing.py assembly -f $fasta $org_{{ pid }} $reference_{{ pid }} -o ./ -j $task.cpus \
                    --typeSeparator $type_separator $min_gene_coverage_{{ pid }} --minGeneIdentity $min_gene_identity

    } || {
      exit_code=\$?
    }

    if [ \$exit_code -eq 0 ]; then
      status='pass'

      type_found=\$(cat seq_typing.report.txt)

      report_str="{'tableRow':[{'sample':'${sample_id}','data':[{'header':'${header_name_{{ pid }}}_seqtyping_assembly','value':'\$type_found','table':'typing'}]}]}"
    fi

    echo \$status > .status
    echo \$report_str > .report.json

    exit \$exit_code
    """
}

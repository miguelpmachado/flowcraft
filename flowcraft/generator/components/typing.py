try:
    from generator.process import Process
except ImportError:
    from flowcraft.generator.process import Process


class SeqTyping(Process):
    """

    """

    def __init__(self, **kwargs):

        super().__init__(**kwargs)

        self.input_type = "fastq"
        self.output_type = None

        self.link_start = None

        self.directives = {"seq_typing": {
            "cpus": 4,
            "memory": "'4GB'",
            "container": "flowcraft/seq_typing",
            "version": "2.0-1"
        }}

        self.params = {
            "referenceFileO": {
                "default": "null",
                "description":
                    "Fasta file containing reference sequences. If more"
                    "than one file is passed via the 'referenceFileH parameter"
                    ", a reference sequence for each file will be determined. "
            },
            "referenceFileH": {
                "default": "null",
                "description":
                    "Fasta file containing reference sequences. If more"
                    "than one file is passed via the 'referenceFileO parameter"
                    ", a reference sequence for each file will be determined. "
            }
        }


class PathoTyping(Process):
    """

    """

    def __init__(self, **kwargs):

        super().__init__(**kwargs)

        self.input_type = "fastq"
        self.output_type = None

        self.ignore_type = True

        self.params = {
            "species": {
                "default": "null",
                "description":
                    "Species name. Must be the complete species name with"
                    "genus and species, e.g.: 'Yersinia enterocolitica'. "
            }
        }

        self.link_start = None
        self.link_end.append({"link": "MAIN_raw",
                              "alias": "SIDE_PathoType_raw"})

        self.directives = {"patho_typing": {
            "cpus": 4,
            "memory": "'4GB'",
            "container": "flowcraft/patho_typing",
            "version": "0.3.0-1"
        }}


class Sistr(Process):

    def __init__(self, **kwargs):

        super().__init__(**kwargs)

        self.input_type = "fasta"
        self.output_type = None

        self.directives = {"sistr": {
            "cpus": 4,
            "memory": "'4GB'",
            "container": "ummidock/sistr_cmd",
            "version": "1.0.2"
        }}


class Momps(Process):

    def __init__(self, **kwargs):

        super().__init__(**kwargs)

        self.input_type = "fasta"
        self.output_type = None

        self.link_end.append({"link": "__fastq", "alias": "_LAST_fastq"})

        self.params = {
            "clearInput": {
                "default": "false",
                "description":
                    "Permanently removes temporary input files. This option "
                    "is only useful to remove temporary files in large "
                    "workflows and prevents nextflow's resume functionality. "
                    "Use with caution."
            }
        }

        self.directives = {
            "momps": {
                "cpus": 3,
                "memory": "'4GB'",
                "container": "flowcraft/momps",
                "version": "0.1.1-1"
            }
        }


class DengueTyping(Process):
    """

    """

    def __init__(self, **kwargs):

        super().__init__(**kwargs)

        self.input_type = "fasta"
        self.output_type = "fasta"

        self.link_start.extend(["_ref_seqTyping"])

        self.params = {
            "reference": {
                "default": "true",
                "description":
                    "Retrieves the sequence of the closest reference."
            }
        }

        self.directives = {"dengue_typing": {
            "cpus": 4,
            "memory": "'4GB'",
            "container": "flowcraft/seq_typing",
            "version": "2.0-1"
        }}

        self.status_channels = [
            "dengue_typing"
        ]


class Seqsero2Reads(Process):
    """SeqSero2 for reads process template interface

    This process is set with:

        - ``input_type``: fastq
        - ``output_type``: None
        - ``ptype``: typing
    """

    def __init__(self, **kwargs):

        super().__init__(**kwargs)

        self.input_type = "fastq"
        self.output_type = None

        self.directives = {
            "seqsero2_reads": {
                "cpus": 1,
                "memory": "{ 1.GB * task.attempt }",
                "container": "ummidock/seqsero2",
                "version": "alpha-test-1",
                "scratch": "true"
            }
        }


class Seqsero2Assembly(Process):
    """SeqSero2 for assembly process template interface

    This process is set with:

        - ``input_type``: fasta
        - ``output_type``: None
        - ``ptype``: typing
    """

    def __init__(self, **kwargs):

        super().__init__(**kwargs)

        self.input_type = "fasta"
        self.output_type = None

        self.directives = {
            "seqsero2_assembly": {
                "cpus": 1,
                "memory": "{ 1.GB * task.attempt }",
                "container": "ummidock/seqsero2",
                "version": "alpha-test-1",
                "scratch": "true"
            }
        }


# TODO: change seq_typing image tag
class StxSeqtyping(Process):
    """ecoli_stx_subtyping.py for reads process template interface

    This process is set with:

        - ``input_type``: fastq
        - ``output_type``: None
        - ``ptype``: typing
    """

    def __init__(self, **kwargs):

        super().__init__(**kwargs)

        self.input_type = "fastq"
        self.output_type = None

        self.params = {
            "stx2covered": {
                "default": '100',
                "description": "Minimal percentage of sequence covered to consider "
                               "extra stx2 subtypes (value between [0, 100])."
            },
            "stx2identity": {
                "default": '99.5',
                "description": "Minimal sequence identity to consider extra stx2 "
                               "subtypes (value between [0, 100])."
            }
        }

        self.directives = {
            "stx_seqtyping": {
                "cpus": 2,
                "memory": "{ 1.GB * task.cpus * task.attempt }",
                "container": "ummidock/seq_typing",
                "version": "2.2-01",
                "scratch": "true"
            }
        }


# TODO: change seq_typing image tag
class SeqtypingReads(Process):
    """seq_typing.py for reads process template interface

    This process is set with:

        - ``input_type``: fastq
        - ``output_type``: None
        - ``ptype``: typing
    """

    def __init__(self, **kwargs):

        super().__init__(**kwargs)

        self.input_type = "fastq"
        self.output_type = None

        self.params = {
            "org": {
                "default": 'null',
                "description": "Need to use either 'org' or 'reference' parameter. "
                               "Organism option with reference sequences provided "
                               "together with seq_typing.py for typing "
                               "('seqtyping/reference_sequences/' folder). "
                               "Some options: ['Escherichia coli', 'Haemophilus influenzae',"
                               "'GBS sero', 'GBS pili', 'GBS surf']. "
                               "See https://github.com/B-UMMI/seq_typing for more "
                               "information."
            },
            "reference": {
                "default": 'null',
                "description": "Need to use either 'org' or 'reference' parameter. "
                               "Path to reference sequences file. If more "
                               "than one file is passed, a type for each file will be "
                               "determined. Give the files name in the same order that "
                               "the type must be determined."
            },
            "type_separator": {
                "default": '"_"',
                "description": "Last single character separating the general sequence "
                               "header from the last part containing the type"
            },
            "extra_seq": {
                "default": 'null',
                "description": "Sequence length added to both ends of target sequences "
                               "(usefull to improve reads mapping to the target one) "
                               "that will be trimmed in ReMatCh outputs "
                               "(default when not using --org: 0)"
            },
            "min_cov_presence": {
                "default": 'null',
                "description": "Reference position minimum coverage depth to consider "
                               "the position to be present in the sample "
                               "(default when not using --org: 5)"
            },
            "min_cov_call": {
                "default": 'null',
                "description": "Reference position minimum coverage depth to perform a "
                               "base call (default when not using --org: 10)"
            },
            "min_gene_coverage": {
                "default": 'null',
                "description": "Minimum percentage of target reference sequence "
                               "covered to consider a sequence to be present (value "
                               "between [0, 100]) (default when not using --org: 60)"
            },
            "min_depth_coverage": {
                "default": '2',
                "description": "Minimum depth of coverage of target reference sequence "
                               "to consider a sequence to be present"
            },
            "min_gene_identity": {
                "default": '80',
                "description": "Minimum percentage of identity of reference sequence "
                               "covered to consider a gene to be present (value "
                               "between [0, 100]). One INDEL will be considered as one "
                               "difference."
            },
            "bowtie_algo": {
                "default": 'null',
                "description": "Bowtie2 alignment mode. It can be an end-to-end "
                               "alignment (unclipped alignment) or local alignment "
                               "(soft clipped alignment). Also, can choose between "
                               "fast or sensitive alignments. Please check Bowtie2 "
                               "manual for extra information: "
                               "http://bowtie-bio.sourceforge.net/bowtie2/index.shtml . "
                               "(default when not using --org: '--very-sensitive-local')"
            },
            "max_num_map_loc": {
                "default": 'null',
                "description": "Maximum number of locations to which a read can map "
                               "(sometimes useful when mapping against similar "
                               "sequences) (default when not using --org: 1"
            },
            "not_remove_consensus": {
                "default": 'false',
                "description": "Do not remove ReMatCh consensus sequences"
            },
            "save_new_allele": {
                "default": 'false',
                "description": "Save the new allele found for the selected type"
            }
        }

        self.directives = {
            "seqtyping_reads": {
                "cpus": 2,
                "memory": "{ 1.GB * task.cpus * task.attempt }",
                "container": "ummidock/seq_typing",
                "version": "dev",
                "scratch": "true"
            }
        }


# TODO: change seq_typing image tag
class SeqtypingAssembly(Process):
    """seq_typing.py for assemblies process template interface

    This process is set with:

        - ``input_type``: fasta
        - ``output_type``: None
        - ``ptype``: typing
    """

    def __init__(self, **kwargs):

        super().__init__(**kwargs)

        self.input_type = "fasta"
        self.output_type = None

        self.params = {
            "org": {
                "default": 'null',
                "description": "Need to use either 'org' or 'reference' parameter. "
                               "Organism option with DB sequences files provided "
                               "together with seq_typing.py for typing "
                               "('seqtyping/reference_sequences/' folder). "
                               "Some options: ['Escherichia coli', 'Haemophilus influenzae',"
                               "'GBS sero', 'GBS pili', 'GBS surf']. "
                               "See https://github.com/B-UMMI/seq_typing for more "
                               "information."
            },
            "reference": {
                "default": 'null',
                "description": "Need to use either 'org' or 'reference' parameter. "
                               "Path to DB sequences files. If more "
                               "than one DB file is passed, a type for each file will be "
                               "determined. Give the files name in the same order that "
                               "the type must be determined."
            },
            "type_separator": {
                "default": '"_"',
                "description": "Last single character separating the general sequence "
                               "header from the last part containing the type"
            },
            "min_gene_coverage": {
                "default": 'null',
                "description": "Minimum percentage of target reference sequence "
                               "covered to consider a sequence to be present (value "
                               "between [0, 100]) (default when not using --org: 60)"
            },
            "min_gene_identity": {
                "default": '80',
                "description": "Minimum percentage of identity of reference sequence "
                               "covered to consider a gene to be present (value "
                               "between [0, 100]). One INDEL will be considered as one "
                               "difference."
            },
            "saveNewAllele": {
                "default": 'false',
                "description": "Save the new allele found for the selected type"
            }
        }

        self.directives = {
            "seqtyping_assembly": {
                "cpus": 1,
                "memory": "{ 1.GB * task.cpus * task.attempt }",
                "container": "ummidock/seq_typing",
                "version": "dev",
                "scratch": "true"
            }
        }

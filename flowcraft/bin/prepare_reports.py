#!/usr/bin/env python3

import sys
import json
import logging

from os.path import dirname, abspath

logger = logging.getLogger("main.{}".format(__name__))


def write_json(report_json, version_json, trace_file, task_name,
               project_name, sample_name, pid):

    logging.info("Parsing report JSON")
    try:
        with open(report_json) as fh:
            reports = json.load(fh)
            if "task" in reports:
                del reports["task"]
    except json.JSONDecodeError:
        logging.warning("Could not parse report JSON: {}".format(report_json))
        reports = {}

    logging.info("Parsing versions JSON")
    try:
        with open(version_json) as fh:
            versions = json.load(fh)
    except json.JSONDecodeError:
        logging.warning("Could not parse versions JSON: {}".format(
            report_json))
        versions = []

    logging.info("Parsing trace file")
    with open(trace_file) as fh:
        trace = fh.readlines()

    report = {
        "reportJson": reports,
        "versions": versions,
        "trace": trace,
        "processId": pid,
        "pipelineId": 1,
        "projectid": 1,
        "userId": 1,
        "username": "user",
        "processName": task_name,
        "workdir": dirname(abspath(report_json))
    }

    logging.info("Dumping final report JSON file")
    logging.debug("Final JSON file: {}".format(report))
    with open("{}_{}_report.json".format(task_name, sample_name), "w") \
            as report_fh:
        report_fh.write(json.dumps(report, separators=(",", ":")))


def main():

    # Fetch arguments
    args = sys.argv[1:]
    report_json = args[0]
    version_json = args[1]
    trace = args[2]
    sample_name = args[3]
    task_name = args[4]
    project_name = args[5]
    pid = args[6]
    logging.debug("Report JSON: {}".format(report_json))
    logging.debug("Version JSON: {}".format(version_json))
    logging.debug("Trace file: {}".format(trace))
    logging.debug("Sample name: {}".format(sample_name))
    logging.debug("Task name: {}".format(task_name))
    logging.debug("Project name: {}".format(project_name))
    logging.debug("Process ID: {}".format(pid))

    # Write the final report JSON that compiles all information
    write_json(report_json, version_json, trace, task_name,
               project_name, sample_name, pid)


main()

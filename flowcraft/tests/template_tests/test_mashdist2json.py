import os
import json
import pytest
import flowcraft.templates.mashdist2json as mashdist2json


@pytest.fixture
def fetch_file(tmpdir, request):
    # create a temporary file mash screen txt file
    mash_file = tmpdir.join("test_depth_file.txt")
    mash_file.write("ACC1\tseq1\t0\t900/1000")

    mashdist2json.main(str(mash_file), "0.5", "test", "assembly_file")
    result_dict = json.load(open("{}.json".format(
            str(mash_file).split(".")[0])))

    # finalizer statement that removes .report.json
    def remove_test_files():
        os.remove(".report.json")
    request.addfinalizer(remove_test_files)

    return result_dict, str(mash_file)


def test_generate_file(fetch_file):
    """
    This function tests if the files generated by this template script are
    created
    """
    _, mash_file = fetch_file
    assert os.path.isfile("{}.json".format(mash_file.split(".")[0]))


def test_generate_report(fetch_file):
    """
    This tests if the report.json file is generated
    """
    assert os.path.isfile(".report.json")


def test_generated_dict(fetch_file):
    """
    This function checks if the file contains a dict
    """
    result_dict, _ = fetch_file
    assert isinstance(result_dict, dict)


def test_generated_dict_contents(fetch_file):
    # the expected result from loading the dictionary in the generated file
    expected_dict = {"ACC1": [1.0, 0.9, "seq1"]}
    result_dict, _ = fetch_file
    assert result_dict == expected_dict
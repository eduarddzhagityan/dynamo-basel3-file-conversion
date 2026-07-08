from pathlib import Path


def test_output_directory_exists():
    assert Path("output").exists(), "Missing output directory."


def test_compliance_report_exists():
    assert Path("output/compliance_report.json").exists(), \
        "Missing compliance_report.json."


def test_findings_exists():
    assert Path("output/findings.csv").exists(), \
        "Missing findings.csv."


def test_rwa_summary_exists():
    assert Path("output/rwa_summary.csv").exists(), \
        "Missing rwa_summary.csv."

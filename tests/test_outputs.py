import csv
import json
from pathlib import Path


OUTPUT_DIR = Path("output")
EXPECTED_FILES = {
    "compliance_report.json",
    "findings.csv",
    "rwa_summary.csv",
}


def _load_json(path):
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def _load_csv(path):
    with path.open("r", encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def _assert_close(actual, expected, tolerance=0.01):
    assert abs(float(actual) - expected) <= tolerance


def test_output_directory_contains_exactly_required_files():
    assert OUTPUT_DIR.exists(), "Missing output directory."
    assert OUTPUT_DIR.is_dir(), "output must be a directory."

    actual_files = {p.name for p in OUTPUT_DIR.iterdir() if p.is_file()}
    assert actual_files == EXPECTED_FILES


def test_compliance_report_schema_and_values():
    report = _load_json(OUTPUT_DIR / "compliance_report.json")

    assert set(report.keys()) == {
        "bank_id",
        "reporting_date",
        "overall_status",
        "primary_reason",
        "capital_ratios",
        "requirements",
        "finding_count",
    }

    assert report["bank_id"] == "B001"
    assert report["reporting_date"] == "2025-12-31"
    assert report["overall_status"] == "Not Fully Compliant"
    assert report["primary_reason"] == "Capital Conservation Buffer breach"
    assert report["finding_count"] == 3

    ratios = report["capital_ratios"]
    _assert_close(ratios["cet1_ratio"], 6.11)
    _assert_close(ratios["tier1_ratio"], 15.31)
    _assert_close(ratios["total_capital_ratio"], 18.07)
    _assert_close(ratios["leverage_ratio"], 4.08)

    assert report["requirements"] == {
        "cet1_minimum_met": True,
        "capital_conservation_buffer_met": False,
        "tier1_minimum_met": True,
        "total_capital_minimum_met": True,
        "leverage_ratio_met": True,
    }


def test_findings_csv_schema_and_required_findings():
    rows = _load_csv(OUTPUT_DIR / "findings.csv")

    assert rows, "findings.csv must contain supervisory findings."
    assert list(rows[0].keys()) == [
        "finding_id",
        "severity",
        "category",
        "reference",
        "basel_rule",
        "description",
    ]

    assert len(rows) == 3

    text = " ".join(
        " ".join(str(value) for value in row.values()) for row in rows
    ).lower()

    assert "capital conservation buffer" in text
    assert "col002" in text
    assert "ineligible collateral" in text
    assert "e004" in text
    assert "sme" in text


def test_rwa_summary_csv_schema_and_core_metrics():
    rows = _load_csv(OUTPUT_DIR / "rwa_summary.csv")

    assert rows, "rwa_summary.csv must contain supervisory calculations."
    assert list(rows[0].keys()) == ["metric", "value"]

    metrics = {row["metric"].strip().lower(): row["value"] for row in rows}

    required_metrics = {
        "adjusted_cet1",
        "credit_rwa",
        "off_balance_sheet_rwa",
        "total_rwa",
        "total_exposure_measure",
    }

    assert required_metrics.issubset(metrics.keys())

    _assert_close(metrics["adjusted_cet1"], 25000000, tolerance=1)
    _assert_close(metrics["credit_rwa"], 357500000, tolerance=1)
    _assert_close(metrics["off_balance_sheet_rwa"], 48375000, tolerance=1)
    _assert_close(metrics["total_rwa"], 398375000, tolerance=1)

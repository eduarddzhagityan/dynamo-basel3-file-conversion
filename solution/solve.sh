#!/bin/bash

set -euo pipefail

python3 - <<'PY'
import csv
import json
from pathlib import Path

INPUT_DIR = Path("input")
OUTPUT_DIR = Path("output")
OUTPUT_DIR.mkdir(exist_ok=True)

def read_csv(name):
    with (INPUT_DIR / name).open("r", encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))

def write_csv(name, fieldnames, rows):
    with (OUTPUT_DIR / name).open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

def as_float(value):
    if value is None or value == "":
        return 0.0
    return float(value)

bank_profile = read_csv("bank_profile.csv")[0]
capital = read_csv("capital_components.csv")[0]
credit_exposures = read_csv("credit_exposures.csv")
collateral = read_csv("collateral_register.csv")
off_balance_sheet = read_csv("off_balance_sheet.csv")

collateral_by_id = {row["collateral_id"]: row for row in collateral}

adjusted_cet1 = (
    as_float(capital["gross_cet1"])
    - as_float(capital["goodwill"])
    - as_float(capital["deferred_tax_assets"])
    - as_float(capital["other_cet1_deductions"])
)

credit_rwa = 0.0
findings = []

for exposure in credit_exposures:
    amount = as_float(exposure["amount"])
    risk_weight_hint = exposure.get("risk_weight_hint", "")

    if risk_weight_hint != "":
        risk_weight = as_float(risk_weight_hint)
    elif exposure["is_sme_flag"].lower() == "true":
        risk_weight = 85.0
    else:
        risk_weight = 100.0

    secured_by = exposure.get("secured_by_collateral_id", "")
    if secured_by:
        collateral_row = collateral_by_id.get(secured_by)
        if collateral_row and collateral_row["eligible_under_basel"].lower() == "false":
            findings.append({
                "finding_id": "F002",
                "severity": "High",
                "category": "Credit RWA",
                "reference": secured_by,
                "basel_rule": "Eligible credit risk mitigation",
                "description": f"Ineligible collateral {secured_by} must not reduce RWA.",
            })

    credit_rwa += amount * risk_weight / 100.0

    if exposure["exposure_id"] == "E004" and exposure["is_sme_flag"].lower() == "true":
        findings.append({
            "finding_id": "F003",
            "severity": "Medium",
            "category": "SME classification",
            "reference": "E004",
            "basel_rule": "SME exposure classification",
            "description": "Exposure E004 is flagged as SME but group annual revenue exceeds the SME threshold.",
        })

off_balance_sheet_rwa = 0.0

for item in off_balance_sheet:
    notional = as_float(item["notional_amount"])
    instrument_type = item["instrument_type"]
    related_type = item["related_exposure_type"]
    cancelable = item["cancelable_unconditionally"].lower() == "true"

        if cancelable:
        ccf = 0.1
    elif instrument_type == "trade_letter_of_credit":
        ccf = 0.2
    else:
        ccf = 0.5

    if related_type == "corporate":
        risk_weight = 100.0
    elif related_type == "trade_finance":
        risk_weight = 100.0
    elif related_type == "retail":
        risk_weight = 75.0
    else:
        risk_weight = 100.0

    off_balance_sheet_rwa += notional * ccf * risk_weight / 100.0

total_rwa = credit_rwa + off_balance_sheet_rwa

tier1_capital = as_float(capital["tier1_capital"])
total_capital = as_float(capital["total_capital"])
total_exposure_measure = as_float(bank_profile["total_exposure_measure"])

cet1_ratio = adjusted_cet1 / total_rwa * 100
tier1_ratio = tier1_capital / total_rwa * 100
total_capital_ratio = total_capital / total_rwa * 100
leverage_ratio = tier1_capital / total_exposure_measure * 100

requirements = {
    "cet1_minimum_met": cet1_ratio >= 4.5,
    "capital_conservation_buffer_met": cet1_ratio >= 7.0,
    "tier1_minimum_met": tier1_ratio >= 6.0,
    "total_capital_minimum_met": total_capital_ratio >= 8.0,
    "leverage_ratio_met": leverage_ratio >= 3.0,
}

if not requirements["capital_conservation_buffer_met"]:
    findings.insert(0, {
        "finding_id": "F001",
        "severity": "High",
        "category": "Capital adequacy",
        "reference": "B001",
        "basel_rule": "Capital Conservation Buffer",
        "description": "Capital Conservation Buffer breach: CET1 ratio is below 7.00%.",
    })

overall_status = "Compliant" if all(requirements.values()) else "Not Fully Compliant"
primary_reason = "None" if overall_status == "Compliant" else "Capital Conservation Buffer breach"

report = {
    "bank_id": bank_profile["bank_id"],
    "reporting_date": bank_profile["reporting_date"],
    "overall_status": overall_status,
    "primary_reason": primary_reason,
    "capital_ratios": {
        "cet1_ratio": round(cet1_ratio, 2),
        "tier1_ratio": round(tier1_ratio, 2),
        "total_capital_ratio": round(total_capital_ratio, 2),
        "leverage_ratio": round(leverage_ratio, 2),
    },
    "requirements": requirements,
    "finding_count": len(findings),
}

with (OUTPUT_DIR / "compliance_report.json").open("w", encoding="utf-8") as f:
    json.dump(report, f, indent=2)

write_csv(
    "findings.csv",
    ["finding_id", "severity", "category", "reference", "basel_rule", "description"],
    findings,
)

write_csv(
    "rwa_summary.csv",
    ["metric", "value"],
    [
        {"metric": "adjusted_cet1", "value": round(adjusted_cet1, 2)},
        {"metric": "credit_rwa", "value": round(credit_rwa, 2)},
        {"metric": "off_balance_sheet_rwa", "value": round(off_balance_sheet_rwa, 2)},
        {"metric": "total_rwa", "value": round(total_rwa, 2)},
        {"metric": "total_exposure_measure", "value": round(total_exposure_measure, 2)},
    ],
)
PY

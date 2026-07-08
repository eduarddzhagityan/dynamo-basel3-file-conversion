# Basel III Supervisory Compliance Review

## Background

You are acting as a prudential supervisory analyst responsible for reviewing a synthetic commercial bank's Basel III capital adequacy position.

The objective is to perform a deterministic supervisory assessment using only the information provided in the input files and the Basel III rules defined below.

Do not use external data, assumptions, or regulatory interpretations beyond those explicitly stated in this document.

---

# Input files

The input directory contains the following files:

- `input/bank_profile.csv`
- `input/capital_components.csv`
- `input/credit_exposures.csv`
- `input/collateral_register.csv`
- `input/off_balance_sheet.csv`

Treat all input data as internally consistent.

---

# Required outputs

Create exactly the following files:

- `output/compliance_report.json`
- `output/findings.csv`
- `output/rwa_summary.csv`

No additional output files should be created.

---

# Supervisory objective

Your review must:

1. Calculate adjusted CET1 capital.
2. Calculate credit Risk-Weighted Assets (RWA).
3. Calculate off-balance-sheet RWA.
4. Calculate total RWA.
5. Calculate Basel III capital ratios.
6. Determine compliance with each minimum requirement.
7. Identify every supervisory finding.
8. Produce the final supervisory conclusion.

---

# Basel III calculation rules

## Adjusted CET1

Adjusted CET1 is calculated as:

```
Adjusted CET1 =
Gross CET1
− Goodwill
− Deferred Tax Assets
− Other CET1 Deductions
```

---

## Capital ratios

```
CET1 Ratio =
Adjusted CET1 / Total RWA × 100
```

```
Tier 1 Ratio =
Tier 1 Capital / Total RWA × 100
```

```
Total Capital Ratio =
Total Capital / Total RWA × 100
```

```
Leverage Ratio =
Tier 1 Capital / Total Exposure Measure × 100
```

---

# Minimum regulatory requirements

| Requirement | Minimum |
|------------|---------:|
| CET1 | 4.5% |
| CET1 + Capital Conservation Buffer | 7.0% |
| Tier 1 | 6.0% |
| Total Capital | 8.0% |
| Leverage Ratio | 3.0% |

---

# Risk-weight rules

Apply the following deterministic risk weights.

| Exposure | Risk Weight |
|----------|------------:|
| Corporate | 100% |
| Eligible SME | 85% |
| Residential Mortgage | 35% |
| Past-Due Loan | 150% |
| Sovereign | 0% |

---

# SME eligibility

An exposure qualifies as SME only if BOTH conditions are satisfied:

- `is_sme_flag = true`
- `group_annual_revenue <= 50,000,000`

If either condition fails, the exposure must not receive SME treatment.

---

# Collateral eligibility

Collateral may reduce regulatory exposure only if:

```
eligible_under_basel = true
```

Collateral that does not satisfy this requirement must be ignored for supervisory purposes.

---

# Off-balance-sheet exposures

Apply the following Credit Conversion Factors (CCF):

| Instrument | CCF |
|-----------|----:|
| Undrawn Credit Commitment | 50% |
| Trade Letter of Credit | 20% |
| Unconditionally Cancelable Commitment | 10% |

Calculate:

```
Off-Balance-Sheet RWA =
Notional Amount × CCF × 100%
```

---

# Output file specifications

## output/compliance_report.json

The JSON file shall contain:

- bank_id
- reporting_date
- overall_status
- primary_reason
- capital_ratios
- requirements
- finding_count

Example structure:

```json
{
  "bank_id": "B001",
  "reporting_date": "2025-12-31",
  "overall_status": "Not Fully Compliant",
  "primary_reason": "Capital Conservation Buffer breach",
  "capital_ratios": {
    "cet1_ratio": 6.63,
    "tier1_ratio": 9.40,
    "total_capital_ratio": 11.09,
    "leverage_ratio": 4.08
  },
  "requirements": {
    "cet1_minimum_met": true,
    "capital_conservation_buffer_met": false,
    "tier1_minimum_met": true,
    "total_capital_minimum_met": true,
    "leverage_ratio_met": true
  },
  "finding_count": 3
}
```

---

## output/findings.csv

Required columns:

```csv
finding_id,severity,category,reference,basel_rule,description
```

Each supervisory finding must appear exactly once.

---

## output/rwa_summary.csv

Required columns:

```csv
metric,value
```

The file must contain all intermediate supervisory calculations used to determine compliance.

---

# Deterministic requirements

Your solution must be fully deterministic.

Use only:

- the provided input files;
- the Basel III rules defined in this document.

Do not introduce additional assumptions.

---

# Expected supervisory outcome

The synthetic bank is **not fully compliant** with Basel III.

The primary supervisory finding is:

> Capital Conservation Buffer breach

The review must also identify:

- ineligible collateral;
- incorrect SME classification when group revenue is considered;
- correct application of different Credit Conversion Factors;
- leverage ratio compliance despite failure of the CET1 plus Capital Conservation Buffer requirement.

All calculations and findings must be internally consistent.

# Basel III Supervisory Compliance Review

## Background

You are acting as a prudential supervisory analyst reviewing a synthetic commercial bank's Basel III capital adequacy position.

Use only the information provided in the input files and the rules stated in this document. Do not use external data, assumptions, or regulatory interpretations.

## Input files

The input directory contains:

- `input/bank_profile.csv`
- `input/capital_components.csv`
- `input/credit_exposures.csv`
- `input/collateral_register.csv`
- `input/off_balance_sheet.csv`

## Required outputs

Create exactly these files:

- `output/compliance_report.json`
- `output/findings.csv`
- `output/rwa_summary.csv`

No additional output files should be created.

## Supervisory objective

Your review must:

1. Calculate adjusted CET1 capital.
2. Calculate credit Risk-Weighted Assets.
3. Calculate off-balance-sheet RWA.
4. Calculate total RWA.
5. Calculate Basel III capital ratios.
6. Determine compliance with each minimum requirement.
7. Identify every supervisory finding.
8. Produce the final supervisory conclusion.

## Basel III calculation rules

Adjusted CET1 is calculated as:

Adjusted CET1 = Gross CET1 - Goodwill - Deferred Tax Assets - Other CET1 Deductions

Capital ratios are calculated as:

CET1 Ratio = Adjusted CET1 / Total RWA * 100  
Tier 1 Ratio = Tier 1 Capital / Total RWA * 100  
Total Capital Ratio = Total Capital / Total RWA * 100  
Leverage Ratio = Tier 1 Capital / Total Exposure Measure * 100

## Minimum regulatory requirements

| Requirement | Minimum |
|---|---:|
| CET1 minimum | 4.5% |
| CET1 plus Capital Conservation Buffer | 7.0% |
| Tier 1 minimum | 6.0% |
| Total Capital minimum | 8.0% |
| Leverage Ratio minimum | 3.0% |

## Risk-weight rules

Apply the following deterministic risk weights.

| Exposure type | Risk weight |
|---|---:|
| Corporate | 100% |
| Eligible SME | 85% |
| Residential Mortgage | 35% |
| Past-Due Loan | 150% |
| Sovereign | 0% |

## SME eligibility

An exposure qualifies as SME only if both conditions are satisfied:

- `is_sme_flag = true`
- `group_annual_revenue <= 50000000`

If either condition fails, the exposure must not receive SME treatment.

## Collateral eligibility

Collateral may reduce regulatory exposure only if:

`eligible_under_basel = true`

Collateral that does not satisfy this requirement must be ignored for supervisory purposes.

## Off-balance-sheet exposures

Apply the following Credit Conversion Factors.

| Instrument type | CCF |
|---|---:|
| Undrawn Credit Commitment | 50% |
| Trade Letter of Credit | 20% |
| Unconditionally Cancelable Commitment | 10% |

Off-balance-sheet RWA is calculated as:

Off-Balance-Sheet RWA = Notional Amount * CCF * applicable risk weight

For this synthetic task, apply the following off-balance-sheet risk weights based on `related_exposure_type`:

- `corporate`: 100%
- `trade_finance`: 100%
- `retail`: 75%

## Output file specifications

### `output/compliance_report.json`

The JSON file must contain:

- `bank_id`
- `reporting_date`
- `overall_status`
- `primary_reason`
- `capital_ratios`
- `requirements`
- `finding_count`

Use numeric values rounded to two decimal places.

### `output/findings.csv`

Required columns:

`finding_id,severity,category,reference,basel_rule,description`

Each supervisory finding must appear exactly once.

### `output/rwa_summary.csv`

Required columns:

`metric,value`

The file must contain all intermediate supervisory calculations used to determine compliance.

## Deterministic requirements

The solution must be fully deterministic.

Use only:

- the provided input files;
- the Basel III rules defined in this document.

Do not introduce additional assumptions.

## Expected supervisory outcome

The synthetic bank is not fully compliant with Basel III.

The primary supervisory finding is:

Capital Conservation Buffer breach

The review must also identify:

- ineligible collateral;
- incorrect SME classification when group revenue is considered;
- correct application of different Credit Conversion Factors;
- leverage ratio compliance despite failure of the CET1 plus Capital Conservation Buffer requirement;
- material impact of CET1 deductions on compliance.

Overall status must be:

Not Fully Compliant

Primary reason must be:

Capital Conservation Buffer breach

All calculations and findings must be internally consistent.

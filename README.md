
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Public Quality and Outcomes Framework (QOF) data

> This is an experimental version of the data pipeline and we are still
> working on it. If you spot anything that looks wrong, please let us
> know or open an issue.

The Quality and Outcomes Framework (QOF) rewards GP practices in England
for the care they give. NHS England publishes the [QOF
results](https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data)
each year. This repository turns those yearly files into three tidy
datasets that are easy to analyse.

## Available datasets

`get-data.R` downloads the raw files listed in `qof-raw-data.yml` and
combines all years in a tidy format. See [DEVELOPERS.md](DEVELOPERS.md)
for details.

| Dataset     | Start date | End date   |       Rows |
|:------------|:-----------|:-----------|-----------:|
| Achievement | 2013-04-01 | 2026-03-31 | 21,799,630 |
| Prevalence  | 2013-04-01 | 2026-03-31 |  1,907,791 |
| Geography   | 2013-04-01 | 2026-03-31 |     89,423 |

### Prevalence

``` r
# Load latest release in R
qof_prevalence <- arrow::read_parquet(
  "https://github.com/bennettoxford/qof/releases/latest/download/prevalence.parquet"
)
```

How many patients at each GP practice have each condition, such as
diabetes, by year. The labels in `patient_list_type` change between
years and are missing for 2014-15.

- `reporting_period`: QOF financial year, for example `2024-25`.
- `start_date`: first day of the financial year.
- `end_date`: last day of the financial year.
- `practice_code`: GP practice code.
- `group_code`: code for the condition, for example `DM` for Diabetes
  Mellitus.
- `register`: number of patients at the practice with the condition.
- `practice_list_size`: number of patients registered at the practice,
  used to work out the share with the condition.
- `patient_list_type`: which patients `practice_list_size` counts, for
  example `TOTAL` for all patients.

### Achievement

``` r
# Load latest release in R
qof_achievement <- arrow::read_parquet(
  "https://github.com/bennettoxford/qof/releases/latest/download/achievement.parquet"
)
```

How well each GP practice did on each QOF indicator, a measure of care,
by year. The types of `measure` change between years, for example `pcas`
replaced `exceptions` from 2019-20.

- `reporting_period`: QOF financial year, for example `2024-25`.
- `start_date`: first day of the financial year.
- `end_date`: last day of the financial year.
- `practice_code`: GP practice code.
- `indicator_code`: QOF indicator code, for example `DM012`.
- `measure`: what `value` counts, for example `numerator` (patients who
  met the indicator), `denominator` (patients it applies to) or
  `achieved_points` (points the practice earned).
- `value`: the count or points for that measure.

### Geography

``` r
# Load latest release in R
qof_geography <- arrow::read_parquet(
  "https://github.com/bennettoxford/qof/releases/latest/download/geography.parquet"
)
```

The name and NHS region of each GP practice, by year.

- `reporting_period`: QOF financial year, for example `2024-25`.
- `start_date`: first day of the financial year.
- `end_date`: last day of the financial year.
- `practice_code`: GP practice code.
- `practice_name`: GP practice name.
- `region_ods_code`: NHS code for the region.
- `region_name`: name of the NHS region.

## Resources

- [2025-26 technical
  annex](https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data/2025-26/technical-annex):
  Definitions of the raw data, also available for other reporting
  periods.
- [QOF
  publications](https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data):
  The raw data files for each reporting period.
- [QOF business
  rules](https://digital.nhs.uk/data-and-information/data-collections-and-data-sets/data-collections/quality-and-outcomes-framework-qof/business-rules):
  The clinical codes and rules behind each indicator.

## Licence

The code is licensed under the [MIT License](LICENSE.md). The source
data is available under the [Open Government
Licence](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).
Contains information from NHS England, licenced under the current
version of the Open Government Licence.

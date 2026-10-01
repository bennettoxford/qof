
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Public Quality and Outcomes Framework (QOF) data

This repository prepares public Quality and Outcomes Framework (QOF)
data for analysis. The data comes from the NHS England: [Quality and
Outcomes Framework achievement, prevalence and exceptions
data](https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data).

## Data

| Dataset    | Start date | End date   |      Rows | File                 |
|:-----------|:-----------|:-----------|----------:|:---------------------|
| Prevalence | 2013-04-01 | 2026-03-31 | 1,907,791 | `prevalence.parquet` |
| Geography  | 2013-04-01 | 2026-03-31 |    89,423 | `geography.parquet`  |

## Reading the data

The latest prevalence data can be read directly with Arrow:

``` r
qof_prevalence <- arrow::read_parquet(
  "https://github.com/bennettoxford/qof/releases/latest/download/prevalence.parquet"
)
```

## Updating the data

`qof-raw-data.yml` records the download URL and archive filenames for
each release. It also maps raw data column names, which are inconsistent
across the reporting periods, to consistent names. `get-data.R` reads
this config file and writes the combined prevalence and geography data
as Parquet files in `data/`.

## Publishing the tidy data as GitHub Release

1.  Update the data and review the generated Parquet files.
2.  Merge the update into the default branch and pull the latest changes
    locally.
3.  Create and publish the release from the terminal with
    [gh](https://cli.github.com/):

``` bash
gh release create 2025-26-v1 \
  data/prevalence.parquet \
  data/geography.parquet \
  --title "2025-26-v1" \
  --notes "QOF data for financial years 2013-14 to 2025-26."
```

## Licence

The source data is available under the [Open Government
Licence](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).
Contains information from NHS England, licenced under the current
version of the Open Government Licence.

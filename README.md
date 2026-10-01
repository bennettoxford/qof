
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Public Quality and Outcomes Framework (QOF) data

This repository prepares public Quality and Outcomes Framework (QOF)
data for analysis. The data comes from the NHS England: [Quality and
Outcomes Framework achievement, prevalence and
exceptions](https://digital.nhs.uk/data-and-information/publications/statistical/quality-and-outcomes-framework-achievement-prevalence-and-exceptions-data)
data.

## Available data

| Dataset    | Start date | End date   |      Rows |
|:-----------|:-----------|:-----------|----------:|
| Prevalence | 2013-04-01 | 2026-03-31 | 1,907,791 |
| Geography  | 2013-04-01 | 2026-03-31 |    89,423 |

## Practices and list size

| Financial year | Practices | Practice list size |
|:---------------|----------:|-------------------:|
| 2025-26        |     6,145 |         63,674,427 |
| 2024-25        |     6,188 |         63,766,671 |
| 2023-24        |     6,267 |         63,213,403 |
| 2022-23        |     6,378 |         62,378,057 |
| 2021-22        |     6,470 |         61,604,213 |
| 2020-21        |     6,571 |         60,716,244 |
| 2019-20        |     6,720 |         60,407,685 |
| 2018-19        |     6,873 |         59,386,096 |
| 2017-18        |     7,100 |         58,383,266 |
| 2016-17        |     7,392 |         58,029,147 |
| 2015-16        |     7,619 |         57,549,410 |
| 2014-15        |     7,779 |         56,817,654 |
| 2013-14        |     7,921 |         56,324,887 |

## Reading the data

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

## Publishing the tidy data

1.  Update the data and review the generated Parquet files.
2.  Merge the update into the default branch and pull the latest changes
    locally.
3.  Create and publish the release from the terminal with
    [gh](https://cli.github.com/):

``` bash
gh release create YYYY-YY-v1 \
  data/prevalence.parquet \
  data/geography.parquet \
  --title "YYYY-YY-v1" \
  --notes "QOF data for financial years 2013-14 to YYYY-YY."
```

## Licence

The code is licensed under the [MIT License](LICENSE.md). The source
data is available under the [Open Government
Licence](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).
Contains information from NHS England, licenced under the current
version of the Open Government Licence.

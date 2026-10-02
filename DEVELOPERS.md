# For developers

## Updating the data

- `qof-raw-data.yml` records the download URL and archive filenames for each release.
It also maps raw data column names, which are inconsistent across the reporting periods, to consistent names.
- `get-data.R` reads this config file and writes the combined achievement, prevalence and geography data as Parquet files in `data/`.
- The cleaning gives each column the same name in every year, adds start and end dates, and combines all years into one file per dataset.
- `get-data-raw.R` downloads the raw files into `raw-data/` if you want to look at them.

## Publishing the tidy data

1. Update the data and review the generated Parquet files.
1. Merge the update into the default branch and pull the latest changes locally.
1. Create and publish the release from the terminal with [gh](https://cli.github.com/):

```bash
gh release create YYYY-YY-v1 \
  data/achievement.parquet \
  data/prevalence.parquet \
  data/geography.parquet \
  --title "YYYY-YY-v1" \
  --notes "QOF data for financial years 2013-14 to YYYY-YY."
```
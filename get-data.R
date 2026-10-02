library(tidyverse)
library(arrow)
library(yaml)
library(here)
library(janitor)
library(fs)
library(cli)

qof_config <- read_yaml(here("qof-raw-data.yml"))

# Read and combine one or more CSV files
read_csvs <- function(files, directory) {
  files |>
    map(
      \(file) {
        read_csv(
          file.path(directory, file),
          na = c("", "NA", "Insufficient indicator data", "-", "#VALUE!"),
          name_repair = make_clean_names,
          show_col_types = FALSE
        )
      }
    ) |>
    list_rbind()
}

# Download and read all zip foles for one QOF year
read_qof_year <- function(year_config) {
  temp_zip <- tempfile(fileext = ".zip")
  temp_dir <- tempfile()
  on.exit(unlink(c(temp_zip, temp_dir), recursive = TRUE))

  start_year <- as.integer(str_sub(year_config$year, 1, 4))
  start_date <- as.Date(str_c(start_year, "-04-01"))
  end_date <- as.Date(str_c(start_year + 1, "-03-31"))

  cli_alert_info("Downloading QOF {year_config$year}")
  download.file(year_config$url, temp_zip, mode = "wb", quiet = TRUE)
  unzip(temp_zip, exdir = temp_dir)

  map(
    year_config$files,
    \(files) {
      read_csvs(files, temp_dir) |>
        mutate(
          reporting_period = year_config$year,
          start_date = start_date,
          end_date = end_date,
          .before = 1
        )
    }
  )
}

# Pivot 2013-14 and 2014-15 achievement measures from columns to rows
pivot_achievement <- function(data) {
  if (!"measure" %in% names(data)) {
    data <- data |>
      pivot_longer(
        c(numerator, denominator, achieved_points),
        names_to = "measure",
        values_to = "value",
        values_drop_na = TRUE
      )
  }

  data |>
    mutate(
      measure = str_to_lower(measure),
      value = as.double(value)
    )
}

# Match standard column names to their source aliases
source_columns <- function(data, columns) {
  map_chr(
    columns,
    \(aliases) detect(aliases, \(alias) alias %in% names(data)) %||% NA
  )
}

# Select and rename columns to the standard schema
# Columns missing from a source file are filled with NA
standardise_columns <- function(data, columns) {
  sources <- source_columns(data, columns)
  missing <- names(columns)[is.na(sources)]
  data[missing] <- NA_character_

  data |>
    select(
      reporting_period,
      start_date,
      end_date,
      all_of(set_names(coalesce(sources, names(columns)), names(columns)))
    )
}

# 2013-14 has no patient list type, but list size is the same for every
# group within a practice, so it is the total list.
# 2014-15 also has no type, but list size varies by group, so it stays NA.
fill_patient_list_type <- function(data) {
  data |>
    mutate(
      patient_list_type = if_else(
        reporting_period == "2013-14",
        "TOTAL",
        patient_list_type
      )
    )
}

# Standardise and combine one dataset across all years
standardise_dataset <- function(data, dataset) {
  if (dataset == "achievement") {
    data <- map(data, pivot_achievement)
  }

  data <- data |>
    map(
      standardise_columns,
      columns = qof_config$datasets[[dataset]]$columns
    ) |>
    list_rbind()

  if (dataset == "prevalence") {
    data <- fill_patient_list_type(data)
  }

  data
}

financial_years <- str_c(
  "fy_",
  str_replace(map_chr(qof_config$releases, "year"), "-", "_")
)

qof_raw <- qof_config$releases |>
  set_names(financial_years) |>
  map(read_qof_year)

qof_data <- qof_raw |>
  list_transpose() |>
  imap(standardise_dataset)

dir_create(here("data"))

iwalk(
  qof_data,
  \(data, dataset) {
    write_parquet(
      data,
      here("data", paste0(dataset, ".parquet")),
      compression = "zstd",
      compression_level = 22
    )
  }
)

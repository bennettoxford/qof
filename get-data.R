library(tidyverse)
library(arrow)
library(yaml)
library(here)
library(janitor)
library(fs)
library(cli)

qof_config <- read_yaml(here("qof-raw-data.yml"))

read_release <- function(release) {
  temp_zip <- tempfile(fileext = ".zip")
  temp_dir <- tempfile()
  on.exit(unlink(c(temp_zip, temp_dir), recursive = TRUE))

  start_year <- as.integer(str_sub(release$year, 1, 4))
  start_date <- as.Date(str_c(start_year, "-04-01"))
  end_date <- as.Date(str_c(start_year + 1, "-03-31"))

  cli_alert_info("Downloading QOF {release$year}")
  download.file(release$url, temp_zip, mode = "wb", quiet = TRUE)
  unzip(temp_zip, exdir = temp_dir)

  map(
    release$files,
    \(file) {
      read_csv(
        file.path(temp_dir, file),
        na = c("", "NA", "Insufficient indicator data", "-", "#VALUE!"),
        name_repair = make_clean_names,
        show_col_types = FALSE
      ) |>
        mutate(
          year = release$year,
          start_date = start_date,
          end_date = end_date,
          .before = 1
        )
    }
  )
}

standardise_columns <- function(data, columns) {
  source_columns <- map_chr(
    columns,
    \(aliases) detect(aliases, \(alias) alias %in% names(data))
  )

  data |>
    select(
      year,
      start_date,
      end_date,
      all_of(set_names(source_columns, names(columns)))
    )
}

financial_years <- str_c(
  "fy_",
  str_replace(map_chr(qof_config$releases, "year"), "-", "_")
)

qof_raw <- qof_config$releases |>
  set_names(financial_years) |>
  map(read_release)

qof_data <- qof_raw |>
  list_transpose() |>
  imap(
    \(data, dataset) {
      data |>
        map(
          standardise_columns,
          columns = qof_config$datasets[[dataset]]$columns
        ) |>
        list_rbind()
    }
  )

dir_create(here("data"))

iwalk(
  qof_data,
  \(data, dataset) {
    write_parquet(data, here("data", paste0(dataset, ".parquet")))
  }
)

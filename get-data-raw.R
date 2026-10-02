library(yaml)
library(here)
library(fs)
library(cli)
library(purrr)

qof_config <- read_yaml(here("qof-raw-data.yml"))

walk(
  qof_config$releases,
  \(release) {
    cli_alert_info("Downloading QOF {release$year}")
    temp_zip <- tempfile(fileext = ".zip")
    download.file(release$url, temp_zip, mode = "wb", quiet = TRUE)
    unzip(temp_zip, exdir = here("raw-data", release$year))
    file_delete(temp_zip)
  }
)

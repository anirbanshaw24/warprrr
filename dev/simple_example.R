
pkgload::load_all()

generate_patient_labs_long <- function(
    n_patients = 10000,
    visits_per_patient = 15,
    labs_per_visit = 8
) {
  set.seed(123)

  patient_ids <- sprintf("PT%06d", seq_len(n_patients))

  patient_visits <- data.table::CJ(
    PatientID = patient_ids,
    VisitNumber = seq_len(visits_per_patient)
  )

  patient_visits[, VisitDate := as.Date("2020-01-01") +
                   cumsum(sample(7:60, .N, TRUE)),
                 by = PatientID]

  lab_tests <- c(
    "Glucose", "Hemoglobin", "WBC", "Platelets",
    "Creatinine", "ALT", "AST", "BUN"
  )

  dt <- data.table::CJ(
    PatientID = patient_visits$PatientID,
    VisitNumber = patient_visits$VisitNumber,
    LabTest = lab_tests[seq_len(labs_per_visit)]
  )

  dt <- patient_visits[dt, on = .(PatientID, VisitNumber)]

  dt[, LabValue := data.table::fcase(
    LabTest == "Glucose",      round(rnorm(.N, 95, 20), 1),
    LabTest == "Hemoglobin",  round(rnorm(.N, 14, 2), 1),
    LabTest == "WBC",         round(rnorm(.N, 7.5, 2.5), 2),
    LabTest == "Platelets",  round(rnorm(.N, 250, 60), 0),
    LabTest == "Creatinine", round(rnorm(.N, 1.0, 0.3), 2),
    LabTest == "ALT",         round(rnorm(.N, 25, 15), 0),
    LabTest == "AST",         round(rnorm(.N, 28, 12), 0),
    LabTest == "BUN",         round(rnorm(.N, 15, 5), 1)
  )]

  dt[, Unit := data.table::fcase(
    LabTest == "Glucose",      "mg/dL",
    LabTest == "Hemoglobin",  "g/dL",
    LabTest == "WBC",         "10^3/uL",
    LabTest == "Platelets",  "10^3/uL",
    LabTest == "Creatinine", "mg/dL",
    LabTest %in% c("ALT", "AST"), "U/L",
    LabTest == "BUN",         "mg/dL"
  )]

  data.table::setorder(dt, PatientID, VisitDate, LabTest)
  dt
}

lab_data <- generate_patient_labs_long(
  n_patients = 30,
  visits_per_patient = 15,
  labs_per_visit = 8
)

dim(lab_data)
head(lab_data, 20)

time_code <- function(expr, message = "") {
  start <- Sys.time()
  eval(expr)
  elapsed <- as.numeric(difftime(Sys.time(), start, units = "secs"))
  msg_prefix <- if (nzchar(message)) paste("to", message) else ""
  cat("Time taken", msg_prefix, ":", sprintf("%.2f secs", elapsed), "\n")
  invisible(round(elapsed, 2))
}

data_dir <- file.path(tempdir(), "warprrr-vignette")
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

time_code({
  haven::write_sas(
    lab_data,
    file.path(data_dir, "lab_data.sas7bdat")
  )
}, message = "write a .sas7bdat file")

time_code({
  haven::read_sas(
    file.path(data_dir, "lab_data.sas7bdat")
  )
}, message = "read the same .sas7bdat file directly")

time_code({
  haven::write_xpt(
    lab_data,
    file.path(data_dir, "lab_data.xpt")
  )
}, message = "write an .xpt file")

time_code({
  haven::read_xpt(
    file.path(data_dir, "lab_data.xpt")
  )
}, message = "read the same .xpt file directly")

time_code({
  warprrr::read_data(
    file.path(data_dir, "lab_data.sas7bdat")
  )
}, message = "read an SAS file with {warprrr} (initial read)")

time_code({
  warprrr::read_data(
    file.path(data_dir, "lab_data.sas7bdat")
  )
}, message = "read the same SAS file again from cache")

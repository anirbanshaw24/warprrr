
read_data_multi_format <- function(
    file_ext, data_path, read_fun_args) {

  switch(
    file_ext,
    csv = {
      do.call(
        data.table::fread,
        c(list(data_path), read_fun_args)
      )
    },
    tsv = {
      do.call(
        data.table::fread,
        c(list(data_path), read_fun_args)
      )
    },
    psv = {
      do.call(
        data.table::fread,
        c(list(data_path), read_fun_args)
      )
    },
    txt = {
      do.call(
        data.table::fread,
        c(list(data_path), read_fun_args)
      )
    },
    sas7bdat = {
      do.call(
        haven::read_sas,
        c(list(data_path), read_fun_args)
      )
    },
    xpt = {
      do.call(
        haven::read_xpt,
        c(list(data_path), read_fun_args)
      )
    },
    parquet = {
      do.call(
        arrow::read_parquet,
        c(list(data_path), read_fun_args)
      )
    },
    feather = {
      do.call(
        arrow::read_feather,
        c(list(data_path), read_fun_args)
      )
    },
    {
      error_glue(
        "`{file_ext}` files are not supported."
      )
    }
  )
}

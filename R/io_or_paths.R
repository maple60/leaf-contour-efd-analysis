#' Resolve repository data directory
#'
#' Returns a data directory path with optional override via environment variable.
#'
#' @param env_var Environment variable name to check first.
#' @param default_dir Default relative directory when env var is unset.
#'
#' @return Character scalar path to a data directory.
#'
#' @sideeffects Reads environment variables.
resolve_data_dir <- function(env_var = "LEAF_EFD_DATA_DIR", default_dir = "data") {
  env_value <- Sys.getenv(env_var, unset = "")
  if (nzchar(env_value)) {
    return(env_value)
  }
  default_dir
}

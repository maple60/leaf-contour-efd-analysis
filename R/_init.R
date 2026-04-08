# Deterministic module loader for analysis helpers.

module_files <- c(
  "normalization.R",
  "geometry.R",
  "io_or_paths.R"
)

for (module_file in module_files) {
  source(file.path("R", module_file), local = .GlobalEnv)
}

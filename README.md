

> This `README.md` is generated from `README.qmd`.  
> Please edit `README.qmd` and re-render instead of editing this file
> directly.

# LeafContourEFD Analysis

This repository contains analysis code and reproducibility materials for
the LeafContourEFD manuscript. The software itself is available at:
[leaf-contour-efd](https://github.com/maple60/leaf-contour-efd)

## Quickstart

Follow these steps to confirm the environment and run a first example
notebook.

1.  Get the data (see (**data?**) section below).

2.  Set `PROJECT_DATA_DIR` in `.Renviron` (project root):

<div class="code-with-filename">

**.Renviron**

```
PROJECT_DATA_DIR=/path/to/your/data
```

</div>

3.  Restore the R package environment:

``` r
renv::restore()
```

4.  Execute analysis notebooks in `notebooks/`. (`.qmd` files;
    [Quarto](https://quarto.org/) is required)

## Requirements

To reproduce the analysis, you need:

- [R](https://www.r-project.org/) (recommended version: 4.3.1 or higher)
- [Quarto](https://quarto.org/)
- the R packages required by this project

If you install [renv](https://rstudio.github.io/renv/), you can install
the required R packages by executing `renv::restore()` (see below). All
analysis code is written in R version 4.3.1 (*R* 2026).

### Optional tools

- [Air](https://posit-dev.github.io/air/): R code formatter.
- [Positron](https://positron.posit.co/): IDE used for all analyses in
  this project, but not required to run the code.

### R environment setup

In this repository, I use [renv](https://rstudio.github.io/renv/) to
manage R package dependencies. Please execute command below after
installing renv.

``` r
# install.packages("renv") # if not installed
renv::restore()
```

## Data and outputs

### Data

Raw data are available on [Dryad](https://datadryad.org/) (DOI: in
preparation).

Tracked-vs-external data policy is documented in `data/README.md`.

This project may require setting a local data directory via environment
variable. Create a `.Renviron` file in the project root and add:

<div class="code-with-filename">

**.Renviron**

    PROJECT_DATA_DIR=/path/to/your/data

</div>

For example:

- macOS: /Users/yourname/Dropbox/project_data
- Windows: C:/Users/yourname/Dropbox/project_data

### Output directories

Generated artifacts should be written to deterministic,
repository-relative paths:

- `outputs/figures/`: rendered figures/images (e.g., SVGs from
  notebooks)
- `outputs/tables/`: derived tabular outputs
- `outputs/cache/`: temporary caches/intermediate artifacts

Notebooks in `notebooks/` follow these conventions and avoid
user-specific absolute output paths.

## Repository layout

| Path | Purpose |
|----|----|
| `notebooks/` | Quarto notebooks used for analysis, figures, and report outputs. |
| `scripts/` or `R/` | Reusable R scripts/functions shared across notebooks and workflows. |
| `renv/` | Project-local R environment metadata and lockfile support. |
| `PROJECT_DATA_DIR` location | External data directory expected by analysis code (set via `.Renviron`). |

## Common pitfalls

- **`PROJECT_DATA_DIR` is not set or points to the wrong location**  
  Symptoms: file-not-found errors when running notebooks or scripts.  
  Fix: confirm `.Renviron` exists in project root and contains the
  correct absolute path.

- **`renv::restore()` fails**  
  Symptoms: package installation errors, version conflicts, or missing
  system libraries.  
  Fix: update R to a compatible version (4.3.1+ recommended), then retry
  `renv::restore()` and install missing system dependencies if prompted.

- **Quarto is missing or not on PATH**  
  Symptoms: `quarto: command not found` or render failures.  
  Fix: install Quarto from <https://quarto.org/> and verify with
  `quarto --version`.

## About README

This `README.md` is generated from `README.qmd` using
[Quarto](https://quarto.org/) by using the command:

``` bash
quarto render README.qmd
```

## Use of AI and LLMs

[ChatGPT](https://chat.openai.com/) was used to improve the
documentation and code. [Codex](https://openai.com/codex) was used to
refactor the code in this repository. [GitHub
Copilot](https://github.com/features/copilot) was used for coding
assistance.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-r:alan2026" class="csl-entry">

*R: A Language and Environment for Statistical Computing*. 2026. Vienna,
Austria. <https://www.R-project.org/>.

</div>

</div>

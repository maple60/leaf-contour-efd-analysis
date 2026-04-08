

> This `README.md` is generated from `README.qmd`.  
> Please edit `README.qmd` and re-render instead of editing this file
> directly.

# LeafContourEFD Analysis

This repository contains analysis code and reproducibility materials for
the LeafContourEFD manuscript. The software itself is available at:
[leaf-contour-efd](https://github.com/maple60/leaf-contour-efd)

## Requirements

Tp reproduce the analysis, you need:

- R
- Quarto
- the R packages required by this project

If you install [renv](https://rstudio.github.io/renv/), you can install
the required R packages by executing `renv::restore()` (see below). All
analysis code is written in R vesion 4.3.1 (*R* 2026).

### R environment setup

In this repository, I use [renv](https://rstudio.github.io/renv/) to
manage R pacage dependencies. Please execute command below after
installing renv.

``` r
# install.packages("renv") # if you don't install
renv::restore()
```

## Data

Raw data are available on [Dryad](https://datadryad.org/):

- DOI: In preparation.

## Data files setup

This project requires setting the data directory via environment
variable.

Please create a `.Renviron` file in the project root and add:

<div class="code-with-filename">

**.Renviron**

```
PROJECT_DATA_DIR=/path/to/your/data
```

</div>

For example:

- macOS: /Users/yourname/Dropbox/project_data
- Windows: C:/Users/yourname/Dropbox/project_data

## About README

This `README.md` is generated from `README.qmd` using
[Quarto](https://quarto.org/) by using the command:

``` bash
quarto render README.qmd
```

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-r:alan2026" class="csl-entry">

*R: A Language and Environment for Statistical Computing*. 2026. Vienna,
Austria. <https://www.R-project.org/>.

</div>

</div>

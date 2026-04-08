

# LeafContourEFD Analysis

This repository contains analysis code and reproducibility materials for
the LeafContourEFD manuscript. The software itself is available at:
[leaf-contour-efd](https://github.com/maple60/leaf-contour-efd)

## R environment setup

In this repository, I use renv to manage R pacage dependencies. Please
execute command below after installing renv.

``` r
# install.packages("renv") # if you don't install
renv::restore()
```

## Data

Raw data are available on Dryad:

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

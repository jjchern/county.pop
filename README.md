
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/jjchern/county.pop.svg?branch=master)](https://travis-ci.org/jjchern/county.pop) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/jjchern/county.pop?branch=master&svg=true)](https://ci.appveyor.com/project/jjchern/county.pop)

About `county.pop`
==================

The package stores U.S. annual county-level population estimates (1969-2016) from [SEER](https://seer.cancer.gov/popdata/download.html). The dataset is unbalanced: certain counties do not have population estimates for all the years.

Installation
============

``` r
# install.packages("devtools")
devtools::install_github("jjchern/county.pop")
# To uninstall the package, use:
# remove.packages("county.pop")
```

Usage
=====

``` r
library(tibble)
county.pop::pop
#> # A tibble: 149,766 x 5
#>    state_fips  usps county_fips  year   pop
#>         <chr> <chr>       <chr> <dbl> <int>
#>  1         01    AL       01001  1969 23819
#>  2         01    AL       01001  1970 24661
#>  3         01    AL       01001  1971 25503
#>  4         01    AL       01001  1972 27156
#>  5         01    AL       01001  1973 28453
#>  6         01    AL       01001  1974 29261
#>  7         01    AL       01001  1975 29716
#>  8         01    AL       01001  1976 29892
#>  9         01    AL       01001  1977 30457
#> 10         01    AL       01001  1978 30879
#> # ... with 149,756 more rows
```

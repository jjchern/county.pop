
library(tidyverse)

url = "https://seer.cancer.gov/popdata/yr1969_2016.19ages/us.1969_2016.19ages.adjusted.txt.gz"
fil = "data-raw/us.1969_2016.19ages.adjusted.txt.gz"
if (!exists(fil)) download.file(url, fil)

# Load raw data -----------------------------------------------------------

read_fwf("data-raw/us.1969_2016.19ages.adjusted.txt",
         fwf_widths(c(4, 2, 2, 3, 2, 1, 1, 1, 2, 8),
                    c("year", "usps", "state_fips", "county_fips", "registry",
                      "race", "origin", "sex", "age", "pop"))) %>%
    print() -> raw

# Aggregate to county-year level ------------------------------------------

raw %>%
    mutate(county_fips = paste0(state_fips, county_fips)) %>%
    mutate(pop = pop %>% as.integer()) %>%
    arrange(state_fips, usps, county_fips, year) %>%
    group_by(state_fips, usps, county_fips, year) %>%
    summarise(pop = pop %>% sum()) %>%
    print() -> pop

devtools::use_data(pop)

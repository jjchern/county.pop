
# dict: https://seer.cancer.gov/popdata/popdic.html -----------------------

library(tidyverse)

# Option 1: Use the 19 age groups
# url = "https://seer.cancer.gov/popdata/yr1990_2016.19ages/us.1990_2016.19ages.txt.gz"
# fil_gz = "data-raw/us.1990_2016.19ages.txt.gz"
# fil    = "data-raw/us.1990_2016.19ages.txt"

# Option 2: Use the single year age groups
url = "https://seer.cancer.gov/popdata/yr1990_2016.singleages/us.1990_2016.singleages.txt.gz"
fil_gz = "data-raw/us.1990_2016.singleages.txt.gz"
fil    = "data-raw/us.1990_2016.singleages.txt"

if (!file.exists(fil_gz)) {
    download.file(url, fil_gz)
    R.utils::gunzip(fil_gz, fil, remove = FALSE)
}

# Load raw data -----------------------------------------------------------

read_fwf(fil,
         fwf_widths(c(4, 2, 2, 3, 2, 1, 1, 1, 2, 8),
                    c("year", "usps", "state_fips", "county_fips", "registry",
                      "race", "origin", "sex", "age", "pop"))) %>%
    print() -> raw

raw %>% sample_n(1000) %>% distinct(race)
raw %>% sample_n(1000) %>% distinct(origin)
raw %>% sample_n(1000) %>% distinct(sex)
raw %>% sample_n(1000) %>% distinct(registry)
raw %>% sample_n(1000) %>% distinct(age)

# Aggregate to county-year level population --------------------------------

raw %>%
    # sample_n(100) %>% # Speed up the pipe
    mutate(county_fips = paste0(state_fips, county_fips)) %>%
    mutate(pop = pop %>% as.integer()) %>%
    arrange(state_fips, usps, county_fips, year) %>%
    group_by(state_fips, usps, county_fips, year) %>%
    summarise(pop = pop %>% sum()) %>%
    ungroup() %>%
    print() -> pop

raw %>%
    # sample_n(100) %>% # Speed up the pipe
    mutate(county_fips = paste0(state_fips, county_fips)) %>%
    mutate(pop = pop %>% as.integer()) %>%
    mutate(race_ethncy = case_when(
        origin == 0 & race == 1         ~ "nh_w", # Non-Hispanic White
        origin == 0 & race == 2         ~ "nh_b", # Non-Hispanic Black
        origin == 0 & race %in% c(3, 4) ~ "nh_o", # Non-Hispanic Others
        origin == 1                     ~ "hisp"  # Hispanic
    )) %>%
    group_by(state_fips, usps, county_fips, year, race_ethncy) %>%
    summarise(pop = pop %>% sum()) %>%
    spread(race_ethncy, pop) %>%
    print() -> pop_by_race

raw %>%
    # sample_n(100) %>% # Speed up the pipe
    mutate(county_fips = paste0(state_fips, county_fips)) %>%
    mutate(pop = pop %>% as.integer()) %>%
    mutate(age = age %>% as.integer()) %>%
    mutate(age_grp = case_when(
        age %in% 0:18  ~ "age_1_18",
        age %in% 19:44 ~ "age_19_44",
        age %in% 45:64 ~ "age_45_64",
        age %in% 65:85 ~ "age_65_85p"
    )) %>%
    group_by(state_fips, usps, county_fips, year, age_grp) %>%
    summarise(pop = pop %>% sum()) %>%
    spread(age_grp, pop) %>%
    print() -> pop_by_age_grp

raw %>%
    # sample_n(100) %>% # Speed up the pipe
    mutate(county_fips = paste0(state_fips, county_fips)) %>%
    mutate(pop = pop %>% as.integer()) %>%
    mutate(sex_grp = if_else(sex == 2, "female", "male")) %>%
    group_by(state_fips, usps, county_fips, year, sex_grp) %>%
    summarise(pop = pop %>% sum()) %>%
    spread(sex_grp, pop) %>%
    print() -> pop_by_sex

pop %>%
    left_join(fips::state) %>%
    select(state_fips, usps, state, county_fips, year, pop) %>%
    left_join(pop_by_race) %>%
    left_join(pop_by_age_grp) %>%
    left_join(pop_by_sex) %>%
    print() -> pop_since_1990

devtools::use_data(pop_since_1990, overwrite = TRUE)

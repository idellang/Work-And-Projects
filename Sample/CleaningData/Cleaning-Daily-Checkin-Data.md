``` r
library(tidyverse)
library(lubridate)
library(caret)
library(data.table)
library(knitr)
```

# DO A SIMPLE EDA TO CLEAN THE DATA

``` r
checkin = read_csv('dailycheckins.csv')
checkin %>%
  head(10) %>%
  kable()
```

| user   | timestamp                                                                                      | hours | project              |
|:-------|:-----------------------------------------------------------------------------------------------|------:|:---------------------|
| ned    | 2019-09-27 00:00:00 UTC                                                                        |   8.0 | bizdev               |
| robert | 09/27/2019 12:00 AM                                                                            |   8.0 | bizdev               |
| ned    | 26 \<U+0441\>\<U+0435\>\<U+043D\>\<U+0442\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2019 00:00 |   4.0 | bizdev               |
| ned    | 2019-09-26 00:00:00 UTC                                                                        |   1.0 | cultureandmanagement |
| ned    | 2019-09-26 00:00:00 UTC                                                                        |   1.5 | project-00           |
| ned    | 2019-09-26 00:00:00 UTC                                                                        |   1.0 | project-43           |
| jaime  | 12/21/2018 12:00 AM                                                                            |   2.0 | project-00           |
| jaime  | 2018-12-21 00:00:00 UTC                                                                        |   0.5 | project-47           |
| jaime  | 2018-12-21 00:00:00 UTC                                                                        |   3.5 | project-47           |
| jaime  | 2018-12-20 00:00:00 UTC                                                                        |   1.5 | project-00           |

Missing values

``` r
map_dbl(checkin, function(x) sum(is.na(x)))
```

    ##      user timestamp     hours   project 
    ##         5         0         0         0

5 missing data from user

### Check user column

``` r
checkin %>%
        count(user) %>%
  arrange(desc(n)) %>%
  head(15)%>%
  kable()
```

| user         |    n |
|:-------------|-----:|
| ned          | 1387 |
| jorah        | 1383 |
| bronn        | 1327 |
| robert       | 1272 |
| davos        | 1241 |
| catelyn      | 1135 |
| littlefinger |  996 |
| jaime        |  840 |
| melisandre   |  703 |
| theon        |  638 |
| sansa        |  628 |
| shae         |  599 |
| hound        |  569 |
| viserys      |  558 |
| tywin        |  549 |

No mistype of entry but with 5 missing data

``` r
checkin %>%
        filter(is.na(user)) %>%
  kable()
```

| user | timestamp                      | hours | project    |
|:-----|:-------------------------------|------:|:-----------|
| NA   | 2017-12-27 10:36:14.000121 UTC |  4.00 | project-40 |
| NA   | 2017-12-27 10:36:14.000121 UTC |  3.00 | learning   |
| NA   | 2017-10-12 10:31:44.000227 UTC |  2.75 | project-47 |
| NA   | 2017-10-12 10:31:44.000227 UTC |  4.00 | bizdev     |
| NA   | 2017-10-12 10:31:44.000227 UTC |  1.00 | transit    |

Missing users are from different project. The timestamps are identical.

### Check timestamp column

Columns without UTC

``` r
checkin %>%
        filter(str_detect(timestamp,'UTC', negate = TRUE))
```

    ## # A tibble: 2,047 x 4
    ##    user    timestamp              hours project    
    ##    <chr>   <chr>                  <dbl> <chr>      
    ##  1 robert  09/27/2019 12:00 AM     8    bizdev     
    ##  2 ned     26 <U+0441><U+0435><U+043D><U+0442><U+044F><U+0431><U+0440><U+044F> 2019 00:00  4    bizdev     
    ##  3 jaime   12/21/2018 12:00 AM     2    project-00 
    ##  4 catelyn 26 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 14:47    0.72 opsandadmin
    ##  5 jorah   11/26/2018 12:49 PM     2    project-51 
    ##  6 viserys 26 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 12:30    0.5  opsandadmin
    ##  7 viserys 11/26/2018 12:30 PM     1    project-51 
    ##  8 jaime   26 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 12:11    1.8  learning   
    ##  9 sansa   11/26/2018 11:48 AM     2    transit    
    ## 10 catelyn 23 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 13:12    2.37 project-40 
    ## # ... with 2,037 more rows

``` r
checkin %>%
        select(timestamp) %>%
        count(str_detect(timestamp,'UTC', negate = TRUE)) %>%
  kable()
```

| str_detect(timestamp, “UTC”, negate = TRUE) |     n |
|:--------------------------------------------|------:|
| FALSE                                       | 18453 |
| TRUE                                        |  2047 |

Can just assume all are UTC

### Count entries with different encoding

``` r
checkin %>%
        mutate(timestamp = str_remove(timestamp,'UTC')) %>%
        filter(str_detect(timestamp, '[:alpha:]')) %>%
        filter(str_detect(timestamp, 'AM|PM', negate =  TRUE))
```

    ## # A tibble: 1,022 x 4
    ##    user    timestamp              hours project    
    ##    <chr>   <chr>                  <dbl> <chr>      
    ##  1 ned     26 <U+0441><U+0435><U+043D><U+0442><U+044F><U+0431><U+0440><U+044F> 2019 00:00  4    bizdev     
    ##  2 catelyn 26 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 14:47    0.72 opsandadmin
    ##  3 viserys 26 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 12:30    0.5  opsandadmin
    ##  4 jaime   26 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 12:11    1.8  learning   
    ##  5 catelyn 23 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 13:12    2.37 project-40 
    ##  6 cersei  23 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 00:00    5.5  blogideas  
    ##  7 joffrey 23 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 00:00    1    project-32 
    ##  8 bran    23 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 00:00    1.78 project-31 
    ##  9 sansa   23 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 00:00    2    project-31 
    ## 10 sansa   23 <U+043D><U+043E><U+044F><U+0431><U+0440><U+044F> 2018 00:00    1    project-51 
    ## # ... with 1,012 more rows

There are 1022 rows with different encoding.

``` r
checkin %>%
        mutate(timestamp = str_remove(timestamp,'UTC')) %>%
        filter(str_detect(timestamp, '[:alpha:]')) %>%
        filter(str_detect(timestamp, 'AM|PM', negate =  TRUE)) %>%
        pull(timestamp) %>%
        head(30) %>%
  kable()
```

| x                                                                                              |
|:-----------------------------------------------------------------------------------------------|
| 26 \<U+0441\>\<U+0435\>\<U+043D\>\<U+0442\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2019 00:00 |
| 26 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 14:47                     |
| 26 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 12:30                     |
| 26 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 12:11                     |
| 23 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 13:12                     |
| 23 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 23 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 23 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 23 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 23 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 22 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 15:46                     |
| 22 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 14:12                     |
| 22 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 14:12                     |
| 22 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 22 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 21 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 14:49                     |
| 21 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 10:14                     |
| 21 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 20 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 15:18                     |
| 20 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 20 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 20 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 19 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 14:39                     |
| 19 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 14:39                     |
| 19 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 13:38                     |
| 19 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 13:29                     |
| 19 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 13:29                     |
| 19 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 11:58                     |
| 19 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |
| 19 \<U+043D\>\<U+043E\>\<U+044F\>\<U+0431\>\<U+0440\>\<U+044F\> 2018 00:00                     |

The words are month in russian.

### Fix timestamp column

Cant detect entries with different encoding as string literal. Manually
detect it using filters. Identify those with different encoding

``` r
checkin = checkin %>%
        mutate(has_utc = str_detect(timestamp, 'UTC')) %>%
        mutate(timestamp = str_remove(timestamp,'UTC')) %>%
        mutate(has_letter = str_detect(timestamp, '[:alpha:]')) %>%
        mutate(notAMPM = str_detect(timestamp, 'AM|PM', negate =  TRUE)) %>%
        mutate(to_change = (has_letter & notAMPM)) %>%
        select(-has_letter, -notAMPM)
```

### Brute force the month since I cant find how to change encoding

Create another table for mapping russian to english

``` r
checkin = checkin %>%
        mutate(month_russian = str_extract(timestamp, '[:alpha:]+')) %>%
        mutate(month_russian = ifelse(str_detect(month_russian, 'AM|PM'), NA, month_russian))

months = checkin %>%
        distinct(month_russian) %>%
        filter(!is.na(month_russian))


english_months = c('September','November','October','August', 'July','June','May','April','March','February','January','December')

months$english_months = english_months
```

Combine table and change russian characters to english

``` r
checkin = checkin %>%
        left_join(months, by = c('month_russian' = 'month_russian')) %>%
        mutate(timestamp = ifelse(to_change, str_replace(timestamp,month_russian, english_months), timestamp))
```

Create identifier for those with AMPM and remove AMPM from timestamp

``` r
checkin = checkin %>%
        mutate(AMPM = str_extract(timestamp, 'AM|PM')) %>%
        mutate(timestamp = ifelse(!is.na(AMPM), str_remove(timestamp, 'AM|PM'), timestamp))
```

Formats - Those with russian letters is in format Day Month Year Hour
Minute. 1022 records - those with APMP has month, day, year, hour minute
format. 1025 records - those with UTC is in format year month day hour
minute second

Create new column fixed timestamp and populate using timestamp

``` r
checkin = checkin %>%
        mutate(fixed_timestamp = if_else(has_utc, ymd_hms(timestamp), NA_real_)) %>% #format for utc
        mutate(fixed_timestamp = if_else(to_change, dmy_hm(timestamp), fixed_timestamp)) %>%
        mutate(fixed_timestamp = if_else(!is.na(AMPM), mdy_hm(timestamp), fixed_timestamp))
```

Remove unnecessary columns

``` r
checkin = checkin %>%
        select(-month_russian, -english_months) %>%
        rename(has_russian = to_change)
```

### Adjust the time based on timezone and AMPM

263 Entries with PM and 762 with AM

``` r
checkin %>%
        count(AMPM) %>%
  kable()
```

| AMPM |     n |
|:-----|------:|
| AM   |   762 |
| PM   |   263 |
| NA   | 19475 |

Some AM and PM were just entry errors. Fix timestamp of AM AND PM based
on next and previous entries

``` r
checkin = checkin %>%
        mutate(prev_entry = lead(fixed_timestamp)) %>% #create next and prev timestamp
        mutate(next_entry = lag(fixed_timestamp)) %>%
        mutate(prev_entry_diff = abs(as.duration(fixed_timestamp - prev_entry))) %>% #compute for time difference
        mutate(next_entry_diff = abs(as.duration(next_entry - fixed_timestamp))) %>% 
        mutate(big_diff = prev_entry_diff > hours(3) & next_entry_diff > hours(3)) %>% #counted big difference if both entries are 3 hrs away
        mutate(fixed_timestamp = if_else((big_diff & !is.na(AMPM) & AMPM == 'AM'), fixed_timestamp - hours(12), fixed_timestamp)) %>% #adjust time
        mutate(fixed_timestamp = if_else((big_diff & !is.na(AMPM) & AMPM == 'PM'), fixed_timestamp + hours(12), fixed_timestamp)) 
```

Get only needed columns and adjust time for UTC

``` r
checkin = checkin %>%
        select(-prev_entry, -next_entry, -next_entry_diff, -prev_entry_diff, -big_diff, -AMPM, -has_russian, -has_utc) %>%
        mutate(fixed_timestamp = fixed_timestamp + hours(8)) %>%
        rename(raw_timesstamp = timestamp) %>%
        rename(timestamp = fixed_timestamp) %>%
        select(timestamp, user, hours, project, raw_timesstamp)
```

### Check hours data

``` r
summary(checkin$hours)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   0.000   0.750   1.325   2.071   3.000  30.000

30 hrs?

``` r
checkin %>%
        filter(hours > 12) %>%
        arrange(desc(hours)) %>%
  head(10) %>%
  kable()
```

| timestamp           | user   | hours | project    | raw_timesstamp             |
|:--------------------|:-------|------:|:-----------|:---------------------------|
| 2018-10-12 18:09:11 | shae   |  30.0 | project-43 | 2018-10-12 10:09:11.0001   |
| 2018-10-01 21:57:04 | shae   |  21.0 | project-43 | 2018-10-01 13:57:04.0001   |
| 2018-10-26 08:00:00 | shae   |  20.0 | project-30 | 2018-10-26 00:00:00        |
| 2018-08-16 08:00:00 | shae   |  20.0 | project-10 | 16 August 2018 00:00       |
| 2018-09-04 08:00:00 | shae   |  18.0 | project-10 | 09/04/2018 12:00           |
| 2018-09-27 23:56:31 | shae   |  16.0 | project-10 | 2018-09-27 15:56:31.0001   |
| 2018-06-21 08:00:00 | theon  |  15.5 | project-38 | 2018-06-21 00:00:00        |
| 2018-10-15 08:00:00 | shae   |  15.0 | project-30 | 2018-10-15 00:00:00        |
| 2018-09-14 08:00:00 | cersei |  15.0 | project-10 | 2018-09-14 00:00:00        |
| 2017-09-18 00:16:10 | shae   |  15.0 | project-55 | 2017-09-17 16:16:10.000023 |

All contains the word project.

## Check project

``` r
checkin %>%
        count(project) %>%
  arrange(desc(n)) %>%
  head(15) %>%
  kable()
```

| project              |    n |
|:---------------------|-----:|
| opsandadmin          | 2824 |
| bizdev               | 1784 |
| cultureandmanagement | 1273 |
| learning             | 1179 |
| project-00           |  946 |
| project-10           |  672 |
| website              |  639 |
| project-40           |  612 |
| blogideas            |  567 |
| project-43           |  526 |
| project-68           |  485 |
| project-64           |  484 |
| project-25           |  467 |
| project-65           |  465 |
| project-20           |  456 |

There are some typos in the project column

Fix typos

``` r
checkin = checkin %>%
        mutate(project = str_replace(project, 'blogideas', 'blog-ideas'),
               project = str_replace(project, '^c(.*)and(.*)','cultureandmanagement'),
               project = str_replace(project, 'hirng','hiring'),
               project = str_replace(project, 'internals','internal'),
               project = str_replace(project, 'machine-learning','machinelearning'),
               project = str_replace(project, 'misc','miscellaneous'),
               project = str_replace(project, '^op(.*)min$','opsandadmin'),
               project = str_replace(project, 'pm','projectmanagement'),
               project = str_replace(project, 'workshops','workshop'))
```

Check missing users

``` r
checkin %>%
        mutate(row = row_number()) %>%
        slice(15790:15810) %>%
  kable()
```

| timestamp           | user         | hours | project     | raw_timesstamp             |   row |
|:--------------------|:-------------|------:|:------------|:---------------------------|------:|
| 2017-12-28 22:25:23 | theon        |  7.00 | project-40  | 2017-12-28 14:25:23.000094 | 15790 |
| 2017-12-28 08:00:00 | bronn        |  3.50 | website     | 2017-12-28 00:00:00        | 15791 |
| 2017-12-28 08:00:00 | jorah        |  4.50 | project-40  | 28 December 2017 00:00     | 15792 |
| 2017-12-28 08:00:00 | bronn        |  0.50 | project-40  | 2017-12-28 00:00:00        | 15793 |
| 2017-12-27 21:59:59 | tywin        |  4.00 | bizdev      | 2017-12-27 13:59:59.000271 | 15794 |
| 2017-12-27 21:59:59 | tywin        |  4.00 | workshop    | 2017-12-27 13:59:59.000271 | 15795 |
| 2017-12-27 21:59:59 | tywin        |  1.00 | learning    | 2017-12-27 13:59:59.000271 | 15796 |
| 2017-12-27 21:38:38 | bronn        |  8.00 | website     | 2017-12-27 13:38:38.000086 | 15797 |
| 2017-12-27 18:36:14 | NA           |  4.00 | project-40  | 2017-12-27 10:36:14.000121 | 15798 |
| 2017-12-27 18:36:14 | NA           |  3.00 | learning    | 2017-12-27 10:36:14.000121 | 15799 |
| 2017-12-27 15:28:22 | margaery     |  3.00 | learning    | 2017-12-27 07:28:22.000135 | 15800 |
| 2017-12-27 15:28:22 | margaery     |  2.00 | project-24  | 2017-12-27 07:28:22.000135 | 15801 |
| 2017-12-27 14:03:12 | theon        |  3.50 | project-40  | 2017-12-27 06:03:12.000166 | 15802 |
| 2017-12-27 08:00:00 | brienne      |  1.25 | workshop    | 2017-12-27 00:00:00        | 15803 |
| 2017-12-27 08:00:00 | brienne      |  5.50 | hiring      | 2017-12-27 00:00:00        | 15804 |
| 2017-12-27 08:00:00 | brienne      |  1.50 | opsandadmin | 2017-12-27 00:00:00        | 15805 |
| 2017-12-27 08:00:00 | brienne      |  5.00 | hiring      | 2017-12-27 00:00:00        | 15806 |
| 2017-12-27 08:00:00 | littlefinger |  6.00 | opsandadmin | 2017-12-27 00:00:00        | 15807 |
| 2017-12-26 22:54:24 | theon        |  4.50 | project-40  | 2017-12-26 14:54:24.00013  | 15808 |
| 2017-12-26 19:03:35 | brienne      |  4.00 | opsandadmin | 2017-12-26 11:03:35.000059 | 15809 |
| 2017-12-26 19:03:00 | brienne      |  1.00 | hiring      | 12/26/2017 11:03           | 15810 |

2 missing entries on December 27 with same timein

``` r
checkin %>%
        mutate(row = row_number()) %>%
        slice(17570:17580) %>%
  kable()
```

| timestamp           | user   | hours | project              | raw_timesstamp             |   row |
|:--------------------|:-------|------:|:---------------------|:---------------------------|------:|
| 2017-10-12 18:55:02 | bronn  |  2.00 | opsandadmin          | 2017-10-12 10:55:02.000393 | 17570 |
| 2017-10-12 18:53:36 | tyrion |  3.00 | learning             | 2017-10-12 10:53:36.000349 | 17571 |
| 2017-10-12 18:53:36 | tyrion |  4.00 | datastorytelling     | 2017-10-12 10:53:36.000349 | 17572 |
| 2017-10-12 18:31:44 | NA     |  2.75 | project-47           | 2017-10-12 10:31:44.000227 | 17573 |
| 2017-10-12 18:31:44 | NA     |  4.00 | bizdev               | 2017-10-12 10:31:44.000227 | 17574 |
| 2017-10-12 18:31:44 | NA     |  1.00 | transit              | 2017-10-12 10:31:44.000227 | 17575 |
| 2017-10-12 17:05:00 | theon  |  1.00 | cultureandmanagement | 12 October 2017 09:05      | 17576 |
| 2017-10-12 17:05:08 | theon  |  2.00 | blog-ideas           | 2017-10-12 09:05:08.000039 | 17577 |
| 2017-10-12 17:05:08 | theon  |  5.00 | learning             | 2017-10-12 09:05:08.000039 | 17578 |
| 2017-10-12 16:20:00 | jorah  |  1.50 | bizdev               | 12 October 2017 08:20      | 17579 |
| 2017-10-12 16:20:37 | jorah  |  1.00 | cultureandmanagement | 2017-10-12 08:20:37.000335 | 17580 |

Same with last time. Consecutive missing data with same timein. Probably
the same person. Cant use previous or next entries for imputation.

There’s not much data types to predict 5 missing values

[Onto the
EDA](https://github.com/idellang/CastanedaTM_Ans/tree/master/CleaningData)

## Function to summarize data cleaning

``` r
clean_data = function(data){
        
        data = data %>%
                mutate(has_utc = str_detect(timestamp, 'UTC')) %>%
                mutate(timestamp = str_remove(timestamp,'UTC')) %>%
                mutate(has_letter = str_detect(timestamp, '[:alpha:]')) %>%
                mutate(notAMPM = str_detect(timestamp, 'AM|PM', negate =  TRUE)) %>%
                mutate(to_change = (has_letter & notAMPM)) %>%
                select(-has_letter, -notAMPM)
        
        data = data %>%
                mutate(month_russian = str_extract(timestamp, '[:alpha:]+')) %>%
                mutate(month_russian = ifelse(str_detect(month_russian, 'AM|PM'), NA, month_russian))
        
        months = data %>%
                distinct(month_russian) %>%
                filter(!is.na(month_russian))
        
        
        english_months = c('September','November','October','August', 'July','June','May','April','March','February','January','December')
        
        months$english_months = english_months
        
        data = data %>%
                left_join(months, by = c('month_russian' = 'month_russian')) %>%
                mutate(timestamp = ifelse(to_change, str_replace(timestamp,month_russian, english_months), timestamp))
        
        data = data %>%
                mutate(AMPM = str_extract(timestamp, 'AM|PM')) %>%
                mutate(timestamp = ifelse(!is.na(AMPM), str_remove(timestamp, 'AM|PM'), timestamp))
        
        data = data %>%
                mutate(fixed_timestamp = if_else(has_utc, ymd_hms(timestamp), NA_real_)) %>% #format for utc
                mutate(fixed_timestamp = if_else(to_change, dmy_hm(timestamp), fixed_timestamp)) %>%
                mutate(fixed_timestamp = if_else(!is.na(AMPM), mdy_hm(timestamp), fixed_timestamp))
        
        data = data %>%
                select(-month_russian, -english_months) %>%
                rename(has_russian = to_change)
        
        data = data %>%
                mutate(prev_entry = lead(fixed_timestamp)) %>% #create next and prev timestamp
                mutate(next_entry = lag(fixed_timestamp)) %>%
                mutate(prev_entry_diff = abs(as.duration(fixed_timestamp - prev_entry))) %>% #compute for time difference
                mutate(next_entry_diff = abs(as.duration(next_entry - fixed_timestamp))) %>% 
                mutate(big_diff = prev_entry_diff > hours(3) & next_entry_diff > hours(3)) %>% #counted big difference if both entries are 6 hrs away
                mutate(fixed_timestamp = if_else((big_diff & !is.na(AMPM) & AMPM == 'AM'), fixed_timestamp - hours(12), fixed_timestamp)) %>% #adjust time
                mutate(fixed_timestamp = if_else((big_diff & !is.na(AMPM) & AMPM == 'PM'), fixed_timestamp + hours(12), fixed_timestamp)) 
        
        data = data %>%
                select(-prev_entry, -next_entry, -next_entry_diff, -prev_entry_diff, -big_diff, -AMPM, -has_russian, -has_utc) %>%
                mutate(fixed_timestamp = fixed_timestamp + hours(8)) %>%
                rename(raw_timesstamp = timestamp) %>%
                rename(timestamp = fixed_timestamp) %>%
                select(timestamp, user, hours, project)
        
        data = data %>%
                mutate(project = str_replace(project, 'blogideas', 'blog-ideas'),
                       project = str_replace(project, '^c(.*)and(.*)','cultureandmanagement'),
                       project = str_replace(project, 'hirng','hiring'),
                       project = str_replace(project, 'internals','internal'),
                       project = str_replace(project, 'machine-learning','machinelearning'),
                       project = str_replace(project, 'misc','miscellaneous'),
                       project = str_replace(project, '^op(.*)min$','opsandadmin'),
                       project = str_replace(project, 'pm','projectmanagement'),
                       project = str_replace(project, 'workshops','workshop'))
        
        data
}
```

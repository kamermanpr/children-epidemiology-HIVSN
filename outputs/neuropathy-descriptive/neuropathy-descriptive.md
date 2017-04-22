---
title: 'HIV-SN in children'
subtitle: 'Descriptive analyses: Neuropathy'
author: Peter Kamerman 
date: "22 April 2017"
output: 
  html_document:
    theme: yeti
    highlight: haddock
    code_folding: show
    toc: true
    toc_depth: 4
    toc_float: true
    df_print: paged
---



## Quick look at the data

```r
# 'Top-n-tail' data
head(data)
```

```
## # A tibble: 6 × 16
##       ID BPNS.prev.pain BPNS.current.pain BPNS.pin.n.needles BPNS.numbness
##    <chr>          <chr>             <chr>              <chr>         <chr>
## 1 ID8120             No                No                 No            No
## 2 ID8078             No                No                 No            No
## 3 ID8076             No                No                 No            No
## 4 ID8093             No                No                 No            No
## 5 ID8177            Yes                No                 No            No
## 6 ID8190            Yes                No                 No            No
## # ... with 11 more variables: BPNS.reduced.vibration.RL <chr>,
## #   BPNS.absent.reflex.RL <chr>, Other.symp.cramping <chr>,
## #   Other.symp.itching <chr>, Other.symp.painful.cold <chr>,
## #   Reduced.pin.prick.RL <chr>, Symptoms <chr>, Neuropathy <chr>,
## #   Neuropathy_pin <chr>, Symp.Neuropathy <chr>, Symp.Neuropathy_pin <chr>
```

```r
tail(data)
```

```
## # A tibble: 6 × 16
##       ID BPNS.prev.pain BPNS.current.pain BPNS.pin.n.needles BPNS.numbness
##    <chr>          <chr>             <chr>              <chr>         <chr>
## 1 ID8147             No                No                 No            No
## 2 ID8151            Yes               Yes                 No            No
## 3 ID8161            Yes               Yes                Yes            No
## 4 ID8209             No                No                 No            No
## 5 ID8111             No                No                 No            No
## 6 ID8220            Yes                No                 No            No
## # ... with 11 more variables: BPNS.reduced.vibration.RL <chr>,
## #   BPNS.absent.reflex.RL <chr>, Other.symp.cramping <chr>,
## #   Other.symp.itching <chr>, Other.symp.painful.cold <chr>,
## #   Reduced.pin.prick.RL <chr>, Symptoms <chr>, Neuropathy <chr>,
## #   Neuropathy_pin <chr>, Symp.Neuropathy <chr>, Symp.Neuropathy_pin <chr>
```

```r
# Check structure
glimpse(data)
```

```
## Observations: 135
## Variables: 16
## $ ID                        <chr> "ID8120", "ID8078", "ID8076", "ID809...
## $ BPNS.prev.pain            <chr> "No", "No", "No", "No", "Yes", "Yes"...
## $ BPNS.current.pain         <chr> "No", "No", "No", "No", "No", "No", ...
## $ BPNS.pin.n.needles        <chr> "No", "No", "No", "No", "No", "No", ...
## $ BPNS.numbness             <chr> "No", "No", "No", "No", "No", "No", ...
## $ BPNS.reduced.vibration.RL <chr> "Yes", "No", "No", "No", "No", "No",...
## $ BPNS.absent.reflex.RL     <chr> "No", "No", "No", "No", NA, "No", "N...
## $ Other.symp.cramping       <chr> "No", "No", "No", "No", "No", "No", ...
## $ Other.symp.itching        <chr> "No", "No", "No", "No", "No", "No", ...
## $ Other.symp.painful.cold   <chr> "No", "No", "No", "No", "No", "No", ...
## $ Reduced.pin.prick.RL      <chr> "No", "No", "No", "No", "No", "No", ...
## $ Symptoms                  <chr> "No", "No", "No", "No", "No", "No", ...
## $ Neuropathy                <chr> "Yes", "No", "No", "No", "No", "No",...
## $ Neuropathy_pin            <chr> "Yes", "No", "No", "No", "No", "No",...
## $ Symp.Neuropathy           <chr> "No", "No", "No", "No", "No", "No", ...
## $ Symp.Neuropathy_pin       <chr> "No", "No", "No", "No", "No", "No", ...
```

****

## Prevalence of HIV-SN (pin-prick)
**Case definition of SN:**  

- _Brief Peripheral Neuropathy Screen (BPNS) + pin-prick_

- _At least one bilateral sign (reduced/absent vibration sense, absent ankle-jerk reflexes, reduced/absent pin-prick)_  

**Case definition of symptomatic SN:** 

- _As above, plus at least one bilateral symptom (pain/aching/burning, tingling/pins-and-needles, numbness)_

### Boot functions

```r
############################################################
#                                                          #
#                      Boot functions                      #
#                                                          #
############################################################
# Use package 'boot' to calculate bootstrap 95%CI

## Any SN
sn_prev <- function(data, i) {
    dat <- data[i, ]
    len <- dat %>%
        select(Neuropathy_pin) %>%
        filter(Neuropathy_pin == 'Yes') %>%
        nrow()
    len2 <- nrow(dat)
    prev <- 100 * len / len2
    prev
}

## Symptomatic SN
symp.sn_prev <- function(data, i) {
    dat <- data[i,]
    len <- dat %>%
        select(Symp.Neuropathy_pin) %>%
        filter(Symp.Neuropathy_pin == 'Yes') %>%
        nrow()
    len2 <- nrow(dat)
    prev <- 100 * len / len2
    return(prev)
}
```

### Prevalence summaries
#### SN prevalence (whole cohort) 

```r
# Counts
sn_point <- data %>%  
    group_by(Neuropathy_pin) %>%  
    summarise(N = n(), Percent = 100 * (n() / nrow(data)))

pander(sn_point[ , 1:2], 
       caption = 'SN vs SN-free (count)', justify = 'lr')
```


--------------------
Neuropathy_pin     N
---------------- ---
No               101

Yes               34
--------------------

Table: SN vs SN-free (count)

```r
# Bootstrap 95% CI
sn_boot <- boot(data = data, 
              statistic = sn_prev, 
              R = 1000)

sn_bootCI <- boot.ci(sn_boot, type = 'basic')

# Summary table
sn_tab <- data_frame(Group = 'Neuropathy_pin',
                     `Point prevalence` = round(sn_point$Percent[2], 1),
                     `Lower 95% CI limit` = round(sn_bootCI$basic[4], 1),
                     `Upper 95% CI limit` = round(sn_bootCI$basic[5], 1)) 
pander(sn_tab[ , 2:4], 
       caption = 'Prevalence of SN (%)', justify = 'rrr')
```


------------------------------------------------------------
  Point prevalence   Lower 95% CI limit   Upper 95% CI limit
------------------ -------------------- --------------------
              25.2                   17                 32.6
------------------------------------------------------------

Table: Prevalence of SN (%)

#### Symptomatic SN+ (SN+ cohort only)

```r
# Subset out the SN+ participants
data.sn_only <- data %>%
    filter(Neuropathy_pin == 'Yes')

# Counts
symp.sn_point <- data.sn_only %>%  
    group_by(Symp.Neuropathy_pin) %>%  
    summarise(N = n(), Percent = 100 * (n() / nrow(data.sn_only)))

pander(symp.sn_point[ , 1:2], 
       caption = 'Symptomatic SN (SN+ only, count)', justify = 'lr')
```


-------------------------
Symp.Neuropathy_pin     N
--------------------- ---
No                     22

Yes                    12
-------------------------

Table: Symptomatic SN (SN+ only, count)

```r
# Bootstrap 95% CI
symp.sn_boot <- boot(data = data.sn_only, 
                     statistic = symp.sn_prev, 
                     R = 1000)

symp.sn_bootCI <- boot.ci(symp.sn_boot, type = 'basic')

# Summary table
symp.sn_tab <- data_frame(Group = 'Symptomatic HIV-SN',
                          `Point prevalence` = round(symp.sn_point$Percent[2], 1),
                          `Lower 95% CI limit` = round(symp.sn_bootCI$basic[4], 1),
                          `Upper 95% CI limit` = round(symp.sn_bootCI$basic[5], 1))
pander(symp.sn_tab[ , 2:4], 
       caption = 'Prevalence of Symptomatic SN (SN+ only, %)', justify = 'rrr')
```


------------------------------------------------------------
  Point prevalence   Lower 95% CI limit   Upper 95% CI limit
------------------ -------------------- --------------------
              35.3                 20.6                   50
------------------------------------------------------------

Table: Prevalence of Symptomatic SN (SN+ only, %)

### Characteristics of symptomatic SN

```r
############################################################
#                                                          #
#     Not very informative because of the small number     #
#         (n = 12) of children with symptomatic SN          #
#                                                          #
############################################################
# Filter out only those with symptomatic SN (primary definition)
symptomatic_sn <- data %>%
    filter(Symp.Neuropathy_pin == 'Yes')

# Extract symptoms
symptoms_sn <- symptomatic_sn %>%
    select(BPNS.numbness, BPNS.prev.pain, BPNS.current.pain, BPNS.pin.n.needles,
           Other.symp.itching, Other.symp.cramping, Other.symp.painful.cold) %>%
    rename(Numbness = BPNS.numbness, 
           `Previous pain` = BPNS.prev.pain,
           `Current pain` = BPNS.current.pain, 
           `Pins and needles` = BPNS.pin.n.needles,
           Itch = Other.symp.itching, 
           Cramping = Other.symp.cramping, 
           `Painful cold` = Other.symp.painful.cold)

# Table point estimates of symptom prevalences (%)
symptom_tab <- symptoms_sn %>%
    summarise_each(funs(round(sum(. == 'Yes', na.rm = TRUE)))) %>%
    gather(key = key,
           value = n) %>%
    mutate(percent = round(n / nrow(symptomatic_sn) * 100)) %>%
    arrange(desc(n))

# Table
pander(symptom_tab, 
       caption = 'Prevalence (%) of symptoms in 12 children with symptomatic HIV-SN', 
       justify = 'lrr', split.tables = Inf)
```


------------------------------
key                n   percent
---------------- --- ---------
Previous pain     12       100

Current pain      11        92

Painful cold       5        42

Pins and needles   4        33

Cramping           3        25

Numbness           2        17

Itch               2        17
------------------------------

Table: Prevalence (%) of symptoms in 12 children with symptomatic HIV-SN

### Characteristics of SN signs

```r
# Filter out only those with SN
sn_signs <- data %>%
    filter(Neuropathy_pin == 'Yes')

# Extract signs
signs_sn <- sn_signs %>%
    select(BPNS.absent.reflex.RL, BPNS.reduced.vibration.RL, Reduced.pin.prick.RL) %>%
    rename(`Absent reflexes` = BPNS.absent.reflex.RL, 
           `Absent/Reduced vibration sense` = BPNS.reduced.vibration.RL,
           `Absent/reduced pin-prick sense` = Reduced.pin.prick.RL)

# Table point estimates of signs prevalences (%)
signs_tab <- signs_sn %>%
    summarise_each(funs(round(sum(. == 'Yes', na.rm = TRUE)))) %>%
    gather(key = key,
           value = n) %>%
    mutate(percent = round(n / nrow(signs_sn) * 100)) %>%
    arrange(desc(n))

# Table
pander(signs_tab, 
       caption = 'Prevalence (%) of signs in 34 children with HIV-SN', 
       justify = 'lrr', split.tables = Inf)
```


--------------------------------------------
key                              n   percent
------------------------------ --- ---------
Absent/reduced pin-prick sense  22        65

Absent/Reduced vibration sense  17        50

Absent reflexes                  1         3
--------------------------------------------

Table: Prevalence (%) of signs in 34 children with HIV-SN

****

## Prevalence of HIV-SN (BPNS)
**Case definition of SN:**  

- _Brief Peripheral Neuropathy Screen (BPNS) only_

- _At least one bilateral sign (reduced/absent vibration sense, absent ankle-jerk reflexes; NB: no pin-prick)_  

**Case definition of symptomatic SN:** 

- _As above, plus at least one bilateral symptom (pain/aching/burning, tingling/pins-and-needles, numbness)_

### Boot functions

```r
############################################################
#                                                          #
#                      Boot functions                      #
#                                                          #
############################################################
# Use package 'boot' to calculate bootstrap 95%CI

## Any SN
sn_prev <- function(data, i) {
    dat <- data[i, ]
    len <- dat %>%
        select(Neuropathy) %>%
        filter(Neuropathy == 'Yes') %>%
        nrow()
    len2 <- nrow(dat)
    prev <- 100 * len / len2
    prev
}

## Symptomatic SN
symp.sn_prev <- function(data, i) {
    dat <- data[i,]
    len <- dat %>%
        select(Symp.Neuropathy) %>%
        filter(Symp.Neuropathy == 'Yes') %>%
        nrow()
    len2 <- nrow(dat)
    prev <- 100 * len / len2
    return(prev)
}
```

### Prevalence summaries
#### SN prevalence (whole cohort) 

```r
# Counts
sn_point <- data %>%  
    group_by(Neuropathy) %>%  
    summarise(N = n(), Percent = 100 * (n() / nrow(data)))

pander(sn_point[ , 1:2], 
       caption = 'SN vs SN-free (count)', justify = 'lr')
```


----------------
Neuropathy     N
------------ ---
No           117

Yes           18
----------------

Table: SN vs SN-free (count)

```r
# Bootstrap 95% CI
sn_boot <- boot(data = data, 
              statistic = sn_prev, 
              R = 1000)

sn_bootCI <- boot.ci(sn_boot, type = 'basic')

# Summary table
sn_tab <- data_frame(Group = 'Neuropathy',
                     `Point prevalence` = round(sn_point$Percent[2], 1),
                     `Lower 95% CI limit` = round(sn_bootCI$basic[4], 1),
                     `Upper 95% CI limit` = round(sn_bootCI$basic[5], 1)) 

pander(sn_tab[ , 2:4], 
       caption = 'Prevalence of SN (%)', justify = 'rrr')
```


------------------------------------------------------------
  Point prevalence   Lower 95% CI limit   Upper 95% CI limit
------------------ -------------------- --------------------
              13.3                  7.4                 18.5
------------------------------------------------------------

Table: Prevalence of SN (%)

#### Symptomatic SN+ (SN+ cohort only)

```r
# Subset out the SN+ participants
data.sn_only <- data %>%
    filter(Neuropathy == 'Yes')

# Counts
symp.sn_point <- data.sn_only %>%  
    group_by(Symp.Neuropathy) %>%  
    summarise(N = n(), Percent = 100 * (n() / nrow(data.sn_only)))

pander(symp.sn_point[ , 1:2], 
       caption = 'Symptomatic SN (SN+ only, count)', justify = 'lr')
```


---------------------
Symp.Neuropathy     N
----------------- ---
No                 13

Yes                 5
---------------------

Table: Symptomatic SN (SN+ only, count)

```r
# Bootstrap 95% CI
symp.sn_boot <- boot(data = data.sn_only, 
                     statistic = symp.sn_prev, 
                     R = 1000)

symp.sn_bootCI <- boot.ci(symp.sn_boot, type = 'basic')

# Summary table
symp.sn_tab <- data_frame(Group = 'Symptomatic HIV-SN',
                          `Point prevalence` = round(symp.sn_point$Percent[2], 1),
                          `Lower 95% CI limit` = round(symp.sn_bootCI$basic[4], 1),
                          `Upper 95% CI limit` = round(symp.sn_bootCI$basic[5], 1))

pander(symp.sn_tab[ , 2:4], 
       caption = 'Prevalence of Symptomatic SN (SN+ only, %)', justify = 'rrr')
```


------------------------------------------------------------
  Point prevalence   Lower 95% CI limit   Upper 95% CI limit
------------------ -------------------- --------------------
              27.8                  5.6                   50
------------------------------------------------------------

Table: Prevalence of Symptomatic SN (SN+ only, %)

### Characteristics of symptomatic SN

```r
############################################################
#                                                          #
#     Not very informative because of the small number     #
#         (n = 5) of children with symptomatic SN          #
#                                                          #
############################################################
# Filter out only those with symptomatic SN (primary definition)
symptomatic_sn <- data %>%
    filter(Symp.Neuropathy == 'Yes')

# Extract symptoms
symptoms_sn <- symptomatic_sn %>%
    select(BPNS.numbness, BPNS.prev.pain, BPNS.current.pain, BPNS.pin.n.needles,
           Other.symp.itching, Other.symp.cramping, Other.symp.painful.cold) %>%
    rename(Numbness = BPNS.numbness, 
           `Previous pain` = BPNS.prev.pain,
           `Current pain` = BPNS.current.pain, 
           `Pins and needles` =BPNS.pin.n.needles,
           Itch = Other.symp.itching, 
           Cramping = Other.symp.cramping, 
           `Painful cold` = Other.symp.painful.cold)

# Table point estimates of symptom prevalences (%)
symptom_tab <- symptoms_sn %>%
    summarise_each(funs(round(sum(. == 'Yes', na.rm = TRUE)))) %>%
    gather(key = key,
           value = n) %>%
    mutate(percent = round(n / nrow(symptomatic_sn) * 100)) %>%
    arrange(desc(n))#/ length(.x) * 100, 1)) 

# Table
pander(symptom_tab, 
       caption = 'Prevalence (%) of symptoms in 5 children with symptomatic HIV-SN', 
       justify = 'lrr', split.tables = Inf)
```


------------------------------
key                n   percent
---------------- --- ---------
Previous pain      5       100

Current pain       4        80

Painful cold       3        60

Itch               2        40

Numbness           1        20

Pins and needles   1        20

Cramping           1        20
------------------------------

Table: Prevalence (%) of symptoms in 5 children with symptomatic HIV-SN

### Characteristics of SN signs

```r
# Filter out only those with SN
sn_signs <- data %>%
    filter(Neuropathy == 'Yes')

# Extract signs
signs_sn <- sn_signs %>%
    select(BPNS.absent.reflex.RL, BPNS.reduced.vibration.RL) %>%
    rename(`Absent reflexes` = BPNS.absent.reflex.RL, 
           `Absent/Reduced vibration sense` = BPNS.reduced.vibration.RL)

# Table point estimates of signs prevalences (%)
signs_tab <- signs_sn %>%
    summarise_each(funs(round(sum(. == 'Yes', na.rm = TRUE)))) %>%
    gather(key = key,
           value = n) %>%
    mutate(percent = round(n / nrow(signs_sn) * 100)) %>%
    arrange(desc(n))

# Table
pander(signs_tab, 
       caption = 'Prevalence (%) of signs in 18 children with HIV-SN', 
       justify = 'lrr', split.tables = Inf)
```


--------------------------------------------
key                              n   percent
------------------------------ --- ---------
Absent/Reduced vibration sense  17        94

Absent reflexes                  1         6
--------------------------------------------

Table: Prevalence (%) of signs in 18 children with HIV-SN

****

## Session infomation
**R version 3.3.3 (2017-03-06)**

**Platform:** x86_64-apple-darwin13.4.0 (64-bit) 

**locale:**
en_GB.UTF-8||en_GB.UTF-8||en_GB.UTF-8||C||en_GB.UTF-8||en_GB.UTF-8

**attached base packages:** 
_stats_, _graphics_, _grDevices_, _utils_, _datasets_ and _base_

**other attached packages:** 
_boot(v.1.3-18)_, _pander(v.0.6.0)_, _stringr(v.1.2.0)_, _ggplot2(v.2.2.1)_, _readr(v.1.1.0)_, _tidyr(v.0.6.1)_ and _dplyr(v.0.5.0)_

**loaded via a namespace (and not attached):** 
_Rcpp(v.0.12.10)_, _knitr(v.1.15.1)_, _magrittr(v.1.5)_, _hms(v.0.3)_, _munsell(v.0.4.3)_, _colorspace(v.1.3-2)_, _R6(v.2.2.0)_, _plyr(v.1.8.4)_, _tools(v.3.3.3)_, _grid(v.3.3.3)_, _packrat(v.0.4.8-1)_, _gtable(v.0.2.0)_, _R.oo(v.1.21.0)_, _DBI(v.0.6-1)_, _lazyeval(v.0.2.0)_, _assertthat(v.0.2.0)_, _digest(v.0.6.12)_, _tibble(v.1.3.0)_, _ezknitr(v.0.6)_, _codetools(v.0.2-15)_, _R.utils(v.2.5.0)_, _evaluate(v.0.10)_, _stringi(v.1.1.5)_, _methods(v.3.3.3)_, _scales(v.0.4.1)_ and _R.methodsS3(v.1.7.1)_

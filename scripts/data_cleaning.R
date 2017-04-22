############################################################
#                                                          #
#                      Load packages                       #
#                                                          #
############################################################
library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(stringr)
library(lubridate)

############################################################
#                                                          #
#                       Data import                        #
#                                                          #
############################################################
data <- read_csv('./data/original_data.csv')

############################################################
#                                                          #
#                Remove possible duplicates                #
#                                                          #
############################################################
data <- data[!duplicated(data$id.code),]

############################################################
#                                                          #
#               Correct column data classes                #
#                                                          #
############################################################
## Add 'ID' prefix and rename id.code column
data <- transform(data, id.code = sprintf("ID%d", id.code)) %>%
    rename(., ID = id.code)

## 'Date.of.assessment' => date
data$Date.of.assessment <- dmy(data$Date.of.assessment)

## 'Date.of.birth' => date
data$Date.of.birth <- dmy(data$Date.of.birth)

############################################################
#                                                          #
#                 Remove unwanted columns                  #
#                                                          #
############################################################
# Remove derived columns where formulas were used in Excel
data <- data %>%
    select(-ends_with('.RL', ignore.case = FALSE),
           -starts_with('NeP', ignore.case = FALSE))

############################################################
#                                                          #
#                     Add new columns                      #
#                                                          #
############################################################
# Age and ART in years
######################
## Add Age (in years) and time on ART (in years) columns
data <- data %>%
    # Turn ART years months into a period
    mutate(ART.period = paste0(ART.start.age.years, ' years ',
                              Age.start.age.months, ' months')) %>%
    mutate(ART.period = as.period(ART.period, unit = 'years')) %>%
    # Add ART period object to date of birth
    mutate(ART.date.started = Date.of.birth + ART.period) %>%
    # Convert to ART date started into years
    mutate(ART.years = round(interval(ART.date.started, Date.of.assessment)
                                     / years(1), 2)) %>%
    # Add age in years
    mutate(Age.years = round(interval(Date.of.birth, Date.of.assessment)
                             / years(1), 2)) %>%
    # Remove intermediate columns
    select(-ART.period, -ART.date.started )

# Add derived columns on bilateral presence of signs
# Because NA is a valid logical, need to split each sign off into a new dataframe,
# filter out the NA's, perform the column comparison, and then finally join the
# new column onto the original dataframe.

# Vibration
###########
# Get rows with NA
vib.na <- data %>%
    select(ID, BPNS.reduced.vibration.R,
           BPNS.reduced.vibration.L) %>%
    filter(is.na(BPNS.reduced.vibration.R) |
               is.na(BPNS.reduced.vibration.L)) %>%
    mutate(BPNS.reduced.vibration.RL = factor(rep(NA, nrow(.)))) %>%
    select(ID, BPNS.reduced.vibration.RL)
# Get rows without NA
vib <- data %>%
    select(ID, BPNS.reduced.vibration.R,
           BPNS.reduced.vibration.L) %>%
    filter(!is.na(BPNS.reduced.vibration.R) |
               !is.na(BPNS.reduced.vibration.L)) %>%
    mutate(BPNS.reduced.vibration.RL =
               ifelse(BPNS.reduced.vibration.R == 'Yes' &
                          BPNS.reduced.vibration.L == 'Yes',
                      yes = 'Yes', no = 'No')) %>%
    select(ID, BPNS.reduced.vibration.RL)
# Bind rows from vib and vib.na
vib.all <- bind_rows(vib, vib.na)
vib.all$BPNS.reduced.vibration.RL <- factor(vib.all$BPNS.reduced.vibration.RL)
vib.all <- arrange(vib.all, ID)
# Join vib.all and data by ID, and then remove any duplicates that are generated
data <- left_join(data, vib.all)
data <- data[!duplicated(data$ID), ]

# Reflexes
##########
# Get rows with NA
reflex.na <- data %>%
    select(ID, BPNS.absent.reflex.R,
           BPNS.absent.reflex.L) %>%
    filter(is.na(BPNS.absent.reflex.R) |
               is.na(BPNS.absent.reflex.L)) %>%
    mutate(BPNS.absent.reflex.RL = factor(rep(NA, nrow(.)))) %>%
    select(ID, BPNS.absent.reflex.RL)
# Get rows without NA
reflex <- data %>%
    select(ID, BPNS.absent.reflex.R, BPNS.absent.reflex.L) %>%
    filter(!is.na(BPNS.absent.reflex.R) |
               !is.na(BPNS.absent.reflex.L)) %>%
    mutate(BPNS.absent.reflex.RL =
               ifelse(BPNS.absent.reflex.R == 'Yes' &
                           BPNS.absent.reflex.L == 'Yes',
                      yes = 'Yes', no = 'No')) %>%
    select(ID, BPNS.absent.reflex.RL)
# Bind rows from vib and vib.na
reflex.all <- bind_rows(reflex, reflex.na)
reflex.all$BPNS.absent.reflex.RL <- factor(reflex.all$BPNS.absent.reflex.RL)
reflex.all <- arrange(reflex.all, ID)
# Join reflex.all and data by ID, and then remove any duplicates that are generated
data <- left_join(data, reflex.all)
data <- data[!duplicated(data$ID), ]

# Pin.prick
###########
# Pin-prick has an unusual distributions of loss in many children, probably
# reflecting lack of understanding by the children about what was being asked

# Get rows with NA
prick.na <- data %>%
    select(ID, Other.signs.reduced.pin.prick.R,
           Other.signs.reduced.pin.prick.L) %>%
    filter(is.na(Other.signs.reduced.pin.prick.R) |
               is.na(Other.signs.reduced.pin.prick.L)) %>%
    mutate(Other.signs.reduced.pin.prick.RL =
               factor(rep(NA, nrow(.)))) %>%
    select(ID, Other.signs.reduced.pin.prick.RL)
# Get rows without NA
prick <- data %>%
    select(ID, Other.signs.reduced.pin.prick.R,
           Other.signs.reduced.pin.prick.L) %>%
    filter(!is.na(Other.signs.reduced.pin.prick.R) |
               !is.na(Other.signs.reduced.pin.prick.L)) %>%
    mutate(Other.signs.reduced.pin.prick.RL =
               ifelse(Other.signs.reduced.pin.prick.R == 'Yes' &
                          Other.signs.reduced.pin.prick.L == 'Yes',
                      yes = 'Yes', no = 'No')) %>%
    select(ID, Other.signs.reduced.pin.prick.RL)
# Bind rows from vib and vib.na
prick.all <- bind_rows(prick, prick.na)
prick.all$Other.signs.reduced.pin.prick.RL <-
    factor(prick.all$Other.signs.reduced.pin.prick.RL)
prick.all <- arrange(prick.all, ID)
# Join prick.all and data by ID, and then remove any duplicates that are generated
data <- left_join(data, prick.all)
# Rename 'Other.signs.reduced.pin.prick.RL' column
data <- data %>%
    rename(Reduced.pin.prick.RL = Other.signs.reduced.pin.prick.RL)

# Neuropathy classification
###########################
# Classification based on signs only.
# Primary classification is presence of at least one bilateral signs
# NB pin-prick was may be unreliable (odd distributions) and therefore
# classification performed with an without the inclusion of pin-prick.

# Issue with regex and <NA>, so insert dummy value 'NA'
data <- data %>%
    mutate(BPNS.reduced.vibration.RL =
               str_replace_na(BPNS.reduced.vibration.RL)) %>%
    mutate(BPNS.absent.reflex.RL =
               str_replace_na(BPNS.absent.reflex.RL)) %>%
    mutate(Reduced.pin.prick.RL =
               str_replace_na(Reduced.pin.prick.RL))

# SN classification
## Neuropathy_pin is classification with pin-prick
data <- data %>%
    mutate(Neuropathy = ifelse(BPNS.reduced.vibration.RL == 'Yes' |
                                   BPNS.absent.reflex.RL == 'Yes',
                               'Yes', 'No'),
           Neuropathy_pin = ifelse(BPNS.reduced.vibration.RL == 'Yes' |
                                       BPNS.absent.reflex.RL == 'Yes' |
                                       Reduced.pin.prick.RL == 'Yes',
                               'Yes', 'No'))

# Recode text 'NA' to <NA>
data$BPNS.reduced.vibration.RL[data$BPNS.reduced.vibration.RL == 'NA'] <- NA
data$BPNS.absent.reflex.RL[data$BPNS.absent.reflex.RL == 'NA'] <- NA
data$Reduced.pin.prick.RL[data$Reduced.pin.prick.RL == 'NA'] <- NA

# Any symptoms (neuropathy or no neuropathy)
data <- data %>%
    mutate(Symptoms = ifelse(BPNS.current.pain == 'Yes' |
                                 BPNS.pin.n.needles == 'Yes' |
                                 BPNS.numbness == 'Yes' |
                                 Other.symp.cramping == 'Yes' |
                                 Other.symp.itching == 'Yes' |
                                 Other.symp.painful.cold == 'Yes',
                             'Yes', 'No'))

# Symptomatic neuropathy
data <- data %>%
    mutate(Symp.Neuropathy = ifelse(Neuropathy == 'Yes' &
                                        Symptoms == 'Yes',
                                    'Yes', 'No'),
           Symp.Neuropathy_pin = ifelse(Neuropathy_pin == 'Yes' &
                                            Symptoms == 'Yes',
                                        'Yes', 'No'))

############################################################
#                                                          #
#                   Output cleaned data                    #
#                        & clean-up                        #
#                                                          #
############################################################
write_csv(data, './data/cleaned_data.csv')
rm(list = ls())


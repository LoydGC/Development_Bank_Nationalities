# clear environmwnt
rm(list=ls(all=TRUE))

#library time
library(rio)
library(tidyverse)
library(labelled)
library(data.table)
library(countrycode)

#Import spreadsheet

afdb_df = import("Data/AFDB_Board.xlsx")


#Check data

summary(afdb_df)

#Remove non-needed variables

afdb_df = select(afdb_df, "country", "year")

#Add board variable and assign 1 to all countries pre-balancing

afdb_df$board <- 1

#Fix Central African Republic

afdb_df$country = ifelse(afdb_df$country == "Republic of Central Africa", 
                         "Central African Republic", 
                         afdb_df$country)

#TEMP remove NAs for years without data. --- REMOVE CODE AFTER 2002 is added

afdb_df <- na.omit(afdb_df)

#Balance the data frame

afdb_df <- afdb_df %>%  
  complete(nesting(country), year = full_seq(year, period = 1))

#Replace NAs created by balancing with 0s

afdb_df$board <- ifelse(is.na(afdb_df$board), 0, afdb_df$board)


#Country Code

afdb_df$countrycode = countrycode(sourcevar = afdb_df$country, 
                                origin = "country.name", 
                                destination = "iso3c",
                                warn = FALSE)


#Check for NAs

check = afdb_df %>% 
  filter(is.na(countrycode))


#Remove check
remove(check)

#Create labels
var_label(afdb_df) <- list(`country` = "Country",
                         'year' = "Year",
                         'countrycode' = "Country Code",
                         'board' = "Executive Board")


#Move country code to be after country

afdb_df <- relocate(afdb_df, countrycode, .after = country )

#Export to Output Folder

export(afdb_df, "Output/AFDB.dta")
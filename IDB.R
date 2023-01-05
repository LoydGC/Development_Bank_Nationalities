# clear environmwnt
rm(list=ls(all=TRUE))

#library time
library(rio)
library(tidyverse)
library(labelled)
library(data.table)
library(countrycode)

#Import spreadsheet

idb_df = import("Data/IDB_Board.xlsx")


#Check data

summary(idb_df)

#Fix capitalization

idb_df$country <- str_to_title(idb_df$country)

#Remove alternate variable

idb_df <- select(idb_df, "country", "year", "board")

#Balance the data frame

idb_df <- idb_df %>%  
  complete(nesting(country), year = full_seq(year, period = 1))


#Country Code

idb_df$countrycode = countrycode(sourcevar = idb_df$country, 
                                 origin = "country.name", 
                                 destination = "iso3c",
                                 warn = FALSE)


#Check for NAs

check = idb_df %>% 
  filter(is.na(countrycode))

#Remove check

remove(check)

#Replace NAs created by balancing with 0s

idb_df$board <- ifelse(is.na(idb_df$board), 0, idb_df$board)


#Create labels
var_label(idb_df) <- list(`country` = "Country",
                                'year' = "Year",
                                'board' = "Executive Director",
                                'countrycode' = "Country Code")




#Move country code to be after country

idb_df <- relocate(idb_df, countrycode, .after = country )





#Export to Output Folder

export(idb_df, "Output/IDB.dta")
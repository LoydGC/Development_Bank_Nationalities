# clear environmwnt
rm(list=ls(all=TRUE))

#library time
library(rio)
library(tidyverse)
library(labelled)
library(data.table)
library(countrycode)

#Import spreadsheet

adb_df = import("Data/ADB_Board.xlsx")


#Check data

summary(adb_df)

#change Date to year

setnames(adb_df, "Date", "year")

#Make data long

adb_df<- pivot_longer(data=adb_df, 
                          -year,
                          names_to = "country",
                          values_to = "board")


#Country Code

adb_df$countrycode = countrycode(sourcevar = adb_df$country, 
                                 origin = "country.name", 
                                 destination = "iso3c",
                                 warn = FALSE)





#Check for NAs

check = adb_df %>% 
  filter(is.na(countrycode))

#Remove check

remove(check)


#Create labels
var_label(adb_df) <- list(`country` = "Country",
                          'year' = "Year",
                          'countrycode' = "Country Code",
                          'board' = "Executive Board")


#Move country code to be after country and year after country code

adb_df <- relocate(adb_df, countrycode, .after = country )

adb_df <- relocate(adb_df, year, .after = countrycode )


#Export to Output Folder

export(adb_df, "Output/ADB.dta")

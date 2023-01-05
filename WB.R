# clear environmwnt
rm(list=ls(all=TRUE))

#library time
library(rio)
library(tidyverse)
library(labelled)
library(data.table)
library(countrycode)

#Import spreadsheet

wb_df = import("Data/WB_Board.xlsx")


#Check data

summary(wb_df)

#Remove Notes Var

wb_df = select(wb_df, "country", "year")

#Fix Typo - UK

wb_df$country = ifelse(wb_df$country == "United Kindgdom", "United Kingdom", 
                       wb_df$country)

#Create board var and populate with 1s pre-balancing
wb_df$board <- 1

#Balance the df 

wb_df <- wb_df %>%  
  complete(nesting(country), year = full_seq(year, period = 1))


#Replace NAs from balancing with 0s 

wb_df$board <- ifelse(is.na(wb_df$board), 0, wb_df$board)

#Country Code

wb_df$countrycode = countrycode(sourcevar = wb_df$country, 
                                 origin = "country.name", 
                                 destination = "iso3c",
                                 warn = FALSE)





#Check for NAs

check = wb_df %>% 
  filter(is.na(countrycode))


#Fix Yugoslavia

wb_df$countrycode = ifelse(wb_df$country == "Yugoslavia", "YUG", 
                       wb_df$countrycode)

#Remove check
remove(check)

#Create labels
var_label(wb_df) <- list(`country` = "Country",
                          'year' = "Year",
                          'countrycode' = "Country Code",
                         'board' = "Executive Board")


#Move country code to be after country

wb_df <- relocate(wb_df, countrycode, .after = country )

#Export to Output Folder

export(wb_df, "Output/WB.dta")
# clear environmwnt
rm(list=ls(all=TRUE))

#library time
library(rio)
library(tidyverse)
library(labelled)
library(data.table)
library(countrycode)



#Import dataframes

afdb_df <- import("Output/AFDB.dta")
idb_df <- import("Output/IDB.dta")
wb_df <- import("Output/WB.dta")


#rename board variables to be distinct

afdb_df = setnames(afdb_df, "board", "af_board")

idb_df = setnames(idb_df, "board", "idb_board" )

wb_df = setnames(wb_df, "board", "wb_board")


##Merge dataframes on country code-year

#afdb and idb
devb_df = full_join(afdb_df, idb_df, by=c("countrycode", "year"))

# rename country.x to country in 1st merge
setnames(devb_df,"country.x", "country")

# if any of the values are missing in country, take them from country.y in 1st merge
devb_df$country = ifelse(is.na(devb_df$country) , devb_df$country.y, devb_df$country)

# now country.y from the data frame in 1st merge
devb_df = dplyr::select(devb_df, -country.y)

#devb_df + wb_df - 2nd merge

devb_df = full_join(devb_df, wb_df, by=c("countrycode", "year"))

# rename country.x to country in 2nd merge
setnames(devb_df,"country.x", "country")

# if any of the values are missing in country, take them from country.y in 2nd merge
devb_df$country = ifelse(is.na(devb_df$country) , devb_df$country.y, devb_df$country)

# remove country.y from the 3 db merged df in 2nd merge
devb_df = dplyr::select(devb_df, -country.y)


#Replace NAs with 0s

devb_df$af_board = ifelse(is.na(devb_df$af_board), 0, devb_df$af_board)
devb_df$idb_board = ifelse(is.na(devb_df$idb_board), 0, devb_df$idb_board)
devb_df$wb_board = ifelse(is.na(devb_df$wb_board), 0, devb_df$wb_board)


#Check new finished df

summary(devb_df)



#Balance the data frame

devb_df <- devb_df %>%  
  complete(nesting(country), year = full_seq(year, period = 1))

#Replace NAs from balancing

devb_df$af_board <- ifelse(is.na(devb_df$af_board), 0, devb_df$af_board)
devb_df$idb_board <- ifelse(is.na(devb_df$idb_board), 0, devb_df$idb_board)
devb_df$wb_board <- ifelse(is.na(devb_df$wb_board), 0, devb_df$wb_board)

#Relabel board vars

var_label(devb_df) <- list('af_board' = "African Development Board",
                           'idb_board' = "Inter-American Development Board",
                           'wb_board' = "World Bank Board",
                           'country' = "Country",
                           'year' = "Year")
#Remove old dfs

remove(afdb_df)
remove(idb_df)
remove(wb_df)


#Export --- Note: Not accurate until African Development Bank data is found from before 1976
## Current script assumes ALL relevant data has been coded in spreadsheet and included.
# As of now, missing data in af_board is turned into 0s but they likely have 1s 
export(devb_df, "Output/DEVB.dta")
library(tidyverse)
library(readr)
library(tidyext)

## import data ##
npidata_pfile_20050523_20181007 <- read_csv("npidata_pfile_20050523-20181007.csv")

## subset ##
NPI_must = npidata_pfile_20050523_20181007 %>% 
  select('NPI', 
         'Replacement NPI', 
         'Provider Last Name (Legal Name)', 
         'Provider First Name',
         'Provider Middle Name', 
         'Provider Gender Code',
         'Provider License Number_1' ,
         'Provider License Number State Code_1')
NPI_must = NPI_must %>% 
  mutate_if(is.factor, as.character)
save(NPI_must, file = "NPI_must.Rda")


# random sample 50,000
NPI_50000 = sample_n(NPI_must, 50000)

NPI_select = npidata_pfile_20050523_20181007 %>% 
  filter(str_detect(`Provider Credential Text`, 'M.D.|MD'))

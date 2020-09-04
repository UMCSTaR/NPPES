library(tidyverse)
library(readr)
library(tidyext)
library(data.table)

## import data ##
npidata_pfile_2020 <- fread("X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_20050523-20200112.csv")

# select 
npidata_pfile_2020_selected_var = npidata_pfile_2020 %>% 
  select('NPI',
         `Entity Type Code`,
         'Provider Last Name (Legal Name)', 
         'Provider First Name',
         'Provider Middle Name', 
         'Provider Gender Code',
         'Provider License Number_1' ,
         'Provider License Number State Code_1',
         'Provider Credential Text',
         'Healthcare Provider Taxonomy Code_1',
          contains("Deactivation"))


npidata_pfile_2020_selected_var = npidata_pfile_2020_selected_var %>% 
   rename(first_name = `Provider First Name`,
          last_name = `Provider Last Name (Legal Name)`,
          middle_name = `Provider Middle Name`)

save(npidata_pfile_2020_selected_var, file = "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var.rdata")

# Active Individual -------
npidata_individual = npidata_pfile_2020_selected_var %>%
  mutate(credential = str_replace_all(`Provider Credential Text`, "[^[:alpha:]]", "")) %>% 
  filter(`Entity Type Code` == 1) 

npidata_individual_active = npidata_individual %>% 
  filter(`NPI Deactivation Date` == "", is.na(`NPI Deactivation Reason Code`))

fwrite(npidata_individual_active, file = "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_individual_active.csv")


# save MD NPI ----
npidata_md = npidata_individual_active %>%
  # 1. clean credential for MD or any credential with "MD" 
  mutate(credential = str_replace_all(`Provider Credential Text`, "[^[:alpha:]]", "")) %>% 
  filter(str_detect(credential, 'MD'))


fwrite(npidata_md, file = "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var_md.csv")

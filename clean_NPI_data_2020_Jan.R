library(tidyverse)
library(readr)
library(tidyext)
library(data.table)

## import data ##
npidata_pfile_2020 <- read_csv("/Volumes/George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_20050523-20200112.csv")

names(npidata_pfile_2020)


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
          contains("Deactivation"))

save(npidata_pfile_2020_selected_var, file = "/Volumes/George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var.rdata")

# load selected vars
load("/Volumes/George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var.rdata")

npidata_pfile_2020_selected_var = npidata_pfile_2020_selected_var %>% 
   rename(first_name = `Provider First Name`,
          last_name = `Provider Last Name (Legal Name)`,
          middle_name = `Provider Middle Name`)

save(npidata_pfile_2020_selected_var, file = "/Volumes/George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var.rdata")


# save MD NPI
npidata_pfile_2020_selected_var_md = npidata_pfile_2020_selected_var %>%
  # 1. clean credential for MD or any credential with "MD" 
  mutate(credential = str_replace_all(`Provider Credential Text`, "[^[:alpha:]]", "")) %>% 
  filter(str_detect(credential, 'MD'), is.na(`NPI Deactivation Date`))


save(npidata_pfile_2020_selected_var_md, file = "/Volumes/George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var_md.rdata")


# save MD and DO NPI
npidata_pfile_2020_selected_var_md_do = npidata_pfile_2020_selected_var %>%
  # 1. clean credential for MD or any credential with "MD" or "DO"
  mutate(credential = str_replace_all(`Provider Credential Text`, "[^[:alpha:]]", "")) %>% 
  filter(str_detect(credential, 'MD|DO'), is.na(`NPI Deactivation Date`))


save(npidata_pfile_2020_selected_var_md_do, file = "/Volumes/George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var_md_do.rdata")

unique(npidata_pfile_2020_selected_var_md_do$`Provider Credential Text`)


npidata_pfile_2020_selected_var_md_do %>% 
  count(`Provider Credential Text`, sort = T)


# Only include NPI for individual --------
npidata_pfile_2020_selected_var %>%
  count(`Entity Type Code`)

npidata_pfile_2020_selected_var_individual = npidata_pfile_2020_selected_var %>%
  mutate(credential = str_replace_all(`Provider Credential Text`, "[^[:alpha:]]", "")) %>% 
  filter(`Entity Type Code` == 1) 

save(npidata_pfile_2020_selected_var_individual, file = "/Volumes/George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var_individual.rdata")


# Only include NPI for MD/DO/NA --------
npidata_pfile_2020_selected_var %>%
  count(`Entity Type Code`)

npidata_pfile_2020_selected_var_individual = npidata_pfile_2020_selected_var %>%
  mutate(credential = str_replace_all(`Provider Credential Text`, "[^[:alpha:]]", "")) %>% 
  filter(str_detect(credential, 'MD|DO'), is.na(`NPI Deactivation Date`))

npidata_pfile_2020_selected_var_individual_NA = npidata_pfile_2020_selected_var %>% 
  mutate(credential = str_replace_all(`Provider Credential Text`, "[^[:alpha:]]", "")) %>% 
  filter(is.na(credential), `Entity Type Code` == 1, is.na(`NPI Deactivation Date`))

npidata_pfile_2020_selected_var_md_do_na = rbind(npidata_pfile_2020_selected_var_individual, npidata_pfile_2020_selected_var_individual_NA) %>% 
  as_tibble()

save(npidata_pfile_2020_selected_var_md_do_na, file = "/Volumes/George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var_md_do_na.rdata")

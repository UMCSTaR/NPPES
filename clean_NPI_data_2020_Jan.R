library(tidyverse)
library(readr)
library(data.table)

## import data 
npidata_pfile_2020 <- fread("X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_20050523-20200112.csv")

## 1. select vars------
npidata_pfile_2020_selected_var = npidata_pfile_2020 %>% 
  select('NPI',
         `Entity Type Code`,
         'Provider Last Name (Legal Name)', 
         'Provider First Name',
         'Provider Middle Name', 
         'Provider Name Suffix Text',
         'Provider Gender Code',
         'Provider License Number_1' ,
         'Provider License Number State Code_1',
         'Provider Credential Text',
         'Healthcare Provider Taxonomy Code_1',
         contains("Deactivation"))


npidata_pfile_2020_selected_var = npidata_pfile_2020_selected_var %>% 
  rename(first_name = `Provider First Name`,
         last_name = `Provider Last Name (Legal Name)`,
         middle_name = `Provider Middle Name`,
         suffix = `Provider Name Suffix Text`)

# fwrite(npidata_pfile_2020_selected_var, file = "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var.csv")

# 2. Individual -------
npidata_individual = npidata_pfile_2020_selected_var %>%
  mutate(credential = str_replace_all(`Provider Credential Text`, "[^[:alpha:]]", "")) %>% 
  filter(`Entity Type Code` == 1) 

fwrite(npidata_individual, file = "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_individual.csv")


npidata_individual_active = npidata_individual %>% 
  filter(`NPI Deactivation Date` == "", is.na(`NPI Deactivation Reason Code`))

fwrite(npidata_individual_active, file = "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_individual_active.csv")


# 3. MD NPI ----
load("X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var.rdata")

npidata_individual = npidata_pfile_2020_selected_var %>%
  mutate(credential = str_replace_all(`Provider Credential Text`, "[^[:alpha:]]", "")) %>% 
  filter(`Entity Type Code` == 1) 

npidata_md = npidata_individual %>%
  # 1. clean credential for MD or any credential with "MD" 
  mutate(credential = str_replace_all(`Provider Credential Text`, "[^[:alpha:]]", "")) %>% 
  filter(str_detect(credential, 'MD'))

fwrite(npidata_md, file = "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_2020_selected_var_md.csv")

# 4. specialty ------
# taxonomy data for npi
taxonomy <- readr::read_csv("CROSSWALK_MEDICARE_PROVIDER_SUPPLIER_to_HEALTHCARE_PROVIDER_TAXONOMY.csv")

taxonomy_gs = taxonomy %>%
  filter(`MEDICARE SPECIALTY CODE` == "02",
         `PROVIDER TAXONOMY CODE` == "208600000X") 

anyDuplicated(taxonomy_gs$`PROVIDER TAXONOMY CODE`)
  
# 4.1. GS surgeons -----
npi_md_spty_gs = npidata_md %>%
  filter(`Healthcare Provider Taxonomy Code_1` %in% taxonomy_gs$`PROVIDER TAXONOMY CODE`)

fwrite(npi_md_spty_gs, file = "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npi_md_spty_gs.csv")


# 4.2 Surgery -----
taxonomy_surg = taxonomy %>% 
  filter(str_detect(`MEDICARE PROVIDER/SUPPLIER TYPE DESCRIPTION`, 'Surgery'))

npi_md_spty_surgery = npidata_md %>%
  filter(`Healthcare Provider Taxonomy Code_1` %in% taxonomy_surg$`PROVIDER TAXONOMY CODE`)

fwrite(npi_md_spty_surgery, file = "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npi_md_spty_surgery.csv")












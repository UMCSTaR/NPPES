library(tidyverse)

npidata_select <-
  data.table::fread(
    "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_20050523-20200112.csv",
    select = c(
      'NPI',
      'Entity Type Code',
      'Provider Last Name (Legal Name)',
      'Provider First Name',
      'Provider Middle Name',
      'Provider Gender Code',
      'Provider Credential Text',
      'NPI Deactivation Date',
      'Healthcare Provider Taxonomy Code_1'
    )
  )

# taxonomy data  for npi
taxonomy <- readr::read_csv("CROSSWALK_MEDICARE_PROVIDER_SUPPLIER_to_HEALTHCARE_PROVIDER_TAXONOMY.csv")


# filter MD, GS in NPPES------
# 1. add taxonomy filter for MD
npidata_md = npidata_select %>% 
  left_join(taxonomy, by = c('Healthcare Provider Taxonomy Code_1' = 'PROVIDER TAXONOMY CODE'))  %>% 
  mutate(credential = str_replace_all(`Provider Credential Text`, "[^[:alpha:]]", ""))  %>% 
  filter(str_detect(credential, 'MD'), `NPI Deactivation Date`  == "")

# 2. only keep single specialty surgeons
# 3. filter GS
npi_md_single_spty_gs = npidata_md %>% 
  filter(`MEDICARE SPECIALTY CODE` == "02") %>% 
  add_count(NPI) %>% 
  filter(n == 1) %>% 
  select(-n)

save(npi_md_single_spty_gs, file = "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npi_md_single_spty_gs_2020.rdata")


# add taxonomy to NPI
npi_selecct_vars = data.table::fread("X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npidata_pfile_20050523-20200112.csv",
                                select = c('NPI','Provider Credential Text','Healthcare Provider Taxonomy Code_1','Entity Type Code', 'NPI Deactivation Date'))

npi_taxonomy_individual = npi_selecct_vars %>% 
  filter(`Entity Type Code` == 1,
         `NPI Deactivation Date`  == "") %>%  # individual
  left_join(taxonomy, by = c('Healthcare Provider Taxonomy Code_1' = 'PROVIDER TAXONOMY CODE'))  

data.table::fwrite(npi_taxonomy_individual, file = "X:\\George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npi_taxonomy_individual.csv" )  

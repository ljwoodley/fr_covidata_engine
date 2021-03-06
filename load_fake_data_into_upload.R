library(tidyverse)
library(dotenv)
library(REDCapR)

# set the timezone
Sys.setenv(TZ = Sys.getenv("TIME_ZONE"))
Sys.getenv("INSTANCE")

records <- redcap_read_oneshot(redcap_uri = Sys.getenv("URI"),
                                       token = Sys.getenv("SURVEY_TOKEN"))$data %>% 
  filter(!is.na(research_encounter_id)) %>% 
  filter(is.na(covid_19_swab_result)) %>%
  select(research_encounter_id, covid_19_swab_result, igg_antibodies, igm_antibodies)

# note the number of records we have so we can make samples of the same size
n <- nrow(records)

# make some fake test results
results <- records %>%
  mutate(covid_19_swab_result = sample(c("Positive", "Negative", "negative", "positive"), n, replace = T)) %>%
  rename(record_id  = research_encounter_id) %>%
  mutate(igg_antibodies = sample(c("Positive", "Negative", "negative", "positive"), n, replace = T),
         igm_antibodies = sample(c("Positive", "Negative", "negative", "positive"), n, replace = T))

# Write data into the results project if it's safe to do so
if (Sys.getenv("INSTANCE") == "Development") {
  redcap_write_oneshot(results, 
                       redcap_uri = Sys.getenv("URI"),
                       token = Sys.getenv("RESULT_TOKEN"))
}



# turning the csv into md files, adapted from zackbatist/open-archaeo

library(glue)
library(stringr)
library(dplyr)
library(purrr)
library(readr)
library(jsonlite)
library(fs)
source("R/site.R")

conf_list <- readr::read_csv("ssla_conf_list.csv")

# Generate URL-friendly, unique slugs (lowercase, without spaces etc.)
conf_list %<>% 
  mutate(slug = clean_slug(Subject)) %>% 
  group_by(slug) %>% 
  mutate(slug = unique_slug(cur_data_all()))

# Merge multiple columns
conf_list %<>% 
  rowwise() %>% 
  mutate(
    links = list(as.list(cnotna(
      `Website` = `Website URL`,
      `Proposal-URL` = `Proposal URL`,
      `Sponsorship-URL` = `Sponsorship URL`
      ))),
    StartDate = `Start Date`,
    EndDate = `End Date`,
    SessionDeadline = `Session Deadline`,
    TalkDeadline = `Talk Deadline`,
    tags = list(cnotna(str_split(Tags,"\\|")))
  ) %>% 
  ungroup() %>%
  select(slug,
         Subject,
         Description,
         links,
         tags,
         StartDate,
         EndDate,
         Location,
         Country,
         Venue,
         SessionDeadline,
         TalkDeadline
)

# Generate .md files
conf_list %>% 
  rename(title = Subject) %>% 
  pmap(generate_post_md, path = "content/post/") %>% 
  invisible()

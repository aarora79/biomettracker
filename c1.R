library(gt)
library(xts)
library(zoo)
library(glue)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)
library(ggthemes)
library(dygraphs)
library(lubridate)
library(tidyverse)
library(flexdashboard)
library(futile.logger)
library(gridExtra)


deck_suits <- data.frame(house=c("hearts", "spades", "diamonds", "clubs"),
                         exercise=c("burpees", "sprints", "KB goblet squat into push press", "body rows"),
                         icon = c("♥", "♠" , "♦", "♣"))
m <- read_csv("raw_data/house_mapping.csv")
df <- read_csv("raw_data/2021_03_17.csv") %>%
  left_join(m, by="house") %>%
  left_join(deck_suits, by=c("house", "exercise")) %>%
  group_by(person) %>%
  mutate(set=row_number()) %>%
  mutate(total_reps = cumsum(reps)) %>%
  ungroup()  
  
df

tb <- deck_suits %>% select(icon, exercise)
data.tb <- tibble(x = 2, y = 200, tb = list(tb))

df %>%
  group_by(person) %>%
  mutate(label = if_else(set == max(set), as.character(person), NA_character_)) %>%
  ggplot(aes(x=set, y=total_reps, col=exercise, shape=icon)) + 
  geom_point(size=3) +
  geom_table(data = data.tb, aes(x, y, label = tb)) +
  scale_shape_identity() +
  geom_label_repel(aes(label = label),
                   nudge_x = 1,
                   na.rm = TRUE) +
  scale_x_continuous(breaks=seq(1, nrow(df), 1)) +
  scale_color_tableau() +
  theme_fivethirtyeight() + 
  labs(title="A fun workout on St. Patrick's day",
       subtitle="With a deck of cards") +
  theme(legend.position="none") +
  theme(axis.title = element_text(), legend.title = element_blank()) + 
  ylab('Total Reps') + xlab("Card Draw #")

df %>%
  group_by(person) %>%
  mutate(label = if_else(set == max(set), as.character(person), NA_character_)) %>%
  ggplot(aes(x=set, y=total_reps, col=person)) + 
  geom_point() +
  geom_smooth() +
  #geom_table(data = data.tb, aes(x, y, label = tb)) +
  #scale_shape_identity() +
  geom_label_repel(aes(label = label),
                   nudge_x = 1,
                   na.rm = TRUE) +
  scale_x_continuous(breaks=seq(1, nrow(df), 1)) +
  scale_color_tableau() +
  theme_fivethirtyeight() + 
  labs(title="A fun workout on St. Patrick's day",
       subtitle="With a deck of cards") +
  theme(legend.position="none") +
  theme(axis.title = element_text(), legend.title = element_blank()) + 
  ylab('Total Reps') + xlab("Card Draw #")


df_total_reps <- df %>%
  group_by(person) %>%
  summarize(reps=sum(reps)) %>%
  spread(person, reps)
df %>%
  group_by(person, exercise) %>%
  summarize(reps=sum(reps)) %>%
  left_join(deck_suits, by="exercise") %>%
  mutate(exercise = glue("{icon}\n{exercise}")) %>%
  mutate(exercise=fct_reorder(exercise, -reps)) %>%
  ggplot(aes(x=exercise, y=reps, col=person, fill=person)) +
  geom_bar(stat="identity", position="dodge") +
  geom_text(aes(label=reps), position=position_dodge(width=0.9), vjust=-0.25) +
  scale_color_tableau() +
  scale_fill_tableau() +
  theme_fivethirtyeight() + 
  labs(title="A fun workout on St. Patrick's day with a deck of cards",
       subtitle=glue("Nidhi did total {df_total_reps$Nidhi} reps, Amit did {df_total_reps$Amit} reps!")) +
  theme(legend.position="bottom") +
  theme(axis.title = element_text(), legend.title = element_blank()) + 
  ylab('Reps') + xlab("")
  
df %>%
  ggplot(aes(x=person, y=reps, col=person)) + 
  geom_boxplot() +
  scale_y_continuous(breaks=seq(1, max(df$reps), 1)) +
  scale_color_tableau() +
  scale_fill_tableau() +
  theme_fivethirtyeight() + 
  labs(title="Luck of the Irish",
       subtitle=glue("Nidhi had almost a 50% chance of picking a photo card, Amit only a 28% chance!"),
       caption="For every card we drew we did the number of reps on the card"
       ) +
  theme(legend.position="bottom") +
  theme(axis.title = element_text(), legend.title = element_blank()) + 
  ylab('Number on the card') + xlab("")

df %>%
  #group_by(person) %>%
  
  #summarize(q = quantile(reps, 0.5))

  mutate(gt_than_7 = ifelse(reps >= 10, "yes", "no")) %>%
  count(person, gt_than_7)

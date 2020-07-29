
library(glue)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggrepel)
library(ggthemes)
library(lubridate)
library(tidyverse)
library(futile.logger)

# read the raw data
START_DATE <- "2020-02-17"
DATA_DIR <- "data"
P1_NAME <- "Nidhi"
P2_NAME <- "Amit"
P1_DATA_FPATH <- file.path(DATA_DIR, glue("{P1_NAME}.csv"))
P2_DATA_FPATH <- file.path(DATA_DIR, glue("{P2_NAME}.csv"))
CAPTION <- "Source: Exported data from Ideal Protein app"
MONTH_ABB <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
IMPORTANT_DATES_FNAME <- "important_dates.csv"
IMPORTANT_DATES_FPATH <- file.path(DATA_DIR, IMPORTANT_DATES_FNAME)
NUDGE_X <- 1
NUDGE_Y <- 5

# print the parameters used
flog.info(glue("params used: START_DATE={START_DATE}, DATA_DIR={DATA_DIR},
                P1_NAME={P1_NAME}, P2_NAME={P2_NAME},
                P1_DATA_FPATH={P1_DATA_FPATH}, P2_DATA_FPATH={P2_DATA_FPATH}"))


df_P1 <- read_csv(P1_DATA_FPATH) %>%
  mutate(name=P1_NAME) %>%
  arrange(Date) %>%
  filter(Date >= START_DATE)
flog.info(glue("read data for {P1_NAME} from {P1_DATA_FPATH}, shape of dataframe={nrow(df_P1)}x{ncol(df_P1)}"))
print(head(df_P1))
print(summary(df_P1))

if(!is.na(P2_NAME)) {
  df_P2 <- read_csv(P2_DATA_FPATH) %>%
    mutate(name=P2_NAME) %>%
    arrange(Date) %>%
    filter(Date >= START_DATE)
  flog.info(glue("read data for {P2_NAME} from {P2_DATA_FPATH}, shape of dataframe={nrow(df_P2)}x{ncol(df_P2)}"))
  print(head(df_P2))  
  print(summary(df_P2))  
}

if(!is.na(IMPORTANT_DATES_FNAME)) {
  important_dates <- read_csv(IMPORTANT_DATES_FPATH)
  flog.info(glue("read data for important dates from {IMPORTANT_DATES_FNAME}, shape of dataframe={nrow(important_dates)}x{ncol(important_dates)}"))
  print(head(important_dates))  
  print(summary(important_dates))  
}

# combine the dataframes
if(!is.na(df_P2)) {
  df <- bind_rows(df_P1, df_P2)
  (df) %>%
    sample_n(5)
  flog.info(glue("combined data for {P1_NAME} and {P2_NAME}, shape of data is {nrow(df)}x{ncol(df)}"))
} else {
  flog.info(glue("only {P1_NAME} specified, only analyzing data for one person"))
  df <- df_P1
}


# get the data in tidy format
flog.info("converting the data to tidy format")
df_tidy <- df %>%
  gather(metric, value, -Date, -name)
df_tidy %>%
  sample_n(5)
flog.info(glue("shape of the tidy dataframe is {nrow(df_tidy)}x{ncol(df_tidy)}"))

# plot some basic charts, since we have multiple metrics for each date
# so a faceted timeseries would be useful
options(repr.plot.width=15, repr.plot.height=8) 
df_tidy %>%
  ggplot(aes(x=Date, y=value, col=name)) +
  geom_line() +
  facet_wrap(~metric, scales = "free_y") + 
  theme_fivethirtyeight() +
  xlab("") +
  labs(title=glue("Journey to health"),
       subtitle=glue("Tracking weight and other biometrics, Timespan: {min(df_tidy$Date)} to {max(df_tidy$Date)}"),
       caption=CAPTION) + 
  theme(text = element_text(size=20), legend.title = element_blank()) + 
  scale_color_tableau()

# weight loss per day
flog.info("creating a separate dataframe for tracking weight loss per day")
df_daily_wt_loss <- df_tidy %>%
  filter(metric == "Weight") %>%
  group_by(name) %>%
  mutate(daily_wt_loss = value - lag(value))

df_daily_wt_loss %>%
  sample_n(5)

df_daily_wt_loss %>%
  mutate(month = month.abb[month(Date)]) %>%
  mutate(month = factor(month, levels = MONTH_ABB)) %>%
  arrange(month) %>%
  ggplot(aes(x=month, y=daily_wt_loss, col=name)) +
  geom_violin(draw_quantiles = c(0.5)) +
  scale_color_tableau() +
  theme_fivethirtyeight() +
  labs(title=glue("Daily weight loss spread for each month"),
       subtitle=glue("Weight change from previous day (lb), Timespan: {min(df_tidy$Date)} to {max(df_tidy$Date)}"),
       caption=CAPTION) + 
  theme(text = element_text(size=20), legend.position = "none") + 
  theme(axis.title = element_text()) + ylab('Change in weight (lb)') +
  facet_wrap(~name)


# cumualative number of days on which weight was lost
flog.info("calculating cumulative weight loss as its own dataframe")
df_cumul_wt_loss_days <- df_daily_wt_loss %>%
  mutate(daily_wt_loss = ifelse(is.na(daily_wt_loss), 0, daily_wt_loss)) %>%
  mutate(was_this_a_wt_loss_day = (ifelse(daily_wt_loss < 0, 1, 0))) %>%
  mutate(cumul_wt_loss_days = cumsum(was_this_a_wt_loss_day)) %>%
  select(Date, name, cumul_wt_loss_days)

head(df_cumul_wt_loss_days, 5)


df_cumul_wt_loss_days_w_labels <- df_cumul_wt_loss_days %>%
  #mutate(label=ifelse(cumul_wt_loss_days==max(cumul_wt_loss_days), name, NA)) %>%
  left_join(important_dates, by=c("name", "Date")) %>%
  mutate(nudge_y = 5)

p <-  df_cumul_wt_loss_days_w_labels %>%
  ggplot(aes(x=Date, y=cumul_wt_loss_days, col=name)) +
  geom_line() +
  geom_point() + 
  theme_fivethirtyeight() +
  xlab("") + 
  labs(title=glue("Cumulative number of weight loss days"),
       subtitle=glue("Timespan: {min(df_tidy$Date)} to {max(df_tidy$Date)}"),
       caption=CAPTION) + 
  theme(text = element_text(size=20), legend.position = "bottom", legend.title=element_blank()) + 
  theme(axis.title = element_text()) + ylab('Number of days') +
  scale_color_tableau() +
  geom_text_repel(aes(label = label),
                  nudge_x = 1,
                  nudge_y = ifelse(df_cumul_wt_loss_days_w_labels[!is.na(df_cumul_wt_loss_days_w_labels$label), ]$name==P1_NAME, -NUDGE_Y, NUDGE_Y),
                  segment.size  = 0.3,
                  arrow = arrow(length = unit(0.02, "npc"), type = "closed", ends = "last"),
                  force = 10,
                  na.rm = TRUE)
p


df_days_to_next_drop <- df_daily_wt_loss %>%
  mutate(value = floor(value)) %>%
  ungroup() %>%
  group_by(name, value) %>%
  summarize(Date=max(Date)) %>%
  arrange(desc(Date)) %>%
  mutate(value_diff=value-lag(value), days=abs(as.numeric(Date-lag(Date)))) %>%
  replace_na(list(value_diff = 0, days = 0)) %>%
  mutate(value=value-min(value)) %>%
  filter(value != 0)

head(df_days_to_next_drop, 5)

p <- df_days_to_next_drop %>%
  ggplot(aes(x=value, y=days, col=name)) +
  geom_line() +
  geom_point() +
  theme_fivethirtyeight() +
  labs(title=glue("How many days does it take to lose a pound?"),
       subtitle=glue("Timespan: {min(df_tidy$Date)} to {max(df_tidy$Date)}"),
       caption=CAPTION) + 
  theme(axis.title = element_text()) + ylab('Days') + xlab("Pounds lost") +
  theme(text = element_text(size=20), legend.position="bottom", legend.title = element_blank()) + 
  scale_color_tableau()

p

# plot some basic charts, since we have multiple metrics for each date
# so a faceted timeseries would be useful
options(repr.plot.width=15, repr.plot.height=8) 
df_tidy %>%
  filter(metric=="Weight") %>%
  left_join(important_dates ,
            by=c("name","Date")) %>%
  ggplot(aes(x=Date, y=value, col=name)) +
  geom_line() +
  facet_wrap(~name, scales = "free_y") + 
  theme_fivethirtyeight() +
  xlab("") +
  labs(title=glue("The weight loss journey"),
       subtitle=glue("Tracking weight along with important events, Timespan: {min(df_tidy$Date)} to {max(df_tidy$Date)}"),
       caption=CAPTION) + 
  theme(text = element_text(size=20), legend.position="none") + 
  theme(axis.title = element_text()) + ylab('Weight (pounds)') +
  scale_color_tableau() + 
  geom_label_repel(aes(label = label),
                   nudge_y = -NUDGE_Y,
                   nudge_x=-3*NUDGE_X,
                   segment.size  = 0.3,
                   arrow = arrow(length = unit(0.02, "npc"), type = "closed", ends = "last"),
                   force = 10,
                   na.rm = TRUE)


df_daily_wt_loss %>%
  mutate(weekday = wday(Date, label = TRUE)) %>%
  group_by(name, weekday) %>%
  summarize(wt_loss = median(daily_wt_loss, na.rm=TRUE)) %>%
  ggplot(aes(x=weekday, y=-1*wt_loss, fill=name, col=name)) +
  geom_bar(position="dodge", stat="identity") +
  facet_wrap(~name) + 
  theme_fivethirtyeight() +
  xlab("") + 
  labs(title=glue("Daily weight loss"),
       subtitle=glue("Median loss in weight on each day of the week, Timespan: {min(df_tidy$Date)} to {max(df_tidy$Date)}"),
       caption=CAPTION) + 
  theme(axis.title = element_text()) + ylab('Weight change (lb)') +
  theme(text = element_text(size=20), legend.position = "none") + 
  scale_fill_tableau() +
  scale_color_tableau()


library(prophet)
df_wt <- df_tidy %>%
  filter(metric=="Weight" & name=="Nidhi") %>%
  rename(ds=Date, y=value) %>%
  select(ds, y)
df_wt$cap <- 160
df_wt$floor <- 120

m <- prophet(df_wt, growth = 'logistic')
#df_wt

# R
future <- make_future_dataframe(m, periods = 180)

future$floor <- 120
future$cap <- 160
tail(future)

# R
forecast <- predict(m, future)
tail(forecast[c('ds', 'yhat', 'yhat_lower', 'yhat_upper')])

# R
plot(m, forecast)

forecast %>%
  filter(yhat <= 128) %>%
  select(ds, yhat) %>%
  head(1)




library(prophet)
df_wt <- df_tidy %>%
  filter(metric=="Weight" & name=="Amit") %>%
  rename(ds=Date, y=value) %>%
  select(ds, y)
df_wt$cap <- 260
df_wt$floor <- 180

m <- prophet(df_wt, growth = 'logistic')
#df_wt

# R
future <- make_future_dataframe(m, periods = 180)

future$floor <- 180
future$cap <- 260
tail(future)

# R
forecast <- predict(m, future)
tail(forecast[c('ds', 'yhat', 'yhat_lower', 'yhat_upper')])

# R
plot(m, forecast)

forecast %>%
  filter(yhat <= 190) %>%
  select(ds, yhat) %>%
  head(1)


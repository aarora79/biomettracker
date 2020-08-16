### Were some days of the week better than others in terms of weight loss?
Is there a "curse of the weekend?" i.e. no weight loss or even a weight gain on Monday or Tuesday following indiscretions over the weekend?
  ```{r}
renderPlot({
  
  df_daily_wt_loss %>%
    mutate(weekday = wday(Date, label = TRUE)) %>%
    group_by(name, weekday) %>%
    summarize(wt_loss = median(daily_wt_loss, na.rm=TRUE)) %>%
    ggplot(aes(x=weekday, y=-1*wt_loss, fill=name, col=name)) +
    geom_bar(position="dodge", stat="identity") +
    # facet_wrap(~name) + 
    theme_fivethirtyeight() +
    xlab("") + 
    labs(title=glue("Median weight loss by day of week"),
         subtitle=glue("Timespan: {min(df_tidy$Date)} to {max(df_tidy$Date)}"),
         caption=CAPTION) + 
    theme(axis.title = element_text()) + ylab('Weight loss (lb)') +
    theme(text = element_text(size=CHART_ELEMENT_TEXT_SIZE_MOBILE), legend.position = "bottom") + 
    scale_fill_tableau() +
    scale_color_tableau()
})
```

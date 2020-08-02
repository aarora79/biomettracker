
#' forecast_wt_loss_timeseries
#' Function uses the prophet library to make a forecast. It uses the built in dygraph library to create a
#' chart object. An annotation is added on the chart object to indicate the date when the target weight loss
#' is achieved.
#' NOTE: As with any other forecast, it needs to be understood that this is valid only if the conditions
#' that exist in the training data continue in the future as well i.e. if there is no intervention then
#' this forecast should hold.
forecast_wt_loss_timeseries <- function(df_tidy, pname, pname_initial, weight_cap, weight_floor, forecast_range_in_days, weight_target) {
  # get the weight loss timeseries for this person and 
  # rename the fields as prophet requires 
  flog.info(glue("forecast_wt_loss_timeseries,
                 pname={pname},
                 weight_cap={weight_cap},
                 weight_floor={weight_floor},
                 forecast_range_in_days={forecast_range_in_days},
                 weight_target={weight_target}"), name=LOGGER)
  
  df_wt <- df_tidy %>%
    filter(metric=="Weight" & name==pname) %>%
    rename(ds=Date, y=value) %>%
    select(ds, y)
  flog.info(glue("forecast_wt_loss_timeseries, shape of the df_wt dataframe is {nrow(df_wt)}x{ncol(df_wt)}"), name=LOGGER)
  
  # set the cap and floor because we want to get to a saturated
  # minimum i.e. obviously the weight loss cannot continue infinitely.
  df_wt$cap <- as.integer(weight_cap)
  df_wt$floor <- as.integer(weight_floor)
  
  # for the saturating minimum we use the logistic model
  m <- prophet(df_wt, growth = 'logistic')
  
  # create a dataframe for the desired future duration
  future <- make_future_dataframe(m, periods = as.integer(forecast_range_in_days))
  
  # same floor and cap for the future as well
  future$floor <-  as.integer(weight_floor)
  future$cap <- as.integer(weight_cap)
  
  # run the forecast
  forecast <- predict(m, future)
  
  # save this dataframe to local file for display in a version of this dashboard
  # which just displays the results
  write_csv(forecast %>%
              left_join(m$history %>% select(ds, y), by="ds"),
            file.path(DATA_DIR, glue("forecast_{pname}.csv")))

  # find the date on which the target will be achieved. This is done by keeping only the entries
  # where the yhat is <= target and then finding the first such entry
  target_achieved_date <- forecast %>%
    filter(yhat <= as.integer(weight_target)) %>%
    arrange(desc(yhat)) %>%
    head(1) %>%
    mutate(ds = as.character(ds)) %>%
    pull(ds)
  # also save the target achievement data to a csv file
  write_csv(data.frame(date=target_achieved_date, target=weight_target), file.path(DATA_DIR, glue("target_achievement_{pname}.csv")))
  
  # all done, create an interactive plot object using dygraph. Use the first letter of the name as the
  # annotation symbol
  dyplot.prophet(m, forecast) %>%
    dyAnnotation(target_achieved_date, text = pname_initial, tooltip = glue("Target: {weight_target} lb, Expected date: {target_achieved_date}"))
  
}
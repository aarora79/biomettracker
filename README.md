# Biometric Tracker

Track weight, BMI and other metrics. Parse through the Ideal protein metrics, visualize and analyze.

## Tools Used

Python3 for data wrangling step and then R Shiny for the web application. The R packages used are Shiny, Flexdashboard, tidyr, tidyverse, dplyr for data analysis, ggplot2 and dygraph for visualization and Prophet for timeseries forecasting.

## Steps for adding new data and re-running the analysis

1. Get new data from the ideal protein website, this is done just by copy pasting from their web page. Save the copy pasted data in a file in the raw_data directory. Run the pre-processing step using the following  (pandas is required, see requirements.txt). The output file (CSV) will be created in the data directory.

```{bash}
python preprocess.py  --raw-data-filepath raw_data/raw_data_nidhi.txt --output-filename Nidhi.csv
```

2. Run the dashboard.Rmd in RStudio, this will create the timeseries forecasts and store the results as CSV file in the data directory. Publish the dashboard_no_prophet.Rmd and dashboard_mobile.Rmd as Shiny applications to shinyapps.io (requires sign-up).

## Links to Shiny Apps

1. Desktop Version: https://amit-arora.shinyapps.io/BiometTracker/

2. Mobile Version: https://amit-arora.shinyapps.io/BiometTrackerMobile/

## Home Gym

![](https://raw.githubusercontent.com/aarora79/biomettracker/master/gym.png)


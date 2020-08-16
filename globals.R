# global constants
# most of these should be configuration parameters

APP_NAME <- "biometric_tracker"
LOG_FILE <- file.path("/tmp", glue("{APP_NAME}.log"))
LOGGER <- APP_NAME
ABOUT_FILE <- "about.md"

START_DATE <- "2020-02-17"
DATA_DIR <- "data"
RAW_DATA_DIR <- "raw_data"

# person 1 and 2 details
P1_NAME <- "Nidhi"
P1_NAME_INITIAL <- "N"
P2_NAME <- "Amit"
P2_NAME_INITIAL <- "A"

P1_TARGET_WEIGHT <- 128
P1_WEIGHT_CAP <- 160
P1_WEIGHT_FLOOR <- 120

P2_TARGET_WEIGHT <- 190
P2_WEIGHT_CAP <- 260
P2_WEIGHT_FLOOR <- 180

P1_DATA_FPATH <- file.path(DATA_DIR, glue("{P1_NAME}.csv"))
P2_DATA_FPATH <- file.path(DATA_DIR, glue("{P2_NAME}.csv"))

P1_TARGET_ACHIEVED_FPATH <- file.path(DATA_DIR, glue("target_achievement_{P1_NAME}.csv"))
P2_TARGET_ACHIEVED_FPATH <- file.path(DATA_DIR, glue("target_achievement_{P2_NAME}.csv"))
P1_FORECAST_FPATH <- file.path(DATA_DIR, glue("forecast_{P1_NAME}.csv"))
P2_FORECAST_FPATH <- file.path(DATA_DIR, glue("forecast_{P2_NAME}.csv"))

CAPTION <- "Source: Daily measurements done @home"
MONTH_ABB <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

# file containing dates and details for important events that could impact this analysis
IMPORTANT_DATES_FNAME <- "important_dates.csv"
IMPORTANT_DATES_MOBILE_FNAME <- "important_dates_mobile.csv"
IMPORTANT_DATES_FPATH <- file.path(DATA_DIR, IMPORTANT_DATES_FNAME)
IMPORTANT_DATES_MOBILE_FPATH <- file.path(DATA_DIR, IMPORTANT_DATES_MOBILE_FNAME)
P2_DEADLIFT_FILE_PATH <- file.path(RAW_DATA_DIR, glue("{P2_NAME}_deadlifts.csv"))

# charting related, how far should be the annoation from a point on the graph
NUDGE_X <- 1
NUDGE_Y <- 5
CHART_ELEMENT_TEXT_SIZE <- 20
CHART_ELEMENT_TEXT_SIZE_MOBILE <- 10

MAIN_PAGE_CHART_TITLE <- "Journey to health"
HOW_EACH_POUND_WAS_LOST_TITLE <- "How each pound was lost..."
N_FOR_LAST_N_POUNDS_OF_INTREST <- 10

# gauge
SUCCESS_RANGE <- c(75, 100)
WARNING_RANGE <- c(40, 74)
DANGER_RANGE <- c(0, 39)

# slider inputs
FORECAST_DURATIONS <- c(60, 90, 180, 365)
SELECTED_FORECAST_DURATION <- 180
FRACTION_FOR_MIN_WEIGHT <- 0.7
WEIGHT_SLIDER_STEP_SIZE <- 1



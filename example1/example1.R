# Example 1 - Urban water use - Non-interactive version

library(tidyverse)

# Read in urban water agency conservation data by month for 2014-2019
waterdata <- read_csv("example1/CA urban water conservation 2019-01.csv",
                      col_types = cols(month = col_date(format = "%m/%d/%Y")))

summary(waterdata)  # get summary statistics on the numeric variables
unique(waterdata$region)  # show all unique regions

# GPCD = gallons per capita (person) per day, a common metric for urban water use efficiency
hist(waterdata$gpcd)  # examine the range of gpcds

# Now let's customize the histogram a bit

selectedregion <- "South Coast"     # select a region
numbins <- 8                           # choose a number of bins for the histogram
waterdata_filter <- waterdata %>%   # subset waterdata by the selected region 
  filter(region == selectedregion)

# Now we'll make a new histogram just for that region

hist(waterdata_filter$gpcd,
     breaks = numbins,
     xlab = "gallons per person per day",
     main = paste0("Urban residential water use for ", selectedregion, ", 2014-2018"))

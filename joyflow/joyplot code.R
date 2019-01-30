# JoyFlow
# This script downloads historical streamflow data from the USGS NWIS website and plots it as a ridgeplot.

library(shiny)          # Interactive web apps
library(tidyverse)      # Data wrangling tools
library(dataRetrieval)  # Functions to read streamflow data from USGS's NWIS API
library(lubridate)      # Tools for working with dates
library(ggjoy)          # Make ridgeplots
library(RColorBrewer)   # Use nice colors for plots
library(shinythemes)    # Change the look and feel of the Shiny app
library(WaterML)

### User inputs:
selectedSite <- "09380000" # ID of the gauge station to download
scaleValue <- 5
colorOption <- "byyear"

# Download raw data via the API
server <- "http://hydroportal.cuahsi.org/nwisdv/cuahsi_1_1.asmx?WSDL"
sitelocation <- GetSiteInfo(server, paste0("NWISDV:", selectedSite))
variable <- "00060" # API code for the Discharge variable, in cfs
COdischarge_raw <- readNWISdv(selectedSite, variable, "1901-01-01", today()) # download discharge data from USGS

# Data wrangling
COdischarge <- COdischarge_raw %>%
  rename(cfs = X_00060_00003, date = Date) %>%
  mutate(year = year(date)) %>%
  filter(cfs >= 0) %>%
  group_by(year) %>%
  mutate(total = sum(cfs), julian = row_number())
numyears = max(COdischarge$year) - min(COdischarge$year)

# Change the palette based on selected year type ("byyear" or "bydischarge")
if (colorOption == "byyear") { myPalette <- colorRampPalette(rev(brewer.pal(numyears, "Spectral")))
 } else { myPalette <- colorRampPalette(brewer.pal(numyears, "RdYlBu")) }
  
# fillvar will control the color of each ridge. 
COdischarge$fillvar <- switch(colorOption, byyear = COdischarge$year, bydischarge = COdischarge$total)

# Make the plot!  
ggplot(COdischarge, aes(julian, -year, height = cfs, fill = fillvar, group = year)) +
  geom_joy(stat="identity", scale = scaleValue * 1.2, size = 0.5) +
  theme_joy() +
  theme(text=element_text(size=20),
        axis.text=element_text(size=18),
        plot.title=element_text(size=21),
        plot.caption=element_text(color="#999999", size=12),
        legend.position = "none") +
  scale_fill_gradientn(colors=myPalette(numyears)) +
  labs(x = "Day of year", y = "Year",
       title = paste("Annual discharge at", sitelocation$SiteName))

# End 
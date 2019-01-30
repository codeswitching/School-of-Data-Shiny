# JoyFlow Shiny app
# Lauren Steely, August 2017

library(shiny)          # Interactive web apps
library(tidyverse)      # Data wrangling tools
library(dataRetrieval)  # Functions to read streamflow data from USGS's NWIS API
library(lubridate)      # Tools for working with dates
library(ggjoy)          # Make ridgeplots
library(RColorBrewer)   # Use nice colors for plots
library(leaflet)        # Add interactive maps
library(shinythemes)    # Change the look and feel of the Shiny app
library(zoo)            # More tools for working with dates
library(WaterML)
library(tools)          # <totitlecase> function

# Define the user interface for the application
ui <- fluidPage(theme=shinytheme("sandstone"),
   
   titlePanel("JoyFlow"), # the title
   helpText("Lauren Steely, ", a("@MadreDeZanjas", href="https://twitter.com/MadreDeZanjas"), " | ",
            a("Code available on Github", href="https://github.com/codeswitching/Streamflow-Joyplot-Tool")),
   
   # A row with two columns for a textbox and a button
   fluidRow(
     column(width=4,
       textInput("sitesInput", "Enter a USGS gauging station site ID:",
                 value = "09380000", width = 300, placeholder = NULL)
     ),
     column(width=2,
       actionButton("button", "Make joyful")
     )
   ),
   tags$style(type='text/css', "#button { width:100%; margin-top: 25px;}"),
   helpText("Examples | Rio Grande: 08319000 | Colorado R: 09380000 | Columbia R: 14105700 | Sacramento R: 11425500 | Klamath R: 11530500"),
   helpText(a("Find gauging stations", href="https://maps.waterdata.usgs.gov/mapper/index.html"), " on a map"),

   hr(),
   
   # A second row containing the slider and radio buttons for the graph options
   fluidRow(
    column(width=4,
     sliderInput("scaleInput", "Add joy:", 0, 11, 4, 1)
    ),
    column(width=3,
     radioButtons("radioInput", "Fill color:", choices =
                    c("by year (pretty)" = "byyear", "by total annual discharge (shows dry vs wet years)" = "bydischarge"))
    )
   ),

   plotOutput("distPlot", height="700px"),

   hr(),
   
   leafletOutput("map"), # A leaflet map
   
   hr()
  )

# Server logic that is triggered when the Make Joyful button is pressed
server <- function(input, output) {
   
  observeEvent(input$button, { # When the UI element labelled 'button' is pressed, run this code
     withProgress(message = "Downloading data from NWIS...", value=0.2, { # Display progress messages
       selectedSite <- input$sitesInput # read the site ID from the input textbox sand save it as selectedSite
       server <- "http://hydroportal.cuahsi.org/nwisdv/cuahsi_1_1.asmx?WSDL"
       sitelocation <- GetSiteInfo(server, paste0("NWISDV:", selectedSite))
       variable <- "00060" # Discharge in cfs
       COdischarge_raw <- readNWISdv(selectedSite, variable, "1901-01-01", today()) # download discharge data from USGS
       setProgress(message="Plotting...", value=0.6)
       
       COdischarge_raw %>%
         rename(cfs = X_00060_00003, date = Date) %>%
         mutate(year = year(date)) %>%
         filter(cfs >= 0) %>%
         group_by(year) %>%
         mutate(total = sum(cfs)) -> COdischarge
       numyears = max(COdischarge$year) - min(COdischarge$year)
     
     output$distPlot <- renderPlot({
       
       # Change the palette based on selecte year type
       if (input$radioInput == "byyear") { myPalette <- colorRampPalette(rev(brewer.pal(numyears, "Spectral"))) }
       else { myPalette <- colorRampPalette(brewer.pal(numyears, "RdYlBu")) }
       
       # Recalculate annual flow and julian days based on selected year type
       COdischarge %>% group_by(year) %>%
         mutate(julian = row_number()) -> COdischarge
       
       # fillvar will control the color of each ridge. 
       COdischarge$fillvar <- switch(input$radioInput, byyear = COdischarge$year, bydischarge = COdischarge$total)
       
       ggplot(COdischarge, aes(julian, -year, height = cfs, fill=fillvar, group=year)) +
         geom_joy(stat="identity", scale = input$scaleInput * 1.2, size = 0.5) +
         theme_joy() +
         theme(text=element_text(family="Arial Narrow", size=20),
               axis.text=element_text(family="Arial Narrow", size=18),
               plot.title=element_text(family="Arial Narrow", size=21),
               plot.caption=element_text(color="#999999", size=12),
               legend.position = "none") +
         scale_fill_gradientn(colors=myPalette(numyears)) +
         labs(x = "Day of lyear", y = "Year",
              title = paste("Annual discharge at", toTitleCase(tolower(sitelocation$SiteName))),
              subtitle = "data from USGS NWIS",
              caption = "https://lsteely.shinyapps.io/streamflow_joyplots/")
     })
     
     output$map <- renderLeaflet({
       leaflet() %>%
         addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
         addMarkers(lat=sitelocation$Latitude, lng=sitelocation$Longitude,
                    label=paste(sitelocation$SiteCode, "-", sitelocation$SiteName)) %>%
         setView(lng = mean(sitelocation$Longitude), lat = mean(sitelocation$Latitude), zoom = 10)
     })
     
     setProgress(message="All done.", value=1)
     })
   })
}

# Run the application 
shinyApp(ui = ui, server = server)
# Example 1 - Urban water use - Non-interactive version

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Urban water conservation report"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        selectInput("region",
                  label = "Choose a region:",
                  choices = list("Colorado River" = "Colorado River", "Central Coast" = "Central Coast",
                                 "North Coast" = "North Coast", "North Lahontan" = "North Lahontan",
                                 "South Lahontan" = "South Lahontan", "South Coast" = "South Coast",
                                 "San Francisco Bay" = "San Francisco Bay",
                                 "San Joaquin River" = "San Joaquin River",
                                 "Sacramento River" = "Sacramento River", "Tulare Lake" = "Tulare Lake")),
         sliderInput("bins",
                     label = "Choose the number of bins:",
                     min = 1,
                     max = 50,
                     value = 30)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("histogramPlot")
      )
   )
)

################################ Define server logic required to draw a histogram

server <- function(input, output) {
  
  library(tidyverse)
  
  # Read in urban water agency conservation data by month for 2014-2019
  waterdata <- read_csv("CA urban water conservation 2019-01.csv",
                        col_types = cols(month = col_date(format = "%m/%d/%Y")))
  
  output$histogramPlot <- renderPlot({
    # create a filtered subset of the data based on the selected input region
    waterdata_filter <- filter(waterdata, region == input$region)
     # Now we'll make a new histogram just for that region
     hist(waterdata_filter$gpcd,
          breaks = input$bins,
          xlab = "gallons per person per day",
          main = paste0("Urban residential water use for ", input$region, ", 2014-2018"))
   })
}

# Run the application 
shinyApp(ui = ui, server = server)


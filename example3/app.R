# Example 3

library(DT) # interactive data tables for web pages
library(tidyverse)

ui <- fluidPage(
  sliderInput("slider1", "Show only cars with horsepower less than:", min=50, max=350, value=300),
  dataTableOutput("table_out")
)

server <- function(input, output) {
  output$table_out <- renderDataTable({
    mtcars_filtered <- mtcars %>% filter(hp < input$slider1)
    datatable(mtcars_filtered)
    })
}

shinyApp(ui = ui, server = server)

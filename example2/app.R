# Example 2

library(shiny)

ui <- fluidPage(
  column(4, # A column for the inputs. 4 specifies the width of the column
         h3("Inputs:"),
         actionButton("button1", "Squirt Ink"),
         br(),
         checkboxGroupInput("checkbox1", "Order",
                            choices = c("Octopuses", "Squidoos", "Cuddlefish", "Nautilus"),
                            selected = "Cuddlefish"),
         sliderInput("slider1", "Number of arms", min = 1, max = 8, value=5),
         selectInput("select1", "Cuttlefish Species", choices = c("Broadclub", "Flamboyant", "Pharoah")),
         dateRangeInput("daterange", "Date range", start="2018-06-01", end = "2019-12-31"),
         radioButtons("radios", "Pupil shape", choices=c('W', '--', 'o'))
  ),
  column(4, # A column for the outputs
         h3("Outputs:"),
         h4("Ink squirts:"),
         textOutput("ink_out"),
         h4("Order"),
         textOutput("order_out"),
         h4("Number of arms:"),
         textOutput("arms_out"),
         h4("Cuttlefish species:"),
         textOutput("species_out")
         )
)

server <- function(input, output) {
  output$ink_out <- renderText(input$button1)
  output$arms_out <- renderText(input$slider1)
  output$species_out <- renderText(input$select1)
  output$order_out <- renderText(input$checkbox1)
}

shinyApp(ui = ui, server = server)

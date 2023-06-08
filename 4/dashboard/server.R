library(shiny)

shinyServer(function(input, output) {
  output$testText <- renderText({ 
    paste("Boredom level ",
          input$testRange[1], " - ", 
          input$testRange[2], "%")
  })
})
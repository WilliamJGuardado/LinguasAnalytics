library(shiny)
library(DBI)
library(RMySQL)
library(ggplot2)
library(dplyr)
library(DT)
library(lubridate)

# Define UI
ui <- fluidPage(
  titlePanel("Linguas Analytics Dashboard"),
  actionButton("connect", "Connect to Database"),
  dateInput("start_date", "Start Date", value = Sys.Date() - 7, format = "yyyy-mm-dd"),
  dateInput("end_date", "End Date", value = Sys.Date(), format = "yyyy-mm-dd"),
  mainPanel(
    tabsetPanel(
      tabPanel("Total Count from Each Language Over Time", plotOutput("plot1")),
      tabPanel("Total Count from Each Country Over Time", plotOutput("plot2")),
      tabPanel("Total Count Over Time", plotOutput("plot3")),
      tabPanel("Country Tally", DT::dataTableOutput("countryTallyTable")),
      tabPanel("Data Tables", DT::dataTableOutput("table"))
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Initialize reactive values
  values <- reactiveValues(con = NULL)
  
  observeEvent(input$connect, {
    showModal(modalDialog(
      title = "Enter Database Credentials",
      textInput("host", "Host", value = "127.0.0.1"),
      textInput("user", "Username", value = "user"),
      passwordInput("password", "Password"),
      footer = tagList(modalButton("Cancel"), actionButton("connect_db", "Connect"))
    ))
  })
  
  observeEvent(input$connect_db, {
    req(input$host, input$user, input$password)
    try({
      values$con <- dbConnect(RMySQL::MySQL(),
                              host = input$host,
                              user = input$user,
                              password = input$password)
      removeModal()
      updateActionButton(session, "connect", label = "Connected")
    }, silent = TRUE)
  })
  
  data <- reactive({
    req(values$con)
    df <- dbGetQuery(values$con, "SELECT Country, Language, CONVERT(TimeDate, CHAR) as TimeDate FROM Cephalopod.Cephalopod")
    df$TimeDate <- as.Date(df$TimeDate, format = "%Y-%m-%d %H:%M:%S")
    df
  })
  
  filtered_data <- reactive({
    req(data(), input$start_date, input$end_date)
    data() %>% 
      filter(TimeDate >= as.Date(input$start_date) & TimeDate <= as.Date(input$end_date))
  })
  
  # Plots and tables
  output$plot1 <- renderPlot({
    req(filtered_data())
    count_data <- filtered_data() %>%
      group_by(TimeDate, Language) %>%
      summarise(Total_Count = n(), .groups = "drop")
    ggplot(count_data, aes(x = TimeDate, y = Total_Count, fill = Language)) +
      geom_col(position = "dodge") +
      labs(title = "Total Count from Each Language Over Time", x = "Time", y = "Total Count") +
      theme_minimal() +
      coord_flip() +
      theme(legend.position = "bottom")
  })
  
  # Plotting total count by country over time
  output$plot2 <- renderPlot({
    req(filtered_data())
    count_data <- filtered_data() %>%
      group_by(TimeDate, Country) %>%
      summarise(Total_Count = n(), .groups = "drop")
    ggplot(count_data, aes(x = reorder(Country, Total_Count), y = Total_Count, fill = Country)) +
      geom_col() +
      labs(title = "Total Count from Each Country Over Time", x = "Country", y = "Total Count") +
      theme_minimal() +
      coord_flip() +
      theme(legend.position = "none")
  })
  
  # Plotting total count over time
  output$plot3 <- renderPlot({
    req(filtered_data())
    total_by_date <- filtered_data() %>%
      group_by(TimeDate) %>%
      summarise(Total_Count = n(), .groups = "drop")
    ggplot(total_by_date, aes(x = TimeDate, y = Total_Count)) +
      geom_col(fill = "steelblue") +
      geom_text(aes(label = Total_Count), vjust = -0.5, color = "black") +
      labs(title = "Total Count Over Time", x = "Date", y = "Total Count") +
      theme_minimal()
  })
  
  # Country tally table
  output$countryTallyTable <- DT::renderDataTable({
    req(filtered_data())
    tally_data <- filtered_data() %>%
      group_by(Country) %>%
      summarise(Total_Count = n(), .groups = 'drop') %>%
      arrange(desc(Total_Count))
    tally_data
  })
  
  # Data table for further details
  output$table <- DT::renderDataTable({
    req(filtered_data())
    DT::datatable(filtered_data(), options = list(pageLength = 20, autoWidth = TRUE))
  })
}

# Run the application
shinyApp(ui = ui, server = server)

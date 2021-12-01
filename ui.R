## ui.R
library(shiny)
library(shinydashboard)
library(recommenderlab)
library(data.table)
library(ShinyRatingInput)
library(shinyjs)

source('functions/helpers.R')

sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("Rating Recommender", tabName = "rating_rec", icon = icon("th")),
    menuItem("Genre Recommender", tabName = "genre_rec", icon = icon("th"))
  )
)

rating_rec = tabItem(
  tabName = "rating_rec",
  includeCSS("css/movies.css"),
  
  fluidRow(
    box(width = 12, title = "Step 1: Rate as many Movies as possible", status = "info", solidHeader = TRUE, collapsible = TRUE,
        div(class = "rateitems", uiOutput('ratings'))
    )
  ),
  
  fluidRow(
    useShinyjs(),
    box(
      width = 12, status = "info", solidHeader = TRUE,
      title = "Step 2: Discover Movies you might like",
      br(),
      withBusyIndicatorUI(actionButton("btn", "Click here to get your recommendations", class = "btn-warning")),
      br(),
      tableOutput("results")
    )
  )
)

genre_rec = tabItem(
  tabName="genre_rec",
  fluidPage(
    selectInput("genre_select", h3("Select Genre"),
                choices = list(
                  "Action" = "Action", 
                  "Adventure", 
                  "Animation" , 
                  "Children's", 
                  "Comedy", 
                  "Crime",
                  "Documentary", 
                  "Drama", 
                  "Fantasy",
                  "Film-Noir", 
                  "Horror", 
                  "Musical", 
                  "Mystery", 
                  "Romance", 
                  "Sci-Fi", 
                  "Thriller", 
                  "War", 
                  "Western"
                )
    ), #selectInput
    mainPanel(
      tableOutput("genre_results")
    )
  ) #fluidPage
)

body = dashboardBody(
  tabItems(
    rating_rec,
    genre_rec
  )
)

shinyUI(
  dashboardPage(
    skin = "blue",
    dashboardHeader(title = "Movie Recommender"),
    sidebar,
    body
  )
) 
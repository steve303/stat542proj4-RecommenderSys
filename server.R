## server.R

library(dplyr)

# load functions
source('functions/cf_algorithm.R') # collaborative filtering
source('functions/similarity_measures.R') # similarity measures

# define functions
get_user_ratings = function(value_list) {
  dat = data.table(MovieID = sapply(strsplit(names(value_list), "_"), 
                                    function(x) ifelse(length(x) > 1, x[[2]], NA)),
                   Rating = unlist(as.character(value_list)))
  dat = dat[!is.null(Rating) & !is.na(MovieID)]
  dat[Rating == " ", Rating := 0]
  dat[, ':=' (MovieID = as.numeric(MovieID), Rating = as.numeric(Rating))]
  dat = dat[Rating > 0]
}

# read in data
myurl = "https://liangfgithub.github.io/MovieData/"
movies = readLines(paste0(myurl, 'movies.dat?raw=true'))
movies = strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
movies = matrix(unlist(movies), ncol = 3, byrow = TRUE)
movies = data.frame(movies, stringsAsFactors = FALSE)
colnames(movies) = c('MovieID', 'Title', 'Genres')
movies$MovieID = as.integer(movies$MovieID)
movies$Title = iconv(movies$Title, "latin1", "UTF-8")

bayes_WR = readLines("https://raw.githubusercontent.com/pwodarz/CS598Proj4/main/WR_movies.dat")
bayes_WR = strsplit(bayes_WR, split = "::", fixed = TRUE, useBytes = TRUE)
bayes_WR = matrix(unlist(bayes_WR), ncol = 6, byrow = TRUE)
bayes_WR = data.frame(bayes_WR, stringsAsFactors = FALSE)
colnames(bayes_WR) = c("MovieID","Title","Genres","mean_rating","num_reviews","WR")
bayes_WR$MovieID = as.integer(bayes_WR$MovieID)
bayes_WR$WR = as.numeric(bayes_WR$WR)


small_image_url = "https://liangfgithub.github.io/MovieImages/"
movies$image_url = sapply(movies$MovieID, 
                          function(x) paste0(small_image_url, x, '.jpg?raw=true'))

shinyServer(function(input, output, session) {
  
  # show the movies to be rated
  output$ratings <- renderUI({
    num_rows <- 20
    num_movies <- 6 # movies per row
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        list(box(width = 2,
                 div(style = "text-align:center", img(src = movies$image_url[(i - 1) * num_movies + j], height = 150)),
                 #div(style = "text-align:center; color: #999999; font-size: 80%", books$authors[(i - 1) * num_books + j]),
                 div(style = "text-align:center", strong(movies$Title[(i - 1) * num_movies + j])),
                 div(style = "text-align:center; font-size: 150%; color: #f0ad4e;", ratingInput(paste0("select_", movies$MovieID[(i - 1) * num_movies + j]), label = "", dataStop = 5)))) #00c0ef
      })))
    })
  })
  
  # Calculate recommendations when the sbumbutton is clicked
  df <- eventReactive(input$btn, {
    withBusyIndicatorServer("btn", { # showing the busy indicator
      # hide the rating container
      useShinyjs()
      jsCode <- "document.querySelector('[data-widget=collapse]').click();"
      runjs(jsCode)
      
      # get the user's rating data
      value_list <- reactiveValuesToList(input)
      user_ratings <- get_user_ratings(value_list)
      
      user_results = (1:10)/10
      user_predicted_ids = 1:10
      recom_results <- data.table(Rank = 1:10, 
                                  MovieID = user_predicted_ids, 
                                  Predicted_rating =  user_results)
      
    }) # still busy
    
  }) # clicked on button
  
  
  # display the recommendations
  output$results <- renderUI({
    num_rows <- 2
    num_movies <- 5
    recom_result <- df()
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        box(width = 2, status = "success", solidHeader = TRUE, title = paste0("Rank ", (i - 1) * num_movies + j),
            
            div(style = "text-align:center", 
                a(img(src = movies[movies$MovieID == recom_result$MovieID[(i - 1) * num_movies + j],]$image_url[1], height = 150))
            ),
            div(style="text-align:center; font-size: 100%", 
                strong(movies[movies$MovieID == recom_result$MovieID[(i - 1) * num_movies + j],]$Title[1])
            )
            
        )        
      }))) # columns
    }) # rows
    
  }) # renderUI function
  
  # Display the genre recommendation
  output$genre_results = renderUI({
    n = 10
    top_movies = bayes_WR %>% filter(grepl(input$genre_select,Genres)) %>% arrange(desc(WR))
    user_results = top_movies[1:n,]$mean_rating
    user_predicted_ids = top_movies[1:n,]$MovieID
    recom_result <- data.table(Rank = 1:10, 
                                MovieID = user_predicted_ids, 
                                Predicted_rating =  user_results)
    
    num_rows <- 2
    num_movies <- 5
    
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        box(width = 2, status = "success", solidHeader = TRUE, title = paste0("Rank ", (i - 1) * num_movies + j),
            
            div(style = "text-align:center", 
                a(img(src = movies[movies$MovieID == recom_result$MovieID[(i - 1) * num_movies + j],]$image_url[1], height = 150))
            ),
            div(style="text-align:center; font-size: 100%", 
                strong(movies[movies$MovieID == recom_result$MovieID[(i - 1) * num_movies + j],]$Title[1])
            )
            
        )        
      }))) # columns
    })
  }) # renderUI function
  
}) # server function

## server.R
#code source:  https://github.com/pspachtholz/BookRecommender/blob/master/server.R 
library(dplyr)

# load functions
source('functions/cf_algorithm.R') # collaborative filtering
source('functions/similarity_measures.R') # similarity measures
source('functions/system2.R') #prepare input data "ratingmat" for sys2
# define functions
get_user_ratings = function(value_list) {
  
  value_list <<- value_list #what data structure is this?
  dat = data.table(MovieID = sapply(strsplit(names(value_list), "_"), 
                                    function(x) ifelse(length(x) > 1, x[[2]], NA)),
                   Rating = unlist(as.character(value_list)))
  dat = dat[!is.null(Rating) & !is.na(MovieID)]
  dat[Rating == " ", Rating := 0]
  dat[, ':=' (MovieID = as.numeric(MovieID), Rating = as.numeric(Rating))]  
  dat = dat[Rating > 0]
  
  # get the indices of the ratings
  # add the user ratings to the existing rating matrix
  
  
  user_ratings = sparseMatrix(i = dat$MovieID, 
                               j = rep(1,nrow(dat)),  #what does the 1 do here? refers to column 1
                               x = dat$Rating, 
                               dims = c(nrow(ratingmat), 1))  #build a nx1 matrix where n is num of rows in 
                                                              #ratingmat which is a global var, see system2.R
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
      # add user's ratings as first column to rating matrix
      rmat <- cbind(user_ratings, ratingmat)  
      
      # get the indices of which cells in the matrix should be predicted
      # here I chose to predict all books the current user has not yet rated
      
      items_to_predict <- which(rmat[, 1] == 0)  #find all movies user did not rate; user is located in column 1
      prediction_indices <- as.matrix(expand.grid(items_to_predict, 1))  
      
      # run the cf-alogrithm
      res <- predict_cf(rmat, prediction_indices, "ubcf", TRUE, cal_cos, 25, FALSE, 2000, 1000)
      
      # sort, organize, and return the results
      user_results <- sort(res[, 1], decreasing = TRUE)[1:10]  #these are the ratings sorted top N
      user_predicted_ids <- as.numeric(names(user_results))  
      recom_results <- data.table(Rank = 1:10,
                                  MovieID = user_predicted_ids,
                                  #MovieID = c(230,231,232,233,234,2000,2001,2002,2003,2004), #testing
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

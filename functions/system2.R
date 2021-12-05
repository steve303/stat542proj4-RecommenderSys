library(recommenderlab)
library(Matrix)

#get rating.dat file locally:
ratings0 = read.csv("./data/ratings.dat", 
                   sep = ':',
                   colClasses = c('integer', 'NULL'), 
                   header = FALSE)
colnames(ratings0) = c('UserID', 'MovieID', 'Rating', 'Timestamp')
ratings0$Timestamp = NULL

 i = ratings0$MovieID
 j = ratings0$UserID
 x = ratings0$Rating
 
 #note: users line up sequentially but movies do not!
 num_movies = length(unique(i)) #should be 3706
 num_users = length(unique(j))  #should be 6040
 max_movie_id = max(i)          # maxid = 3952
 max_user_id = max(j)           # maxid = 6040
 

ratingmat = sparseMatrix(i = as.integer(i), j = as.integer(j), x = x)
ratingmat = ratingmat[, unique(summary(ratingmat)$j)] # remove possible unused columns (users); turns out there are none
dimnames(ratingmat) <- list(MovieID = as.character(1:nrow(ratingmat)), UserID = as.character(sort(unique(j))))


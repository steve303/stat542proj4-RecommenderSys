# Building a Movie Recommender App - Algorithm Selection and App Implementation using R's Shiny Platform

# Objectives
1) Evaluate and select a machine learning algorithm best suited for a toy movie recommender system
2) Fully implement the algorithm into a functional web based app using publically available platforms

[technical report and references](https://steve303.github.io/stat542proj4/Project4_S21_Report.html)  
[movie recommender app](https://steve303.shinyapps.io/RecommenderApp/)

# Data Source  
**MovieLens 1M Dataset**
- The dataset contains about 1 million anonymous ratings of approximately 3,900 movies made by 6,040 MovieLens users who joined MovieLens in 2000.
- Check some explanatory data analysis we have done:
\[[Rcode_W13_Movie_EDA](https://liangfgithub.github.io/Rcode_W13_Movie_EDA.nb.html)\] \[[Rcode_W13_Movie_RS](https://liangfgithub.github.io/Rcode_W13_Movie_RS.nb.html)\]

- **System I**: recommendation based on genres. Suppose you know the user's favorite genre. How would you recommend movies to him/her?
  &nbsp;
  Propose **two** recommendation schemes along with all necessary technical details.
   &nbsp;
   For example, you can recommend the top-five most popular movies in that genre, then you have to define what you mean by "most popular". Or recommend the top-five highly-rated movies in that genre; again need to define what you mean by highly-rated. (Will the movie that receives only one 5-point review be considered highly-rated?) Or recommend the most trendy movies in that genre; define how you measure trendiness.

- **System II**: collaborative recommendation system. Review and evaluate at least two collaborative recommendation algorithms, for example, user-based, item-based, or SVD.
  &nbsp;
  Provide a short introduction of those algorithms, then pick a metric, e.g., RMSE, to evaluate the prediction performance of the algorithms, over 10 iterations. In each iteration, create a training and test split of the MovieLens 1M data, train a recommender system on the training data and record prediction accuracy/error on the test data. Report the results via a graph or a table.
  - There is no accuracy benchmark; the purpose here is to demonstrate that you know how to build a collaborative recommender system.
  - You can decide the percentage for training/test data.
  - It'll be great if you want to tune the model parameters, but it's fine to just fix them at some values. Include a description of the meaning of each parameter and the value you have used throughout the simulation study.
  
  &nbsp;
  Include the necessary technical details. For example, suppose you study the user-based or item-based CF.
  - Will you normalize the rating matrix? If so, which normalization option do you use?   
  - What's the nearest neighborhood size you use?
  - Which similarity metric do you use?
  - If you say prediction is based on a "weighted average", then explain what weights you use.
  - Will you still have missing values after running the algorithm? If so, how do you handle those missing values?

  &nbsp;
If you use an SVD-based approach, you cannot simply say that the method is based on the ordinary matrix SVD since the ordinary SVD is not applicable to a matrix with missing values. Instead, provide the objective function the algorithm aims to optimize. If the objective function has some tuning parameters, specify the values you use, e.g., what's the dimension of the latent features.

**A Movie Recommendation App (5pt)**

Build a shiny app (or any other app) with at least one algorithm from **System I** and one algorithm from **System II**.

For the algorithm from **System I**, your app needs to take the input from a user on his/her favorite genre. For the algorithm from **System II**, your app needs to provide some sample movies and ask the user to rate.

The two systems do not have to share any interface; please allow users to select which system to use.
![UI_image%20%281%29.png](https://campuspro-uploads.s3.us-west-2.amazonaws.com/497eef81-a2cf-4d1c-923e-22a7e4dcb092/368df833-ba22-414f-8fd1-a3e796342fc9/UI_image%20%281%29.png)

We will test your app. 3pt, if it works; 2pt for design. For example, an app like \[[**this**](https://philippsp.shinyapps.io/BookRecommendation/)\] will receive 5pt.

**Resources**
You can use others' code, as long as you cite the source.
- Github for the nice Book Recommender System mentioned above
\[[https://github.com/pspachtholz/BookRecommender](https://github.com/pspachtholz/BookRecommender)\]
where you can also find his Kaggle report.
- Comparing State-of-the-Art Collaborative Filtering Systems \[[Link](https://liangfgithub.github.io/ref/Comparing_State-of-the-Art_Collaborative_Filtering_Systems.pdf)\]
- Search "recommender system" on Kaggle, and of course, Google.

**Packages**
You can use any packages. For Python users, check out \[[Dash](https://dash.plotly.com/)\] \[[Flask](https://opensource.com/article/18/4/flask)\]


resources:  
data source:  https://grouplens.org/datasets/movielens/  
prof's code:  https://liangfgithub.github.io/Rcode_W13_Movie_EDA.nb.html  
prof's code:  https://liangfgithub.github.io/Rcode_W13_Movie_RS.nb.html  
demo code:  https://github.com/pspachtholz/BookRecommender  
demo code:  https://www.kaggle.com/philippsp/book-recommender-collaborative-filtering-shiny  

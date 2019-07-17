# Get Old Tweets Programmatically
A project written in R to get old tweets, it bypass some limitations of Twitter Official API.

## Details
Twitter Official API has the bother limitation of time constraints, you can't get older tweets than a week. Some tools provide access to older tweets but in the most of them you have to spend some money before.
I was searching other tools to do this job, I found "https://github.com/Jefferson-Henrique/GetOldTweets-python",
but this application has some limitations. Data cannot be fetched at all times. It is also difficult to discern information such as geolocation, retweet count, quotation. There are also problems in some languages (such as Turkish).

In the face of these challenges, I found a way to bring twitter data from the past by combining Json API knowledge and twitter api call with inspiration from this application.

## Prerequisites
```R
library(rtweet)
library(rvest)
library(jsonlite)
```

Also you may need to create an app from Twitter developer to take "consumer_key, consumer_secret, access_token, access_secret".
```R
create_token(
  app = "dummy",
  consumer_key = "xxxxxxxxxxxxx",
  consumer_secret = "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyy",
  access_token = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
  access_secret = "kkkkkkkkkkkkkkkkkkkkkkkkkkkk")
```  

## Input parameters
```R
startdate =  "2014-01-01" # A lower bound date to restrict search.
enddate = "2015-01-01"    # An upper bound date to restrist search.
language = "en"           # Tweets in a specific language to restrist search.
ntweets = 1000            # The maximum number of tweets to be retrieved
searchTerm <- "donald trump"
``` 

## Examples of R usage
```R
library(rtweet)
library(rvest)
library(jsonlite)

create_token(
  app = "dummy",
  consumer_key = "xxxxxxxxxxxxx",
  consumer_secret = "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyy",
  access_token = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz",
  access_secret = "kkkkkkkkkkkkkkkkkkkkkkkkkkkk")

# Input parameters
startdate =  "2014-01-01"
enddate = "2015-01-01"
language = "en"
ntweets = 1000
searchTerm <- "donald trump"
searchbox <- URLencode(searchTerm)
# convert to url
temp_url <- paste0("https://twitter.com/i/search/timeline?f=tweets&q=",searchbox,"%20since%3A",startdate,"%20until%3A",enddate,"&l=",language,"&src=typd&max_position=")
webpage <- fromJSON(temp_url)
if(webpage$new_latent_count>0){
  tweet_ids <- read_html(webpage$items_html) %>% html_nodes('.js-stream-tweet') %>% html_attr('data-tweet-id')
  breakFlag <- F
  while (webpage$has_more_items == T) {
    tryCatch({
      min_position <- webpage$min_position
      next_url <- paste0(temp_url, min_position)
      webpage <- fromJSON(next_url)
      next_tweet_ids <- read_html(webpage$items_html) %>% html_nodes('.js-stream-tweet') %>% html_attr('data-tweet-id')
      next_tweet_ids <- next_tweet_ids[!is.na(next_tweet_ids)]
      tweet_ids <- unique(c(tweet_ids,next_tweet_ids))
      if(length(tweet_ids) >= ntweets)
      {
        breakFlag <- T
      }
    },
    error=function(cond) {
      message(paste("URL does not seem to exist:", next_url))
      message("Here's the original error message:")
      message(cond)
      breakFlag <<- T
    })
    
    if(breakFlag == T){
      break
    }
  }
  tweets <- lookup_tweets(tweet_ids, parse = TRUE, token = NULL)
  df <- apply(tweets,2,as.character)
  write.csv(df, file = "tweets.csv", row.names = F)
} else {
  paste0("There is no tweet about this search term!")
}
``` 

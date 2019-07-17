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
ntweets = 100
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

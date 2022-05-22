# Note that we can do like below in interactive sessions, but, even when we cache
# the token on disk by cache_disk = TRUE, it seems it's not portable.
#
# request("https://api.twitter.com/2/tweets/search/recent") |>
#   req_oauth_auth_code(client,
#     cache_disk = TRUE,
#     auth_url = "https://twitter.com/i/oauth2/authorize",
#     scope = "tweet.read tweet.write users.read offline.access",
#     host_name = "127.0.0.1",
#     port = 1410
#   ) %>%
#   req_url_query(query = "#rstatsj -is:retweet") |>
#   req_perform() |>
#   resp_body_json()


library(httr2)

RSTATS_JA_BOT_ENVVAR <- "RSTATS_JA_BOT_KEY"

key <- Sys.getenv(RSTATS_JA_BOT_ENVVAR)
if (identical(key, "")) {
  rlang::abort("Please set RSTATS_JA_BOT_KEY envvar first!")
}


# Refresh token first -----------------------------------------------------

client_id     <- secret_decrypt("xomYuuOeMNUN4auHRAgSirk8ebGvCHtdh5KHo4pTGDKa-xPcqNRMbF_7-YnFeFfSx3s", RSTATS_JA_BOT_ENVVAR)
client_secret <- secret_decrypt("B4tmzbLwH0ndjuZUU5L9LkwsHQMlMA084IQJ9b5Q7vh2N8YwdRUoLz_L5hdp90qYArac9hXummdVm67OYgPQgopd", RSTATS_JA_BOT_ENVVAR)

refresh_token <- secret_read_rds(here::here("secrets", "refresh_token.rds"), RSTATS_JA_BOT_ENVVAR)


req <- request("https://api.twitter.com/2/oauth2/token") |>
  req_body_form(
    grant_type = "refresh_token",
    refresh_token = refresh_token
  ) |>
  req_auth_basic(client_id, client_secret)

resp <- req |>
  req_perform() |>
  resp_body_json()

refresh_token <- resp$refresh_token
access_token  <- resp$access_token

secret_write_rds(refresh_token, here::here("secrets", "refresh_token.rds"), RSTATS_JA_BOT_ENVVAR)


# Get #rstatsj tweets -----------------------------------------------------

# c.f. https://developer.twitter.com/en/docs/twitter-api/tweets/search/api-reference/get-tweets-search-recent
# exclude some bots:
# - @rstatsvideo
get_rstatsj_tweets <- function() {
  req <- request("https://api.twitter.com/2/tweets/search/recent") |>
    req_auth_bearer_token(access_token) |>
    req_url_query(query = "(#rstatsj OR (#rstats lang:ja)) -is:retweet -from:rstatsvideo")

  resp <- req |>
    req_perform() |>
    resp_body_json()

  resp$data |>
    purrr::map_chr("id")
}

tweet_ids <- get_rstatsj_tweets()


# Retweets ----------------------------------------------------------------

# c.f. https://developer.twitter.com/en/docs/twitter-api/tweets/retweets/api-reference/post-users-id-retweets
# c.f. https://developer.twitter.com/en/docs/twitter-api/tweets/retweets/migrate/manage-retweets-standard-to-twitter-api-v2

do_rt <- function(tweet_id) {
  req <- request("https://api.twitter.com/2/users/1512635212634923010/retweets") |>
    req_auth_bearer_token(access_token) |>
    req_method("POST") |>
    req_body_json(data = list(tweet_id = tweet_id))

  resp <- req |>
    req_perform()

  print(resp)
  Sys.sleep(60)
}

purrr::walk(tweet_ids, do_rt)

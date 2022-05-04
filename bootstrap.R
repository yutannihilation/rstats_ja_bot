library(httr2)

RSTATS_JA_BOT_ENVVAR <- "RSTATS_JA_BOT_KEY"

key <- Sys.getenv(RSTATS_JA_BOT_ENVVAR)
if (identical(key, "")) {
  rlang::abort("Please set RSTATS_JA_BOT_KEY envvar first!")
}

client_id     <- secret_decrypt("xomYuuOeMNUN4auHRAgSirk8ebGvCHtdh5KHo4pTGDKa-xPcqNRMbF_7-YnFeFfSx3s", RSTATS_JA_BOT_ENVVAR)
client_secret <- secret_decrypt("B4tmzbLwH0ndjuZUU5L9LkwsHQMlMA084IQJ9b5Q7vh2N8YwdRUoLz_L5hdp90qYArac9hXummdVm67OYgPQgopd", RSTATS_JA_BOT_ENVVAR)

client <- oauth_client(
  id = client_id,
  secret = client_secret,
  token_url = "https://api.twitter.com/2/oauth2/token",
  name = "rstats_ja_bot_test",
  auth = "header"
)

token <- oauth_flow_auth_code(client,
  auth_url = "https://twitter.com/i/oauth2/authorize",
  scope = "tweet.read tweet.write users.read offline.access",
  # Note: The redirect URL setting on the Twitter app must be "http://127.0.0.1:1410/"
  #       (the trailing / must be included).
  host_name = "127.0.0.1",
  port = 1410
)

untrace("req_perform")

dir.create(here::here("secrets"), showWarnings = FALSE)
secret_write_rds(token$refresh_token, here::here("secrets", "refresh_token.rds"), RSTATS_JA_BOT_ENVVAR)

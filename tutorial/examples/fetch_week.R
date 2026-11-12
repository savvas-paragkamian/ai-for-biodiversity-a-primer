# One source, one topic, one week: fetch, keep what came back, then count.
library(httr2); library(jsonlite)
week  <- "2026-W45"                        # ISO week: 2 to 8 November 2026
query <- paste("TITLE_ABS:(Collembola OR springtail*)",
               "AND FIRST_PDATE:[2026-11-02 TO 2026-11-08]")
epmc  <- "https://www.ebi.ac.uk/europepmc/webservices/rest/search"
resp  <- request(epmc) |>
  req_url_query(query = query, format = "json", resultType = "core",
                pageSize = 100) |>
  req_user_agent("weekly-literature-tutorial") |>  # add a contact address
  req_retry(max_tries = 4) |>
  req_perform()
raw <- file.path("data/raw", week, "europepmc__collembola__1.json")
dir.create(dirname(raw), recursive = TRUE, showWarnings = FALSE)
writeLines(resp_body_string(resp), raw)    # kept as received, unparsed
found <- fromJSON(raw, simplifyVector = FALSE)
cat(length(found$resultList$result), "items in the file;",
    found$hitCount, "reported by the service\n")

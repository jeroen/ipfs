#' IPFS
#'
#' Connect to the inter-planetary file system.
#'
#' @export
#' @name ipfs
#' @rdname ipfs
#' @param key a multihash key
#' @examples # From 'getting started'
#' ipfs_version()
#' ipfs_get('QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG')
ipfs_get <- function(key){
  ipfs_json("object/get", arg = key)
}

#' @export
#' @rdname ipfs
ipfs_version <- function(){
  ipfs_json("version")
}

ipfs_raw <- function(command, ...){
  params <- list(...)
  ipfs_fetch(command, params)
}

ipfs_json <- function(command, ...){
  params <- list(...)
  params$enc <- "json"
  data <- ipfs_fetch(command, params)
  jsonlite::fromJSON(rawToChar(data))
}

ipfs_fetch <- function(command, params){
  url <- paste0("http://127.0.0.1:5001/api/v0/", command)
  if(length(params)){
    str <- paste(names(params), as.character(params), collapse = "&", sep = "=")
    url <- paste(url, str, sep = "?")
  }
  req <- curl::curl_fetch_memory(url)
  if(req$status_code >= 400)
    stop(sprintf("HTTP %s", rawToChar(req$content)), call. = FALSE)
  req$content
}

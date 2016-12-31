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

#' @export
#' @rdname ipfs
ipfs_webui <- function(){
  ipfs_version() #check that demon is online
  utils::browseURL(ipfs_url("webui"))
}

ipfs_raw <- function(command, ...){
  params <- list(...)
  ipfs_fetch(command, params)
}

ipfs_json <- function(command, ...){
  data <- ipfs_raw(command, enc = "json", ...)
  jsonlite::fromJSON(rawToChar(data))
}

ipfs_fetch <- function(command, params){
  url <- ipfs_url("api/v0", command)
  if(length(params)){
    str <- paste(names(params), as.character(params), collapse = "&", sep = "=")
    url <- paste(url, str, sep = "?")
  }
  req <- curl::curl_fetch_memory(url)
  if(req$status_code >= 400)
    stop(sprintf("HTTP %s", rawToChar(req$content)), call. = FALSE)
  req$content
}

ipfs_url <- function(...){
  paste("http://127.0.0.1:5001", ..., sep = "/")
}

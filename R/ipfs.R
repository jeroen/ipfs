#' IPFS
#'
#' Connect to the inter-planetary file system.
#'
#' @export
#' @name ipfs
#' @rdname ipfs
#' @param key a multihash key
#' @examples # From 'getting started'
#' @references \url{https://ipfs.io/ipfs/QmR7GSQM93Cx5eAg6a6yRzNde1FQv7uL6X1o4k7zrJa3LX/ipfs.draft3.pdf}
#' ipfs_version()
#' ipfs_get('QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG')
#' ipfs_data('QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme')
ipfs_get <- function(key){
  ipfs_json("object/get", arg = key)
}

#' @export
#' @rdname ipfs
ipfs_data <- function(key){
  ipfs_raw("object/data", arg = key)
}

#' @export
#' @rdname ipfs
#' @param path filename to save download.
#' @examples ipfs_download('QmR7GSQM93Cx5eAg6a6yRzNde1FQv7uL6X1o4k7zrJa3LX/ipfs.draft3.pdf')
#' utils::browseURL('ipfs.draft3.pdf')
ipfs_download <- function(key, path = NULL){
  if(!length(path))
    path <- basename(key)
  buf <- ipfs_data(key)
  writeBin(buf, path)
  return(path)
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

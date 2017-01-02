#' IPFS
#'
#' Connect to the inter-planetary file system.
#'
#' @export
#' @name ipfs
#' @rdname ipfs
#' @param key a multihash key
#' @references IPFS api: \url{https://ipfs.io/docs/api/}
#' Draft paper: \url{https://ipfs.io/ipfs/QmR7GSQM93Cx5eAg6a6yRzNde1FQv7uL6X1o4k7zrJa3LX/ipfs.draft3.pdf}
#' @examples # From 'getting started'
#' ipfs_info()
#' ipfs_get('QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG')
#' ipfs_data('QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme')
#'
ipfs_get <- function(key){
  ipfs_json("object/get", arg = key)
}

#' @export
#' @rdname ipfs
ipfs_ls <- function(key){
  ipfs_json("ls", arg = key)
}

#' @export
#' @rdname ipfs
ipfs_data <- function(key){
  buf <- ipfs_raw("object/data", arg = key)
  if(identical(buf, as.raw(c(0x08, 0x01))))
    stop("Not a data block")
  return(buf)
}

#' @export
#' @rdname ipfs
ipfs_swarm <- function(){
  list(
    local = ipfs_json("swarm/addrs/local")$Strings,
    peers = ipfs_json("swarm/peers")$Strings
  )
}

#' @export
#' @rdname ipfs
ipfs_stats <- function(){
  list(
    bitswap = ipfs_json("stats/bitswap"),
    repo = ipfs_json("stats/repo"),
    bw = ipfs_json("stats/bw")
  )
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
ipfs_info <- function(){
  list(
    version = ipfs_json("version"),
    id = ipfs_json("id")
  )
}

#' @export
#' @rdname ipfs
ipfs_webui <- function(){
  ipfs_info() #check that demon is online
  utils::browseURL(ipfs_url("webui"))
}

#' @export
#' @rdname ipfs
ipfs_commands <- function(){
  print_tree <- function(x, indent){
    opts <- unlist(sapply(x$Options, function(y){y$Names[[1]]}))
    optstr <- ifelse(length(opts), paste("[", paste0("--", opts, collapse = ", "), "]"), " ")
    cat(sprintf("%s- %s %s\n", strrep(' ', indent), x$Name, optstr))
    lapply(x$Subcommands, print_tree, indent = indent + 2)
  }
  buf <- ipfs_raw("commands", enc = "json")
  data <- jsonlite::fromJSON(rawToChar(buf), simplifyVector = FALSE)
  invisible(lapply(data[[2]], print_tree, indent = 2))
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

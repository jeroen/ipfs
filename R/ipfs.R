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
#' ipfs_daemon(TRUE)
#' ipfs_info()
#' ipfs_get('QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG')
#' ipfs_data('QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme')
ipfs_get <- function(key){
  ipfs_json("object/get", arg = key)
}

#' @export
#' @rdname ipfs
#' @param files path(s) of files to add
ipfs_add <- function(files){
  post <- lapply(files, function(x){
    curl::form_file(normalizePath(x, mustWork = TRUE))
  })
  names(post) <- basename(files)
  data <- ipfs_raw("add", post = post)
  con <- rawConnection(data)
  on.exit(close(con))
  df <- jsonlite::stream_in(con, verbose = FALSE)
  names(df) <- tolower(names(df))
  df
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
ipfs_cat <- function(key){
  buf <- ipfs_data(key)
  cat(rawToChar(buf))
  invisible(buf)
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
#' # utils::browseURL('ipfs.draft3.pdf')
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
  version <- ipfs_json("version")
  id <- ipfs_json("id")
  c(id, version)
}

#' @export
#' @rdname ipfs
ipfs_config <- function(){
  ipfs_json("config/show")
}

#' @export
#' @rdname ipfs
#' @param gateway any IPFS gateway server
ipfs_browse <- function(key, gateway = "https://ipfs.io/ipfs/"){
  url <- paste0(gateway, key)
  utils::browseURL(url)
  return(url)
}

#' @export
#' @rdname ipfs
ipfs_webui <- function(){
  ipfs_info() #check that demon is online
  utils::browseURL(ipfs_api("webui"))
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

ipfs_raw <- function(command, ..., post = NULL){
  params <- list(...)
  ipfs_fetch(command, params, post)
}

ipfs_json <- function(command, ...){
  data <- ipfs_raw(command, enc = "json", ...)
  jsonlite::fromJSON(rawToChar(data))
}

ipfs_fetch <- function(command, params, post = NULL){
  url <- ipfs_api("api/v0", command)
  h <- curl::new_handle()
  if(length(params)){
    str <- paste(names(params), as.character(params), collapse = "&", sep = "=")
    url <- paste(url, str, sep = "?")
  }
  if(length(post)){
    curl::handle_setform(h, .list = as.list(post))
  }
  req <- curl::curl_fetch_memory(url, handle = h)
  if(req$status_code >= 400)
    stop(sprintf("HTTP %s", rawToChar(req$content)), call. = FALSE)
  req$content
}


#' @export
#' @rdname ipfs
#' @param new_url set a different API server. Default is "http://127.0.0.1:5001"
ipfs_server <- local({
  provider_url <- "http://127.0.0.1:5001"
  function(new_url = NULL){
    if(length(new_url)){
      new_url <- sub("/$", "", new_url)
      req <- curl::curl_fetch_memory(paste0(new_url, "/api/v0/version"))
      if(req$status_code != 200)
        stop(sprintf("Failed to connect (HTTP %d)", req$status_code), call. = FALSE)
      provider_url <<- new_url
    }
    return(provider_url)
  }
})

ipfs_api <- function(...){
  paste(ipfs_server(), ..., sep = "/")
}

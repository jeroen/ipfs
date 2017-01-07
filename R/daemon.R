daemon <- local({
  pid <- NULL
  ipfs_start <- function(restart = FALSE){
    if(isTRUE(restart))
      ipfs_stop()
    if(!is.null(pid))
      base::stop("IPFS already started. Run ipfs_start(restart = TRUE) to force restart", call. = FALSE)
    message("Starting IPFS. Give it a few seconds...")
    pid <<- sys::exec_with_pid("ipfs", c("daemon", "--init"))
    reg.finalizer(environment(.onAttach), function(x){
      ipfs_stop()
    }, onexit = TRUE)
    while(!ipfs_is_online()){
      Sys.sleep(1)
    }
    cat("OK!\n")
    invisible()
  }

  ipfs_stop <- function(){
    if(!is.null(pid)){
      cat("stopping ipfs...\n")
      tools::pskill(pid)
      pid <<- NULL
    }
  }
  environment()
})


has_ipfs <- function(){
  identical(0L, system2("ipfs", "version", stderr = FALSE))
}

ipfs_is_online <- function(){
  url <- ipfs_api("version")
  handle <- curl::new_handle(TIMEOUT = 1, CONNECTTIMEOUT = 1)
  out <- try(curl::curl_fetch_memory(url), silent = TRUE)
  !inherits(out, "try-error")
}


#' IPFS daemon
#'
#' Start and stop the ipfs server. This is automatically done when attaching
#' the package.
#'
#' @export
#' @rdname daemon
#' @param restart force a restart if ipfs is already running
ipfs_daemon <- daemon$ipfs_start

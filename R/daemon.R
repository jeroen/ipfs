daemon <- local({
  pid <- NULL
  start <- function(){
    if(!is.null(pid))
      stop("IPFS already started. Run ipfs_stop() first to restart", call. = FALSE)
    pid <<- sys::exec_with_pid("ipfs", c("daemon", "--init"))
  }

  stop <- function(){
    if(!is.null(pid)){
      cat("stopping ipfs...\n")
      tools::pskill(pid)
      pid <<- NULL
    }
  }
  environment()
})


#' IPFS daemon
#'
#' Start and stop the ipfs server. This is automatically done when attaching
#' the package.
#'
#' @export
#' @rdname daemon
ipfs_start <- daemon$start

#' @export
#' @rdname daemon
ipfs_stop <- daemon$stop

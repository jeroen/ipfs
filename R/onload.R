.onAttach <- function(libname, pkgname){
  if(!ipfs_is_online()){
    if(has_ipfs()){
      ipfs_start()
      reg.finalizer(environment(.onAttach), function(x){
        ipfs_stop()
      }, onexit = TRUE)
    } else {
      packageStartupMessage("Main 'ipfs' executable not found")
    }
  }
}

has_ipfs <- function(){
  identical(0L, system2("ipfs", "version", stderr = FALSE))
}

ipfs_is_online <- function(){
  url <- ipfs_api("version")
  handle <- curl::new_handle(TIMEOUT = 1, CONNECTTIMEOUT = 1)
  out <- try(curl::curl_fetch_memory(url), silent = TRUE)
  !inherits(out, "try-error")
}

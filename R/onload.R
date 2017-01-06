.onLoad <- function(libname, pkgname){

}

.onAttach <- function(libname, pkgname){
  if(has_ipfs()){
    pid <- sys::exec_with_pid("ipfs", c("daemon", "--init"))
    reg.finalizer(environment(.onLoad), function(...){
      cat("stopping ipfs...\n")
      tools::pskill(pid)
    }, onexit = TRUE)
  } else {
    packageStartupMessage("Main 'ipfs' executable not found")
  }
}

has_ipfs <- function(){
  identical(0L, system2("ipfs", "version", stderr = FALSE))
}


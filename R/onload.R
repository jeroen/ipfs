.onAttach <- function(libname, pkgname){
  if(ipfs_is_online()){
    packageStartupMessage("ipfs deamon is running!")
  } else {
    ipfsdir <- file.path(libname, pkgname, "bin", "go-ipfs")
    if(file.exists(ipfsdir)){
      path <- Sys.getenv("PATH")
      sep <- ifelse(identical(.Platform$OS.type, "windows"), ";", ":")
      Sys.setenv(PATH = paste(path, normalizePath(ipfsdir), sep = sep))
    }
    if(has_ipfs()){
      packageStartupMessage("Use ipfs_daemon() to start the IPFS server!")
    } else {
      packageStartupMessage("Main 'ipfs' executable not found :(")
    }
  }
}

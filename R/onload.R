.onAttach <- function(libname, pkgname){
  if(ipfs_is_online()){
    packageStartupMessage("ipfs deamon is running!")
  } else {
    ipfsdir <- file.path(libname, pkgname, "bin", "go-ipfs")
    if(file.exists(ipfsdir)){
      path <- Sys.getenv("PATH")
      Sys.setenv(PATH = paste(ipfsdir, path, sep = ":"))
    }
    if(has_ipfs()){
      packageStartupMessage("Use ipfs_daemon() to start the IPFS server!")
    } else {
      packageStartupMessage("Main 'ipfs' executable not found :(")
    }
  }
}

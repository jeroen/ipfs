.onLoad <- function(libname, pkgname){

}

.onAttach <- function(libname, pkgname){

}

has_ipfs <- function(){
  identical(0L, system2("ipfs", "version", stderr = FALSE))
}


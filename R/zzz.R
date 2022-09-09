###Create helpful message when package is loaded
.onAttach <- function(libname, pkgname){
  
  packageStartupMessage("Welcome to the naptanmapper package!\n")
  
}
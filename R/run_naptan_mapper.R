#' Launches the naptan mapper Shiny tool in a new window.
#'
#' This tool allows individuals to see National Public Transport Access Nodes (NaPTAN) data on a map. 
#'
#' It utilises the naptanr package to access live NaPTAN API data, and is filterable both by locality and specific stops.
#'
#' It contains options to allow you to select specific localities and stops, either by code or name, and details ina  table
#'
#' @export
#' @name run_naptan_mapper
#' @title Launch Naptan Mapper
#' @examples # Launch of Naptan Mapper
#' run_naptan_mapper()

run_naptan_mapper <- function() {
  appDir <- system.file("naptan_mapper_app", package = "naptanmapper")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `naptanmapper`.", call. = FALSE)
  }
  
  shiny::runApp(appDir, display.mode = "normal")
}
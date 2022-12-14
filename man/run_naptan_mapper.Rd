% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run_naptan_mapper.R
\name{run_naptan_mapper}
\alias{run_naptan_mapper}
\title{Launch Naptan Mapper}
\usage{
run_naptan_mapper()
}
\description{
Launches the naptan mapper Shiny tool in a new window.
}
\details{
This tool allows individuals to see National Public Transport Access Nodes (NaPTAN) data on a map.

It utilises the naptanr package to access live NaPTAN API data, and is filterable both by locality and specific stops.

It contains options to allow you to select specific localities and stops, either by code or name, and details ina  table
}
\examples{
# Launch of Naptan Mapper
run_naptan_mapper()
}

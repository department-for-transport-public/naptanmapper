### Import libraries -----------------------------------------------------------
## Load packages
library(shiny)
library(dplyr)
library(reactable)
library(leaflet)
library(sf)
library(shinyWidgets)
library(naptanr)
library(shinycssloaders)
library(shinyBS)

### Data loading ---------------------------------------------------------------
## Load in ATCO local authority look up from naptanr package
local_area_lookup <- lookup_atco_codes() %>% 
  arrange(AreaName)

### Define User Interface for application
ui <- fluidPage(
  ## Application title
  titlePanel("Naptan Mapper"),
  
  ## Sidebar layout
  sidebarLayout(
    # content to be displayed in sidebar
    sidebarPanel(# entry inputs for app
      fluidRow(
        # drop down with area options e.g. Cambridgeshire
        selectInput(
          "local_area",
          "Select area to investigate",
          local_area_lookup$AreaName,
          selected = local_area_lookup$AreaName[1]
        ),
        # helper on hover over
        bsTooltip(
          "local_area",
          "To search press backspace and begin typing. Will revert to prior selection if no matching area is found. Only data for selected area will be loaded in."
        )
      ),
      # loading spinner
      withSpinner(# dynamic UI to choose input options based on selected local authority
        uiOutput("map_controls"))),
    # content to be displayed in main panel
    mainPanel(# loading spinner
      withSpinner(# dynamic UI to load map and table outputs
        uiOutput("map_ui")))
  ))


### Define server logic required to output map and table
server <- function(input, output, session) {
  ### Create reactive data based on inputs -------------------------------------
  
  # reactive data for leaflet mapping, filters by selected area
  df_area <- reactive({
    # retrieves atco lookup based on input area
    df_lookup <-
      local_area_lookup %>%
      filter(AreaName == input$local_area)
    
    # loads in naptan api data using naptanr package
    # and formats geometry for leaflet map plotting
    df_area <-
      call_naptan(atco = df_lookup$AtcoAreaCode) %>%
      select(
        ATCOCode,
        CommonName,
        NptgLocalityCode,
        LocalityName,
        Easting,
        Northing,
        LocalityCentre,
        StopType
      ) %>%
      st_as_sf(coords = c("Easting", "Northing"), crs = 27700) %>%
      st_transform(4326)
  })
  
  # reactive data based on selected options, used in table and map
  df_x <- eventReactive({
    input$local_area
    input$searchtype
    input$select_display
  },
  {
    df_x = df_area()[df_area()[[input$searchtype]] %in% input$select_display, ]
  })
  
  
  # manages and updates clicked items on map
  df_clicked_points <- reactiveValues()
  
  df_clicked_points$DT <- data.frame(lng = numeric(),
                                     lat = numeric(),
                                     layerId = character())
  
  ### Create dynamic user interface elements -----------------------------------
  
  # render dynamic UI for input controls
  output$map_controls <- renderUI({
    fluidRow(
      # toggle between locality or one specific stop
      radioGroupButtons(
        "locality_or_stop",
        "Display data for specific locality or stop",
        c("Locality", "Stop")
      ),
      # drop down to choose whether to filter by a name or code
      selectInput(
        "searchtype",
        "Search by",
        c("Locality Code" = "NptgLocalityCode",
          "Locality Name" = "LocalityName")
      ), 
      # helper text in hover over
      bsTooltip(
        "searchtype",
        "Gives the option of selecting a locality/stop based on name or code."
      ),
      # drop down to select specific stop or locality
      selectInput(
        "select_display",
        "Select variable to display",
        unique(df_area()$NptgLocalityCode)
      ),
      # helper text in hover over
      bsTooltip(
        "select_display",
        "To search press backspace annd begin typing. Will revert to prior selection if no matching area is found."
      ),
      # button to clear highlighted data from map interaction
      actionButton("reset", "Clear selected stops", class = "btn-danger"),
      # helper text in hover over
      bsTooltip(
        "reset",
        "Refreshes map, deselects stops, and removes highlighting in table."
      )
    )
  })
  
  # dynamic UI for map and table
  output$map_ui <- renderUI({
    fluidRow(
      # defines height of map output relative to window size
      tags$style(type = "text/css",
                 "#map {height: calc(65vh - 130px) !important;}"),
      # loading spinner
      withSpinner(# loads map
        leafletOutput("map")),
      # loading spinner
      withSpinner(# loads table
        reactableOutput("table"))
    )
  })
  
  ### ObserveEvent statements to update app when an input changed---------------
  
  #' local area and searchtype inputs ------------------------------------------
  # if local_area or searchtype inputs change, display only relevant options
  observeEvent({
    input$local_area
    input$searchtype
  },
  {
    # halts input updates until section is completed
    freezeReactiveValue(input, "select_display")
    # define options for select_display input
    df_area_selection <-
      df_area() %>%
      select(selection = input$searchtype) %>%
      st_drop_geometry() %>%
      distinct() %>% 
      arrange(selection)
    # update select_display input options
    updateSelectInput(session, "select_display", choices = df_area_selection)
    
    # reset list of "clicked" markers
    df_clicked_points$DT <- df_clicked_points$DT[NULL,]
  })
  
  ## locality or stop input ----------------------------------------------------
  # if locality_or_stop button switches, display only relevant search options
  observeEvent(input$locality_or_stop, {
    if (input$locality_or_stop == "Locality") {
      # halts input updates until section is completed
      freezeReactiveValue(input, "searchtype")
      freezeReactiveValue(input, "select_display")
      # update select_display input options
      updateSelectInput(
        session,
        "searchtype",
        choices = c("Locality Code" = "NptgLocalityCode",
                    "Locality Name" = "LocalityName")
      )
    } else {
      # halts input updates until section is completed
      freezeReactiveValue(input, "searchtype")
      freezeReactiveValue(input, "select_display")
      # update select_display input options
      updateSelectInput(
        session,
        "searchtype",
        choices = c("ATCO stop code" = "ATCOCode",
                    "Common name" = "CommonName")
      )
    }
  })
  
  ## marker clicks on map ------------------------------------------------------
  # if a marker is selected on app, return ATCOCode
  observeEvent(input$map_marker_click, {
    # check if anything had been clicked on the map
    click <- input$map_marker_click
    
    # stores location and atco in data frame
    df_clicked_points$DT <-
      df_clicked_points$DT %>%
      add_row(data.frame(
        lng = click$lng,
        lat = click$lat,
        layerId = click$id
      ))
    
    # update leaflet map markers
    leafletProxy("map") %>%
      removeMarker(layerId = click$id) %>%
      addAwesomeMarkers(
        lng = click$lng,
        lat = click$lat,
        layerId = click$id,
        icon = awesomeIcons(
          icon = 'ios-close',
          iconColor = 'white',
          library = 'ion',
          markerColor = 'red'
        )
      )
    
    # update table sorting order
    updateReactable("table", data = df_x() %>%
                      mutate(clicked =
                               if_else(
                                 ATCOCode %in%
                                   df_clicked_points$DT$layerId, 1, 0
                               )))
  })
  
  ## reset button clicked ------------------------------------------------------
  observeEvent(input$reset, {
    # clear df of clicked points data frame for reset button
    df_clicked_points$DT <- df_clicked_points$DT[NULL,]
    
    # refresh map
    leafletProxy("map", data = df_x()) %>%
      clearMarkers() %>%
      addAwesomeMarkers(layerId = ~ ATCOCode, icon = icons)
  })
  
  ### Map formatting and rendering ---------------------------------------------
  
  ## grid for rough locality borders -------------------------------------------
  gridded_x <- reactive({
    x_non_grid <- st_buffer(st_union(df_x()$geometry), dist = 0)
    x <- st_buffer(st_union(st_make_grid(x_non_grid)), dist = 100)
    x
  })
  
  ## format icons for markers --------------------------------------------------
  icons <- awesomeIcons(
    icon = 'ios-close',
    iconColor = 'white',
    library = 'ion',
    markerColor = "blue"
  )
  
  ## render leaflet map --------------------------------------------------------
  output$map <- renderLeaflet({
    df_x() %>%
      leaflet() %>%
      addTiles() %>%
      addPolygons(data = gridded_x(),
                  opacity = 0,
                  group = "locality") %>%
      addAwesomeMarkers(layerId = ~ ATCOCode, icon = icons)
  })
  
  
  ### Table formatting and rendering ---------------------------------------------
  
  
  output$table <- renderReactable({
    # select reactive data
    df_x() %>%
      # gives selected stops alue of 1 for later row ordering
      mutate(clicked = if_else(ATCOCode %in% df_clicked_points$DT$layerId, 1, 0)) %>%
      reactable(
        # users can filter table
        filterable = TRUE,
        # highlights rows red if relevant stop is selected on map
        defaultColDef = colDef(
          show = TRUE,
          style = function(value, index) {
            if (df_x()$ATCOCode[index] %in% df_clicked_points$DT$layerId) {
              color <- rgb(
                red = 0.7,
                green = 0,
                blue = 0,
                alpha = 0.6
              )
            } else {
              color <- rgb(
                red = 0,
                green = 0,
                blue = 0,
                alpha = 0
              )
            }
            list(background = color)
          }
        ),
        # default ordering of columns baed on map selection and stop code
        defaultSorted = list(clicked = "desc", ATCOCode = "asc"),
        # basic column formatting
        columns = list(
          ATCOCode = colDef(show = TRUE, name = 'ATCO Code'),
          CommonName = colDef(show = TRUE, name = 'Common Name'),
          NptgLocalityCode = colDef(show = TRUE, name = 'NPTG Locality Code'),
          LocalityName = colDef(show = TRUE, name = 'Locality Name'),
          LocalityCentre = colDef(show = FALSE, name = 'Locality Centre'),
          StopType = colDef(show = TRUE, name = 'Stop Type'),
          geometry = colDef(show = FALSE, name = 'Coordinates'),
          clicked = colDef(show = FALSE)
        )
      )
    
  })
  
  
  
}

### Combine server and ui into a Shiny App -------------------------------------
shinyApp(ui = ui, server = server)

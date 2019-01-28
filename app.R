## global --------------
library(shiny)
library(shinydashboard)
library(shinyjs)
library(DT)
library(shinyauthr)
library(dplyr)

user_base <- data_frame(
  user = c("admin", "user1", "user2"),
  password = c("admin", "user1", "user2"),
  permissions = c("admin", "user", "user"),
  name = c("Youngjun Na", "Kim", "Lee")
)

## header --------------
header <- dashboardHeader(
  title = "Shiny Korea @example",
  titleWidth = 300,
  tags$li(
    class = "dropdown", style = "padding: 8px;",
    shinyauthr::logoutUI("logout")
  ),

  tags$li(
    class = "dropdown",
    tags$a(icon("code"),
      href = "https://github.com/shinykorea",
      title = "Homepage",
      target = "_blank"
    )
  )
)

## sidebar --------------
sidebar <- dashboardSidebar(
  width = 300,
  sidebarMenu(
    menuItem("Sidebar 1", tabName = "link", icon = icon("barcode"))
  )
)

## body --------------
body <- dashboardBody(
  ## Auth ----
  shinyjs::useShinyjs(),
  tags$head(
    tags$style(".table{margin: 0 auto;}"),
    tags$script(
      src = "https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
      type = "text/javascript"
    ),
    includeScript("returnClick.js")
  ),
  shinyauthr::loginUI("login"),
  HTML("<div data-iframe-height></div>"),

  ## tabs ----
  tabItems(
    tabItem(
      tabName = "link",
      dataTableOutput("tab1")
    )
  )
)

## ui --------------
ui <- dashboardPage(header, sidebar, body, skin = "black")


## server --------------
server <- function(input, output, session) {
  ## Auth  --------------
  credentials <- callModule(shinyauthr::login, "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    log_out = reactive(logout_init())
  )

  logout_init <- callModule(shinyauthr::logout, "logout", reactive(credentials()$user_auth))

  observe({
    if (credentials()$user_auth) {
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  })


  ## tab1 ----
  output$tab1 <- renderDataTable({
    req(credentials()$user_auth)
    DT::datatable(iris)
  })
}

## run app  --------------
shinyApp(ui, server)

## ㅃㅘ이팅!

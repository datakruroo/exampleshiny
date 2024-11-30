library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(plotly)  # ใช้สำหรับ gauge chart

data <- read_csv("final_merged_2.csv")

ui <- fluidPage(
  # เพิ่ม CSS สำหรับขอบและปุ่ม
  tags$head(
    tags$style(HTML("
      .custom-box {
        border: 1px solid #ccc;
        padding: 15px;
        border-radius: 5px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        margin-bottom: 20px;
      }
      .custom-button {
        font-size: 14px;
        padding: 5px 10px;
      }
    "))
  ),
  # หัวข้อเว็บไซต์
  titlePanel("KruRoo Teller"),
  tags$p("ระบบทำนายผลการสอบ final รายวิชาวิจัย แสดงค่าความน่าจะเป็นที่จะสอบได้คะแนนแต่ละส่วนเกินร้อยละ 60",
         style = "font-size: 16px; color: gray; margin-top: -10px; margin-bottom: 20px;"
  ),
  
  # แบ่งพื้นที่สำหรับฟอร์มและการแสดงผล
  fluidRow(
    # ฟอร์มกรอกข้อมูล
    column(
      width = 4,
      h3("โปรดกรอกข้อมูลของนิสิต"),
      selectInput(
        "department", 
        "สาขาวิชาเอกของนิสิต", 
        choices = data %>% count(department) %>% pull(department)
      ),
      selectInput(
        "ontime_submit", 
        "โดยปกติส่งการบ้านตรงเวลาหรือไม่", 
        choices = c("ส่วนใหญ่ตรงเวลา", "ส่วนใหญ่ไม่ตรงเวลา")
      ),
      sliderInput(
        "midterm", 
        "คะแนนสอบ Midterm ที่ได้รับ (ร้อยละ):",
        min = 0, max = 30,
        value = 25, 
        step = 5
      ),
      selectInput(
        "percent_submit", 
        "ร้อยละของการส่งการบ้าน:", 
        choices = c("น้อยกว่าร้อยละ 90", "ร้อยละ 90 ขึ้นไป")
      ),
      actionButton("predict", "Predict", class = "custom-button btn-primary")  # ปุ่มขนาดเล็ก
    ),
    # พื้นที่สำหรับแสดงผล
    column(
      width = 8,
      div(
        class = "custom-box",
        uiOutput("predictionHeader"),  # แสดงหัวข้อแบบไดนามิก
      plotOutput("probPlot")
    )
  )
)
)
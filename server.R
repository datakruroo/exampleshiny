server <- function(input, output, session) {
  # โหลดโมเดลและ recipe ที่บันทึกไว้
  model <- readRDS("glmnet_model.rds")  # แก้ไข path ให้ชี้ไปยังไฟล์โมเดล

  # Predict function
  prediction <- eventReactive(input$predict, {
    # สร้างข้อมูลใหม่ตามที่ผู้ใช้ป้อน
    new_data <- data.frame(
      department = input$department,
      submit_time = ifelse(input$ontime_submit == "ส่วนใหญ่ตรงเวลา", "ontime","late"),
      midterm = input$midterm,
      percent_submit = ifelse(input$percent_submit == "น้อยกว่าร้อยละ 90", "low", "high")

    ) %>% slice(rep(1,5)) %>% mutate(outcome_A = LETTERS[1:5])
    

    
    # Preprocess ข้อมูลใหม่ด้วย recipe
   # new_data_transformed <- bake(myrecipe, new_data = new_data)
    
    # ทำนายผลด้วย workflow โมเดล
    probs <- predict(model, new_data, type = "prob")
    
    # รวม outcome_A กับ probability ของคลาส pass
    prob_data <- new_data %>%
      select(outcome_A) %>%
      bind_cols(probability = probs$.pred_pass)
    
    return(prob_data)
  })
  
  
  output$predictionHeader <- renderUI({
    # ตรวจสอบว่ามีการทำนายหรือยัง
    req(prediction()$ready)  # หาก ready = TRUE จะแสดงหัวข้อ
    
    h3("ผลการทำนาย")
  })
  # แสดงผลลัพธ์ในตาราง
  output$probPlot <- renderPlotly({
    prob_data <- prediction()
    
    output$probPlot <- renderPlot({
      prob_data <- prediction()
      
      ggplot(prob_data, aes(x = outcome_A, y = probability, fill = outcome_A)) +
        geom_bar(stat = "identity") +
        labs(title = "Probability Score > 60% for Each Outcome", x = "Outcome", y = "Probability") +
        scale_y_continuous(limits=c(0,1), labels = scales::percent_format())+
        theme_minimal()+
        theme(legend.position = "none")
    })
    
    
  

})
  
}
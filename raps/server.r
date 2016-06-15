
library(randomForestSRC)
options(device=NULL)

# Model must be built in production environment or will have endian error
# This model was build using the Docker environment and saved to the image repo
local_files = list.files()
if ("model.rda" %in% local_files){
  load("model.rda")  
} else {
  penn.cr = read.csv(file = "pennData.csv", stringsAsFactors = FALSE)
  rsf.cr <- rfsrc(Surv(time, event) ~ PSA + SM + ECE + SVI + LNI + pG1 + pG2 + age + rpyear + race + BMI, data = penn.cr, seed = 23, importance = "random")  
  save(rsf.cr,file="model.rda")
}

# Function to get bmi from weight and height
bmi = function(h,w) {(w * 703)/(h*h)}

# Render interface with initial values
data = c()
data$race = 1
data$PSA = 14
data$age = 45
data$SVI = 0
data$SM = 0
# Calculate bmi
weight = 145
feet = 5
inches = 10
height = feet*12 + inches
data$BMI = bmi(height,weight)
data$LNI = 0
data$rpyear = 2004
data$ECE = 0
data$pG1 = 0
data$pG2 = 0
data$time = NULL
data$event = NULL
data$X10yrOutcome = NULL
data$chf.oob1 = NULL
data$chf.oob2 = NULL
data$S = NULL
data$cif1 = NULL
data$cif2 = NULL
data$M1 = NULL
data$M2 = NULL
data$EST = NULL
data$k_r = NULL
data$time1 = NULL
data$time2 = NULL

prediction = predict(rsf.cr, as.data.frame(data))
CIF.1 = as.numeric(prediction$cif[,which(prediction$time.interest == 120),1])
CIF.2 = as.numeric(prediction$cif[,which(prediction$time.interest == 120),2])

HTML(c('<div class="col-md-8" style="margin-top:0px; padding-top:0px">',
       '<span style="padding-right:5px">P(Reoccurrence)</span><span>P(Death)</span>',
       '<br><button class="btn btn-lg btn-default" type="button" disabled="">',round(CIF.1,2),'</button><button class="btn btn-lg btn-default" type="button" disabled="">',round(CIF.2,2),'</button></div>'))


shinyServer(function(input, output, session) {
  
  # Combine the selected variables into a new data frame
  data = reactive({
    data = c()
    data$race = switch(input$race,
                   white = 1,
                   black = 2,
                   other = 3,
                   1)
   
    data$psa = as.numeric(input$psa)
    data$age = input$age
    data$svi = input$svi
    data$sm = input$sm
    
    # Calculate bmi
    weight = as.numeric(input$weight)
    feet = as.numeric(input$feet)
    inches = as.numeric(input$inches)
    height = feet*12 + inches
    data$bmi = bmi(height,weight)

    data$lni = input$lni
    data$rpyear = input$year
    data$ece = as.numeric(input$ece)
    data$pg1 = as.numeric(input$pg1)
    data$pg2 = as.numeric(input$pg2)
    data
  })

  output$scores = renderUI({
  
  data = data()    
  X = c()
  X$rpyear = data$rpyear
  X$PSA = data$psa
  X$race = data$race
  X$age = data$age
  X$pG1 = data$pg1
  X$pG2 = data$pg2
  X$SVI = data$svi
  X$SM = data$sm
  X$ECE = data$ece
  X$BMI = data$bmi
  X$LNI = data$lni
  X$time = NULL
  X$event = NULL
  X$X10yrOutcome = NULL
  X$chf.oob1 = NULL
  X$chf.oob2 = NULL
  X$S = NULL
  X$cif1 = NULL
  X$cif2 = NULL
  X$M1 = NULL
  X$M2 = NULL
  X$EST = NULL
  X$k_r = NULL
  X$time1 = NULL
  X$time2 = NULL

  prediction = predict(rsf.cr, as.data.frame(X))
  CIF.1 = as.numeric(prediction$cif[,which(prediction$time.interest == 120),1])
  CIF.2 = as.numeric(prediction$cif[,which(prediction$time.interest == 120),2])

  # If either is zero, change to two decimal places (will render as "0")  
  if (CIF.1==0){
    CIF.1 = "0.00"
  }
  if (CIF.2==0){
    CIF.2 = "0.00"
  }
  HTML(c('<div class="col-md-8" style="margin-top:0px; padding-top:0px">',
    '<span style="padding-right:5px">P(Reoccurrence)</span><span>P(Death)</span>',
    '<br><button class="btn btn-lg btn-default" type="button" disabled="">',round(CIF.1,2),'</button><button class="btn btn-lg btn-default" type="button" disabled="">',round(CIF.2,2),'</button></div>'))
  
  })
  
})

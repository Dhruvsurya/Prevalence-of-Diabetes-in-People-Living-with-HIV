
#Importing Libraries
library(readxl)
library(epiDisplay)
library(lmtest)
library(MASS)
library(car)
library(sigmoid)
library(multcomp)
library(ResourceSelection)
library(boot)
library(ggplot2)
library(vcd)
library(caTools)
library(caret)
library(tidyverse)
library(forestploter)
library(grid)
library(epitools)


#Importing Dataset
ncd <- read_excel("C:/Users/dhruv/OneDrive/Desktop/Project Nikhil Sir/Prevalence of Diabetes in PLHIV/Data/NCD_Database_27_02_19.xlsx")

View(ncd)
summary(ncd)


#For splitting data according to gender
ncdm = ncd %>% filter(Sex == "M")
ncdf = ncd %>% filter(Sex == "F")


#Creating variable : doc
doc = c()
for (i in 1:length(ncd$`Have you ever been told by a doctor or other health care worker that you have raised blood sugar or diabetes`)) {
  if (is.na(ncd$`Have you ever been told by a doctor or other health care worker that you have raised blood sugar or diabetes`[i])) {
    doc = append(doc, "Missing value")
  } else if (ncd$`Have you ever been told by a doctor or other health care worker that you have raised blood sugar or diabetes`[i] == "Yes") {
    doc = append(doc, "Yes")
  } else {
    doc = append(doc, "No")
  }
}

ncd$doc = doc


#Creating variable : hba1c
hba1c = c()
for (i in 1:length(ncd$`Please enter HbA1c value in %`)) {
  if (is.na(ncd$`Please enter HbA1c value in %`[i])) {
    hba1c = append(hba1c, 0)
  }
  else {
    hba1c = append(hba1c, ncd$`Please enter HbA1c value in %`[i])
  }
}

ncd$hba1c = hba1c


#Creating variable : glucose
glucose = c()
for (i in 1:length(ncd$Glucose)) {
  if (is.na(ncd$Glucose[i])) {
    glucose = append(glucose, 0)
  }
  else {
    glucose = append(glucose, ncd$Glucose[i])
  }
}

ncd$glucose = glucose


#defining the response variable : Diabetes (db)
db = c()
for (i in 1:521) {
  if (is.na(ncd$hba1c[i])){
    na.rm = TRUE
  } else if (ncd$hba1c[i] >= 6.5) {
    db = append(db, 1)
  } else if (ncd$glucose[i] >= 200) {
    db = append(db, 1)
  } else if (ncd$doc[i] == "Yes") {
    db = append(db, 1)
  } else {
    db = append(db, 0)
  }
}

ncd$diabetic = db;ncd$diabetic


#Creating variable : Tuberculosis
tb_d = c()
for (i in 1:521){
  if ("Yes" %in% ncd$`Have you ever been told that you have had TB?`[i]){
    tb_d = append(tb_d, 1)
  }
  else if ("Yes" %in% ncd$`Were you put on TB therapy?`[i]){
    tb_d = append(tb_d, 1)
  }
  else{
    tb_d = append(tb_d, 0)
  }
}
ncd$tb_d = tb_d


#Creating variable : raised BP
r_bp = c()
for (i in 1:521){
  if (ncd$avg_sys1[i] > 120){
    r_bp = append(r_bp, 1)
  }
  else if ("Yes" %in% ncd$`Have you ever been told by a doctor or other health care worker that you have raised blood pressure or hypertension?`[i]){
    r_bp = append(r_bp, 1)
  }
  else{
    r_bp = append(r_bp, 0)
  }
}
r_bp


#Creating variable : cooking fuel
cook_fuel = c()
for (i in 1:521){
  if ("Yes" %in% ncd$`Gas Stove`[i]){
    cook_fuel = append(cook_fuel, 1)
  }
  else if ("Yes" %in% ncd$`Electric Stove`[i]){
    cook_fuel = append(cook_fuel, 1)
  }
  else{
    cook_fuel = append(cook_fuel, 0)
  }
}

ncd$cook_fuel = cook_fuel


#Creating variable : Cholesterol (cho)
cho = c()
for (i in 1:521){
  if (!is.na(ncd$`Total cholesterol`[i]) && ncd$`Total cholesterol`[i] > 200){
    cho = append(cho, 1)
  }
  else if (is.na(ncd$`Total cholesterol`[i])){
    cho = append(cho, 0)
  }
  else{
    cho = append(cho, 0)
  }
}
cho


#Creating variable : HDL (hdl)
hdl = c()
for (i in 1:521){
  if (!is.na(ncd$HDL[i]) && ncd$HDL[i] < 50){
    hdl = append(hdl, 1)
  }
  else if (is.na(ncd$HDL[i])){
    hdl = append(hdl, 0)
  }
  else{
    hdl = append(hdl, 0)
  }
}
hdl


#Creating variable : LDL (ldl)
ldl = c()
for (i in 1:521){
  if (!is.na(ncd$`LDL (calculated)`[i]) && ncd$`LDL (calculated)`[i] > 130){
    ldl = append(ldl, 1)
  }
  else if (is.na(ncd$`LDL (calculated)`[i])){
    ldl = append(ldl, 0)
  }
  else{
    ldl = append(ldl, 0)
  }
}
ldl


#Creating variable : Triglycerides (trigl)
trigl = c()
for (i in 1:521){
  if (!is.na(ncd$Triglycerides[i]) && ncd$Triglycerides[i] > 300){
    trigl = append(trigl, 1)
  }
  else if (is.na(ncd$Triglycerides[i])){
    trigl = append(trigl, 0)
  }
  else{
    trigl = append(trigl, 0)
  }
}
ncd$trigl = trigl


#Creating variable : Age above 40 years (age40)
age40 = c()
for (i in 1:521){
  if (!is.na(ncd$`Age(Years)`[i]) && ncd$`Age(Years)`[i] >= 40) {
    age40 = append(age40, 1)
  }
  else if (is.na(ncd$`Age(Years)`[i])){
    age40 = append(age40, 2)
  }
  else{
    age40 = append(age40, 0)
  }
}
ncd$age40 = age40


#Creating variable : Income (inc)
inc = c()
for (i in 1:521){
  if (is.na(ncd$`Monthly household income (in INR)`[i])){
    inc = append(inc, 0)
  }
  else if (ncd$`Monthly household income (in INR)`[i] == "1 000 - 4 999" || ncd$`Monthly household income (in INR)`[i] == "5 000 - 9 999") {
    inc = append(inc, 1)
  }
  else{
    inc = append(inc, 0)
  }
}
ncd$inc = inc


#Creating variable : Obese (obes)
obes = c()
for (i in 1:521){
  if (is.na(ncd$BMI[i])){
    obes = append(obes, 0)
  }
  else if (ncd$BMI[i] > 25) {
    obes = append(obes, 1)
  }
  else{
    obes = append(obes, 0)
  }
}
ncd$obes = obes



#For obtaining the p-value, Odds Ratio, 95%CI of Odds Ratio

#model = glm(diabetic ~ <add variable name>, data = ncd, family = "binomial")
#summary(model)
#logistic.display(model)



#2x2 contingency tables
ncd$diabetic = ordered(ncd$diabetic,levels = c(0,1),labels = c("No", "Yes"))
smoked = ncd$`Have you ever smoked?`
hyp = ncd$`hyper 1`
ncd$hyp = ordered(hyp, levels = c(0,1), labels = c("No", "Yes"))

#Demographic Variables
gender = table(db, ncd$Sex);gender
age_40 = table(db, age40);age_40
edu = table(db, ncd$education);edu #or
inco = table(db, inc);inco
loc = table(db, ncd$`Living location`);loc
empl = table(db, ncd$`Are you employed?`);empl
rig_act = table(db, ncd$`Does your work involve moderate -intensity activity that causes small increases in breathing or heart rate like (brisk walking    carrying or lifting light loads) for at least 10 minutes continuously ?`);rig_act
cookfuel = table(db, cook_fuel);cookfuel
hfias = table(db, ncd$`HFIAS Score`);hfias_score = ncd$`HFIAS Score`;hfias

#Social(Lifestyle) Variables
alc = table(db, ncd$`Do you drink alcohol?`);alco = ncd$`Do you drink alcohol?`;alc
smo = table(db, smoked);smo
hyper = table(db, hyp);hyper
bp = table(db, r_bp);bp
obs = table(db, obes);obs
chol = table(db, cho);ncd$cho = cho;chol
hd_l = table(db, hdl);hd_l
ld_l = table(db, ldl);ld_l
trig = table(db, trigl);ncd$trigl = trigl;trig

#Clinical Variables
tuber = table(db, tb_d);tuber
renal = table(db, ncd$`Have you ever been told by a doctor or other health care worker that you have chronic renal disease?`);ncd$renal_d = ncd$`Have you ever been told by a doctor or other health care worker that you have chronic renal disease?`;renal
liver = table(db, ncd$`Have you ever been told by a doctor or other health care worker that you have chronic liver disease?`);ncd$liver_d = ncd$`Have you ever been told by a doctor or other health care worker that you have chronic liver disease?`;liver
tb_inf = table(db, ncd$`QGIT/IGRA Result`);ncd$tb_in = ncd$`QGIT/IGRA Result`; tb_inf





#BOXPLOTS 

#Diabetic vs Height
Diabetes = factor(db)
Height_cm = ncd$`Height (cm)`

df1 <- data.frame(db, ncd$`Height (cm)`)
ggplot(df1, aes(x = Diabetes, y = Height_cm)) +
  geom_boxplot() + 
  ggtitle("Diabetes vs Height") + 
  theme(plot.title = element_text(face = "bold",hjust = 0.5))



#Diabetic vs Weight
Diabetes = factor(db)
Weight_kg = ncd$`Weight (kg)`

df2 <- data.frame(db, ncd$`Weight (kg)`)
ggplot(df2, aes(x = Diabetes, y = Weight_kg)) +
  geom_boxplot() + 
  ggtitle("Diabetes(F) vs Weight") + 
  theme(plot.title = element_text(face = "bold",hjust = 0.5))



#Diabetic vs Cholesterol
Diabetes = factor(db)
Total_Cholesterol = ncd$`Total cholesterol`

df3 <- data.frame(db, ncd$`Total cholesterol`)
ggplot(df3, aes(x = Diabetes, y = Total_Cholesterol)) +
  geom_boxplot() + 
  ggtitle("Diabetes vs Cholesterol") + 
  theme(plot.title = element_text(face = "bold",hjust = 0.5))



#Diabetic vs Age
Diabetes = factor(db)
Age = ncd$`Age(Years)`

df4 <- data.frame(db, ncd$`Age(Years)`)
ggplot(df4, aes(x = Diabetes, y = Age)) +
  geom_boxplot() + 
  ggtitle("Diabetes(F) vs Age") + 
  theme(plot.title = element_text(face = "bold",hjust = 0.5))



#Diabetic vs Mid Upper Arm Circumference
Diabetes = factor(db)
Mid_Upper_Arm_Circumference_cm = ncd$`Mid-upper arm circumference (cm)`

df5 <- data.frame(db, ncd$`Mid-upper arm circumference (cm)`)
ggplot(df5, aes(x = Diabetes, y = Mid_Upper_Arm_Circumference_cm)) +
  geom_boxplot() + 
  ggtitle("Diabetes(F) vs Mid - Upper Arm Circumference") + 
  theme(plot.title = element_text(face = "bold",hjust = 0.5))



#Diabetic vs Waist to Hip Ratio
Diabetes = factor(db)
Waist_to_Hip_Ratio = ncd$`Waist to hip ratio`

df6 <- data.frame(db, ncd$`Waist to hip ratio`)
ggplot(df6, aes(x = Diabetes, y = Waist_to_Hip_Ratio)) +
  geom_boxplot() + 
  ggtitle("Diabetes(F) vs Waist - to - Hip Ratio") + 
  theme(plot.title = element_text(face = "bold",hjust = 0.5))




#Model with all variables for the whole dataset

rig = ncd$`Does your work involve moderate -intensity activity that causes small increases in breathing or heart rate like (brisk walking    carrying or lifting light loads) for at least 10 minutes continuously ?`
rig1 = relevel(as.factor(rig), ref = "Yes")
ncd$r_bp = r_bp
ncd$ldl = ldl


model = glm(diabetic ~ Sex + age40 + rig1 + hyp + r_bp + obes + cho + ldl + trigl, data = ncd, family = "binomial")
summary(model)

OR = exp(coef(model))
CI_95 = exp(confint(model))
table = cbind(OR, CI_95);table


#Model with all variables for males

modelm = glm(db ~ age40 + obes + cho + trigl, data = ncdm, family = "binomial")
summary(modelm)

OR = exp(coef(modelm))
CI_95 = exp(confint(modelm))
table = cbind(OR, CI_95);table


#Model with all variables for females

modelf = glm(db ~ age40 + rig1 + hyp + r_bp + obes + trigl, data = ncdf, family = "binomial")
summary(modelf)

OR = exp(coef(modelf))
CI_95 = exp(confint(modelf))
table = cbind(OR, CI_95);table



#Forest Plots : Whole Dataset
dt = read_excel("C:\\Users\\dhruv\\OneDrive\\Desktop\\Project Nikhil Sir\\Prevalence of Diabetes in PLHIV\\Data\\Multivariate.xlsx")
dt$est = ifelse(is.na(dt$est), "",dt$est)
dt$lower = ifelse(is.na(dt$lower), "",dt$lower)
dt$upper = ifelse(is.na(dt$upper), "",dt$upper)
dt$`Prevalence of Diabetes (N = 44)` = ifelse(is.na(dt$`Prevalence of Diabetes (N = 44)`), "",dt$`Prevalence of Diabetes (N = 44)`)
dt$`OR (95% CI) Univariate` = ifelse(is.na(dt$`OR (95% CI) Univariate`), "",dt$`OR (95% CI) Univariate`)
dt$`OR (95% CI) Multivariate` = ifelse(is.na(dt$`OR (95% CI) Multivariate`), "",dt$`OR (95% CI) Multivariate`)
dt$`p-value*` = ifelse(is.na(dt$`p-value*`), "",dt$`p-value*`)
dt$`Forest Plot` = ifelse(is.na(dt$`Forest Plot`), "",dt$`Forest Plot`)
dt$Characteristic = ifelse(dt$`Prevalence of Diabetes (N = 44)` == "", dt$Characteristic, paste0("   ", dt$Characteristic))


est = as.numeric(dt$est)
lower = as.numeric(dt$lower)
upper = as.numeric(dt$upper)

tm = forest_theme(base_size = 9)


p = forest(dt[,c(1:5,9)], est = est, lower = lower, 
           upper = upper,
           sizes = 0.4, 
           ci_column = 5,
           ref_line = 1,
           xlim = c(0, 6),
           theme = tm)

p = edit_plot(p, row = c(1, 4, 7, 10, 13, 16, 19, 22, 25), 
              gp = gpar(fontface = "bold"))
plot(p)





#Forest Plots : Male Dataset
dtm = read_excel("C:\\Users\\dhruv\\OneDrive\\Desktop\\Project Nikhil Sir\\Prevalence of Diabetes in PLHIV\\Data\\Multivariate_Male.xlsx")
dtm$est = ifelse(is.na(dtm$est), "",dtm$est)
dtm$lower = ifelse(is.na(dtm$lower), "",dtm$lower)
dtm$upper = ifelse(is.na(dtm$upper), "",dtm$upper)
dtm$`Prevalence of Diabetes (N = 27)` = ifelse(is.na(dtm$`Prevalence of Diabetes (N = 27)`), "",dtm$`Prevalence of Diabetes (N = 27)`)
dtm$`OR (95% CI) Univariate` = ifelse(is.na(dtm$`OR (95% CI) Univariate`), "",dtm$`OR (95% CI) Univariate`)
dtm$`OR (95% CI) Multivariate` = ifelse(is.na(dtm$`OR (95% CI) Multivariate`), "",dtm$`OR (95% CI) Multivariate`)
dtm$`p-value*` = ifelse(is.na(dtm$`p-value*`), "",dtm$`p-value*`)
dtm$`Forest Plot` = ifelse(is.na(dtm$`Forest Plot`), "",dtm$`Forest Plot`)
dtm$Characteristic = ifelse(is.na(dtm$Characteristic),"",dtm$Characteristic)
dtm$Characteristic = ifelse(dtm$`Prevalence of Diabetes (N = 27)` == "", dtm$Characteristic, paste0("   ", dtm$Characteristic))


estm = as.numeric(dtm$est)
lowerm = as.numeric(dtm$lower)
upperm = as.numeric(dtm$upper)


m = forest(dtm[,c(1:5,9)], est = estm, lower = lowerm, 
           upper = upperm, 
           sizes = 0.4, 
           ci_column = 5,
           ref_line = 1,
           xlim = c(0, 6))

m = edit_plot(m, row = c(1, 5, 9, 13), 
              gp = gpar(fontface = "bold"))
plot(m)





#Forest Plots : Female Dataset
dtf = read_excel("C:\\Users\\dhruv\\OneDrive\\Desktop\\Project Nikhil Sir\\Prevalence of Diabetes in PLHIV\\Data\\Multivariate_Female.xlsx")
dtf$est = ifelse(is.na(dtf$est), "",dtf$est)
dtf$lower = ifelse(is.na(dtf$lower), "",dtf$lower)
dtf$upper = ifelse(is.na(dtf$upper), "",dtf$upper)
dtf$`Prevalence of Diabetes (N = 17)` = ifelse(is.na(dtf$`Prevalence of Diabetes (N = 17)`), "",dtf$`Prevalence of Diabetes (N = 17)`)
dtf$`OR (95% CI) Univariate` = ifelse(is.na(dtf$`OR (95% CI) Univariate`), "",dtf$`OR (95% CI) Univariate`)
dtf$`OR (95% CI) Multivariate` = ifelse(is.na(dtf$`OR (95% CI) Multivariate`), "",dtf$`OR (95% CI) Multivariate`)
dtf$`p-value*` = ifelse(is.na(dtf$`p-value*`), "",dtf$`p-value*`)
dtf$`Forest Plot` = ifelse(is.na(dtf$`Forest Plot`), "",dtf$`Forest Plot`)
dtf$Characteristic = ifelse(is.na(dtf$Characteristic),"",dtf$Characteristic)
dtf$Characteristic = ifelse(dtf$`Prevalence of Diabetes (N = 17)` == "", dtf$Characteristic, paste0("   ", dtf$Characteristic))


estf = as.numeric(dtf$est)
lowerf = as.numeric(dtf$lower)
upperf = as.numeric(dtf$upper)


f = forest(dtf[,c(1:5,9)], est = estf, lower = lowerf, 
           upper = upperf, 
           sizes = 0.4, 
           ci_column = 5,
           ref_line = 1,
           xlim = c(0, 6))

f = edit_plot(f, row = c(1, 5, 9, 13, 17, 21), 
              gp = gpar(fontface = "bold"))
plot(f)







# load dataset
tokyo <- read.csv(
  "data/Tokyo_20244_20253_en.csv",
  fileEncoding = "CP932",
  stringsAsFactors = FALSE
) 

# Data Cleaning 
#construction year to numeric 
tokyo$Building...Construction.year <- as.numeric(tokyo$Building...Construction.year)
#building age created 
tokyo$building_age <- 2025 - tokyo$Building...Construction.year
#inavlid values dropped 
tokyo <- tokyo[!is.na(tokyo$building_age) & tokyo$building_age >= 0, ]
#taking price log 
tokyo$log_price <- log(tokyo$Total.transaction.value)
#statistics 
summary(tokyo$building_age)
summary(tokyo$log_price)

#regression 

model1 <- lm(
  log_price ~ building_age,
  data = tokyo
)

summary(model1)

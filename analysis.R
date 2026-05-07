# =========================
# ECON 398 Tokyo Housing Project
# =========================

# load dataset
tokyo <- read.csv(
  "data/Tokyo_20244_20253_en.csv",
  fileEncoding = "CP932",
  stringsAsFactors = FALSE
)

# -------------------------
# Data cleaning
# -------------------------

# convert important variables to numeric
tokyo$Building...Construction.year <- as.numeric(tokyo$Building...Construction.year)
tokyo$Total.transaction.value <- as.numeric(tokyo$Total.transaction.value)
tokyo$Area... <- as.numeric(tokyo$Area...)
tokyo$Nearest.station...Distance <- as.numeric(tokyo$Nearest.station...Distance)

# create building age
tokyo$building_age <- 2025 - tokyo$Building...Construction.year

# keep valid observations only
tokyo <- tokyo[
  !is.na(tokyo$building_age) &
    tokyo$building_age >= 0 &
    !is.na(tokyo$Total.transaction.value) &
    tokyo$Total.transaction.value > 0 &
    !is.na(tokyo$Area...) &
    tokyo$Area... > 0 &
    !is.na(tokyo$Nearest.station...Distance) &
    !is.na(tokyo$City.Town.Ward.Village),
]

# create log price
tokyo$log_price <- log(tokyo$Total.transaction.value)

# -------------------------
# Summary statistics
# -------------------------
cat("Summary of building age:\n")
print(summary(tokyo$building_age))

cat("\nSummary of log price:\n")
print(summary(tokyo$log_price))

cat("\nSummary of area:\n")
print(summary(tokyo$Area...))

cat("\nSummary of distance to nearest station:\n")
print(summary(tokyo$Nearest.station...Distance))

# -------------------------
# Regression 1: simple model
# -------------------------
model1 <- lm(
  log_price ~ building_age,
  data = tokyo
)

cat("\n=========================\n")
cat("MODEL 1: log_price ~ building_age\n")
cat("=========================\n")
print(summary(model1))

# -------------------------
# Regression 2: add controls
# -------------------------
model2 <- lm(
  log_price ~ building_age + Area... + Nearest.station...Distance,
  data = tokyo
)

cat("\n===============================================\n")
cat("MODEL 2: log_price ~ building_age + area + distance\n")
cat("===============================================\n")
print(summary(model2))

# -------------------------
# Regression 3: add location fixed effects
# -------------------------
model3 <- lm(
  log_price ~ building_age + Area... + Nearest.station...Distance + factor(City.Town.Ward.Village),
  data = tokyo
)

cat("\n===============================================================\n")
cat("MODEL 3: log_price ~ building_age + area + distance + location FE\n")
cat("===============================================================\n")
print(summary(model3))

# -------------------------
# Regression 4: rebuilt indicator
# rebuilt = building age 5 years or less
# -------------------------
tokyo$rebuilt <- ifelse(tokyo$building_age <= 5, 1, 0)

model4 <- lm(
  log_price ~ rebuilt + Area... + Nearest.station...Distance + factor(City.Town.Ward.Village),
  data = tokyo
)

cat("\n====================================================================\n")
cat("MODEL 4: log_price ~ rebuilt indicator + area + distance + location FE\n")
cat("====================================================================\n")
print(summary(model4))

# -------------------------
# Simple scatter plot
# -------------------------
plot(
  tokyo$building_age,
  tokyo$log_price,
  xlab = "Building Age",
  ylab = "Log Transaction Price",
  main = "Log Price vs Building Age"
)
abline(model1, col = "red", lwd = 2)

# -------------------------
# Stargazer tables
# -------------------------
# install.packages("stargazer")  # uncomment and run once, then comment out again
library(stargazer)

# Summary statistics table (fixed: rename columns before passing to stargazer)
stats_df <- tokyo[, c("log_price", "building_age", "Area...", "Nearest.station...Distance", "rebuilt")]
stats_df <- as.data.frame(stats_df)
colnames(stats_df) <- c("Log Price", "Building Age (years)", "Floor Area (sqm)", "Distance to Station (min)", "Rebuilt (<=5 yrs)")

stargazer(
  stats_df,
  type = "text",
  title = "Summary Statistics",
  out = "summary_stats.txt"
)

# Regression table (Models 1-4, ward FE omitted from display)
stargazer(
  model1, model2, model3, model4,
  type = "text",
  title = "Regression Results: Effect of Building Age on Log Transaction Price",
  covariate.labels = c("Building Age", "Floor Area", "Distance to Station", "Rebuilt (<=5 yrs)"),
  omit = "City.Town.Ward.Village",
  omit.labels = "Ward Fixed Effects",
  add.lines = list(c("Ward FE", "No", "No", "Yes", "Yes")),
  out = "regression_table.txt"
)

# -------------------------
# Extension: 1981 Building Code Reform (RD Design)
# -------------------------
# Japan's New Earthquake Resistance Standards took effect June 1981
# Buildings built before 1981 face higher rebuilding pressure/incentives
# This creates plausibly exogenous variation in building age near the cutoff

tokyo$post1981 <- ifelse(tokyo$Building...Construction.year >= 1981, 1, 0)

# Restrict to buildings within 20 years of the cutoff for RD-style analysis
tokyo_rd <- tokyo[
  !is.na(tokyo$Building...Construction.year) &
    tokyo$Building...Construction.year >= 1961 &
    tokyo$Building...Construction.year <= 2001,
]

# Plot: avg log price by construction year, around the 1981 cutoff
avg_by_year <- aggregate(log_price ~ Building...Construction.year, data = tokyo_rd, FUN = mean)

plot(
  avg_by_year$Building...Construction.year,
  avg_by_year$log_price,
  xlab = "Construction Year",
  ylab = "Avg Log Transaction Price",
  main = "Avg Log Price by Construction Year (RD around 1981 Code Reform)",
  pch = 16,
  col = ifelse(avg_by_year$Building...Construction.year >= 1981, "steelblue", "tomato")
)
abline(v = 1981, lty = 2, lwd = 2)
legend("topleft", legend = c("Pre-1981", "Post-1981"), col = c("tomato", "steelblue"), pch = 16)

# RD regression: log price on post1981 indicator + running variable + controls
tokyo_rd$year_centered <- tokyo_rd$Building...Construction.year - 1981

model_rd <- lm(
  log_price ~ post1981 + year_centered + I(post1981 * year_centered) +
    Area... + Nearest.station...Distance + factor(City.Town.Ward.Village),
  data = tokyo_rd
)

cat("\n====================================================================\n")
cat("MODEL RD: Regression Discontinuity around 1981 Building Code Reform\n")
cat("====================================================================\n")
print(summary(model_rd))

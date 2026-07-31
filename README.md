# econ398_tokyo_housing

Repository for an ECON 398 project examining whether rebuilding residential
properties causes an increase in housing prices in Tokyo, using Japanese real
estate transaction data.

## Research Question

Does residential rebuilding cause higher housing prices, or does redevelopment
simply tend to occur in already higher-priced areas? The analysis compares
transaction prices for newer and older properties within the same wards and
time periods, using construction year, transaction price, floor area, distance
to the nearest station, and ward location.

As an extension, the project uses Japan's 1981 New Earthquake Resistance
Standards (which took effect in June 1981) as a source of plausibly exogenous
variation in building age, comparing prices of buildings constructed just
before vs. just after the cutoff in a regression discontinuity-style design.

## Data Source

The primary data source is the Ministry of Land, Infrastructure, Transport and
Tourism (MLIT) Real Estate Information Library (transaction prices):
https://www.reinfolib.mlit.go.jp/realEstatePrices/

Raw data lives at `data/Tokyo_20244_20253_en.csv` (Tokyo residential
transactions, 2024 Q4 - 2025 Q3).

Literature reviewed: "The price of residential land in large US cities"
(Morris A. Davis and Michael G. Palumbo).

## Repository Contents

- `analysis.R` — the full pipeline: loads the raw CSV, cleans it, runs all
  regressions, and writes out summary/regression tables and plots. This is
  the only script in the project; there is no separate cleaning step to run
  first.
- `data/Tokyo_20244_20253_en.csv` — raw MLIT transaction data (input).
- `econ398_tokyo_housing.Rproj` — RStudio project file.

## How to Run

1. Open `econ398_tokyo_housing.Rproj` in RStudio (or otherwise set the
   working directory to the repo root).
2. Install the one external dependency if you haven't already:
   ```r
   install.packages("stargazer")
   ```
3. Run `analysis.R` top to bottom. It will:
   - Load `data/Tokyo_20244_20253_en.csv` and clean it (drop rows with
     missing/invalid building age, price, area, station distance, or ward).
   - Print summary statistics for building age, log price, area, and station
     distance.
   - Fit four regressions of `log_price` on building age (or a "rebuilt"
     indicator for buildings <= 5 years old), adding controls and ward fixed
     effects across models.
   - Produce a scatter plot of log price vs. building age.
   - Write `summary_stats.txt` and `regression_table.txt` (stargazer tables,
     Models 1-4).
   - Run the 1981 building-code regression discontinuity extension: restrict
     to buildings from 1961-2001, plot average log price by construction
     year around the 1981 cutoff, and fit an RD regression with a
     pre/post-1981 indicator interacted with a centered running variable.

Outputs currently land in the repo root (not in `figures/`/`tables/`, which
are placeholders for now):
- `summary_stats.txt` — summary statistics table
- `regression_table.txt` — regression results, Models 1-4
- `age_price_plot.png` — log price vs. building age scatter
- `rd_1981_plot.png` — average log price by construction year around 1981

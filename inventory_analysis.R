# title: Variable Radius Plot Inventory Analysis----
# author: Adam Houston
# date: 6/28/2022
# output: github_document
# goal: This script takes variable radius plot (VRP) forest inventory data and 
# creates useful visualizations for making management decisions.
# 
# packages----
pacman::p_load(tidyverse, gridExtra, Polychrome, sf)

# 1 - read data----
# 
url = "https://raw.githubusercontent.com/adambhouston/inventory_analysis/main/trees_data"
trees = read_csv(url)

url2 = "https://raw.githubusercontent.com/adambhouston/inventory_analysis/main/species_codes_data"
codes = read_csv(url2)

# 2 - add necessary variables----
# 
k = .00545415

# add plot radius factor (prf), limiting distance (ld), area of influence (aoi), 
# number of plots in each stand, trees per acre (tpa), and basal area
# represented by each tree in the stand (ba)
trees = trees |> 
  group_by(stand) |> 
  mutate(
    prf = 8.696/sqrt(baf),
    ld = dbh*prf,
    aoi = (pi*ld^2)/43560,
    plots = n_distinct(plot),
    tpa = (1/aoi)/plots,
    ba = baf/plots
  ) 

trees = left_join(trees, codes, by = c("species" = "code"))

trees = trees |> 
  mutate(
    bf = (0.04604*(dbh^2.2312))*
      ((logs*16)^0.75951)*
      ((fc/100)^2.34055)
  )  

# 3 - summarise at division and stand level----
# 
division_summary = trees |> 
  group_by(stand) |> 
  summarise(
    plots = median(plots),
    tpa = round(sum(tpa)),
    ba_ac = round(sum(ba)),
    qmd = round(sqrt(sum(ba)/(sum(tpa)*k))),
    bf_ac = round(sum(bf))
  )

stand_names = unique(trees$stand)

stand_summaries = list()

for(i in 1:length(stand_names)){
temp_sum =  
  trees |> 
    filter(stand == stand_names[i]) |> 
    group_by(species) |> 
    summarise(
      tpa = round(sum(tpa)),
      ba_ac = round(sum(ba)),
      qmd = round(sqrt(sum(ba)/(sum(tpa)*k))),
      bf_ac = round(sum(bf)),
      percent_ba = round(100*ba_ac/(division_summary |> filter(stand == stand_names[i]) |> select(ba_ac)))
    )

stand_summaries[[i]] = temp_sum
names(stand_summaries) = as.character(stand_names)
}


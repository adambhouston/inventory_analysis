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
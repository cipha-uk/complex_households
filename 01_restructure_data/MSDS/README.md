# Build the Community Services Data Set(MSDS)

Konstantinos Daras 22/08/2022

STATUS: ON PROGRESS

## Overview
This calculates the counts of referrals and contacts of patients by month and type of service.

The core building part is based on the work done in R Studio for the System P analysis.

## Stages
There are 2 main stages to this -

- 01_Merge_DBs [`01_Merge_DBs.sql`]: Combines selected columns from both MSDS databases (current and historical database) into a single database. During this process all columns are cleaned and recoded as needed. 
- 02_Calc_Fin [`02_Calc_2021.sql`]: Calculates the counts of referrals and contacts of patients by month and type of service for a given year.


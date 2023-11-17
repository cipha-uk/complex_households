# Build the Community Services Data Set(CSDS)

Konstantinos Daras 04/10/2022

STATUS: **COMPLETED**

## Overview
This calculates the counts of referrals and contacts of patients by month and type of service.

The core building part is based on the work done in R Studio for the System P analysis.

## Stages
There are 2 main stages to this -

- 01_Merge_DBs [`01_Merge_DBs.sql`]: Combines selected columns from both CSDS databases (current and historical database) into a single database. During this process all columns are cleaned and recoded as needed. 
- 02_Calc_Fin [`02_Calc_2021.sql`]: Calculates the counts of referrals and contacts of patients by month and type of service for 2021.

## TODO
[]

## Notes

## ISSUES
- 204 records available in the [CSDS_CYP607PrimDiag] table. Primary diagnosis is not available 
- 337 records available in the [CSDS_Hist_CYP607PrimDiag] table. Primary diagnosis is not available 


## DB table naming convention as suggested by OB.

|Naming convention	|Examples	|Description|
|---|---|---|
|ref*	|_ref_IMD, _ref_AC_medication_codes	|Reference tables which don't change.
|prod*	|_prod_MPI, _prod_UPRN	|Production tables which are stable and used for analysis.
|test*	|_test_MPI, _test_UPRN	|Test tables which are used to test validity of data with other users.
|initial_ *	|OB_MPI, RP_UPRN	|Development tables used to develop methods etc.




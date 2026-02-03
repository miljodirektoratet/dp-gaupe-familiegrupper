# Workflow for grouping observations into family groups

Here I try to explain the content of the folder AutomatiskGruppering and how the files can be used to calculate the number of family groups.

Inside the main folder you will find a Rstudio project, two example scripts, this word document and four folders. There is one example script for the old distance rules and one example script for the new suggestion. Before I describe how these scripts work, I will go through the content of the four folders.

## Data Folder

The Data folder contains the following files:

- **`byttedyrkategori_skandinavia_tettede_hull.shp`**
  Shapefile with the prey class categories used by the old distance rules. The original file did not have full coverage of all terrestrial land in Norway, so I have buffered it. It looks weird on the west coast of Norway, but here we do not have any lynx, and where it looks weird in Trøndelag it actually represents how the prey class categories look like.

- **`Data2014_2021Compiled.rds`**
  This is an .rds file that can be loaded directly into R. It contains all the observations of lynx family groups in Scandinavia from the reproduction years (RS) 2014-2021. This is a combination of points and linestrings. This is created based on the observations from Rovbase and tracking logs (sporlogger). These data need to be fetched from Rovbase automatically and organised similarly to how this data frame is organized.

- **`Data2023Compiled.rds`**
  Data for the reproduction year 2023.

- **`DeerTerrestrial.tif`**
  Raster with the continuous "prey density" for the new distance rules.

- **`Distmat.rds`**
  Distance matrix with distances not crossing water. Used in the new distance rules.

- **`IdentifierDistances.rds`**
  Identifier to connect the distance matrix to the Rovbase observations. Used in the new distance rules.

- **`LandUtenHav250.tif`**
  Raster with cells that do not contain ocean. Used to force all observations to a raster cell without ocean. Used in the new distance rules.

- **`LandUtenHav250_TransitionLayer1s.rds`**
  Large transition matrix, used to calculate distances not crossing the ocean. I will guess this is too large to be loaded locally on a computer. Used in the new distance rules.

## Functions Folder

The Functions folder contains the following files:

- **`Function_Ordering.R`**
  This script contains the function `this.order()`. The function orders the data in different ways, deciding where the algorithm should start to group the observations.

- **`Function_GroupLynxOld.R`**
  This script contains the function `grouplynx()`. This function uses two different algorithms; one custom-made and one based on the base R function `hclust`. The `grouplynx()` can be improved, e.g. moving the distance calculations outside the functions, so this only needs to be done once. If you are continuing with the old distance rules I can improve this function.

- **`Function_GroupLynxOld_MultipleStart.R`**
  This script contains the function `grouplynx_diff_starts()`. This function tries a range of different starting points and calculates the number of family groups based on both the custom-made algorithm and the hclust algorithm. If `grouplynx()` is improved, some changes need to be made here as well.

- **`Function_GroupLynxNew.R`**
  This script contains the function `grouplynx_new()`. Same arguments as for the grouping function for the old distance rules, but the distance matrix needs also to be supplied to the function. The efficiency of the function is improved.

- **`Function_GroupLynxNew_MultipleStart.R`**
  This script contains the function `grouplynx_new_diff_starts()`. Same arguments as for the grouping function for the old distance rules, but the distance matrix needs also to be supplied to the function. The efficiency of the function is improved.

## Output Folders

The folders **GroupedObsOld** and **GroupedObsNew** are where the grouped observations from the two example scripts end up.

## Example Scripts

The two example scripts (`ExampleOldAK` and `ExampleNewAK`) go through one example of how to use the old distance rules and one example for the new distance rules. In the example script with the new distance rules, I have supplied data for the distance matrix as this takes a long time to calculate.

If the new version of the distance rules is preferred and should be implemented to Rovbase, I will suggest doing this differently than what I have done in the script. I will guess one has to calculate the distances between the observations continuously as they are put into Rovbase (e.g. every day) and then store these observations and simply calculate the distance to the new observations as they come along. However, SNO and länsstyrrelsen might do changes during the quality control, so there should be a possibility to recalculate distances too or do this regularly at a low frequency.

## Note

Btw. it looks like the base R function `hclust` (stats package) has been changed since I wrote the first version of the script, since now the starting point does not matter anymore for the hierarchical clustering.

## Questions Miljødirektoratet

### Input data

**`Data2014_2021Compiled.rds`**

This is created based on the observations from Rovbase and tracking logs (sporlogger). These data need to be fetched from Rovbase automatically and organised similarly to how this data frame is organized.

What are the data input layers?

| Dataset | ID name | ID convention | included | Comments |
|---------|---| ---------------|----------|----------|
| *_rovviltobservasjons_stedfesting | RovbaseID | R<nr> | yes |  |
| *_rovviltobservasjons_spor | RovbaseID | R<nr> | yes |  |
| *_doderovdyr | RovbaseID | M<nr> | yes | Only "Dødsdato" |
| *_dna | DNAID | D<nr> | no (?) | I dont see DNA in Compiled.rds  |

What data pre-processing steps are taken here?

- Could you provide us with a detailed list of cleaning/transformations steps?

You mention in the code:

- R555181 is wrong, there is a track that is not valid included there
- R559946 is also wrong, but not that much

How do you know that they are wrong? What Quality check do you propose?

- Data2014_2021Compiled.rds and Data2023Compiled.rds do not have the same attribus?

- What is the temporal range?
  - You load all data (2014 - 2021)
  - Are we not only using data from ONE inventarisationperiod?
    - okt. 2024 - mars. 2025
    - okt. 2025 - mars. 2026

Proposal:

- Fetch weekly new observations from Rovbase
- Bronze/silver:
  - *_rovviltobservasjons_stedfesting
  - *_rovviltobservasjons_spor
  - *_doderovdyr
  - *_byttedyrkategorier
- Gold:
  - gold_gaupeobservasjoner
  - gold_groupinglines
  -
  -
- Analysis include only observations from the current inventarisation period (e.g. okt. 2024 - mars. 2025)

Cleaning/Tranformation steps:

- *_rovviltobservasjons_spor
- Cast the data as multipoint, these means the "sporlogger" will have multiple points per "sporlogg"
- Filter out linestrings > 10 km (LOG warnings in databricks)
- Self-distance in distance matrix should be 0.
  - Using thresholds/What is a good threshold?
  - self - distance < 50 m set to 0?
  - self-distance > 50m remove?
- Check if observations are made in the Oceans
- Add prey classes to silver?

Cluster Analysis:

- Can we not just use hclust? as there is minimal differece between custom/hclust

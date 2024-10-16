# Extinct

## The R Package
  
_work in progress:_ The shiny app (detailed below) essentially rides on a handful of helper functions that allow reading the IUCN Red List conservation status assessment template excel file and calculate extinction probabilities. To give users maximum flexibility, this repository will be wrapped into an R package to allow incorporating functions into scripts.


## The App

This is a Shiny app for a) modeling probability of extinction based on survey and record data, and b) to inform on whether a species should be classified as Critically Endangered or Extinct for the IUCN Red List conservation status assessment, using both the extinction probability form surveys and records, and an assessment of threats to species and their habitat. It is essentially a wrapper for the [IUCN Red List Extinction assessment tool](https://www.iucnredlist.org/resources/ex-probability).

Launch the app here: https://hcliedtke.shinyapps.io/extinct/

## Background

The [IUCN Red List Extinction assessment tool](https://www.iucnredlist.org/resources/ex-probability) is based on the following publications:   

[Keith et al. 2017](https://doi.org/10.1016/j.biocon.2017.07.026) Describe an argument map to derive at probability estimates for threats that are impacting the extinction risk of species both at a local and spatial (distribution-wide) scale.

[Thompson et al. 2017](https://www.sciencedirect.com/science/article/pii/S0006320717300575#s0080) published a method for estimating detection probabilities of a target species from survey data. It takes into account successful sightings (records), search efforts that did not result in sightings (surveys), and estimates for opportunistic sightings outside of official records (passive surveys).

[Akçakaya et al. 2017](https://doi.org/10.1016/j.biocon.2017.07.027) combine the two extinction probabilities defined by Keith et al. and Thompson et al. to help determine if a species should be classified as Critically Endangered or Extinct.

[Butchart et al. 2018](https://doi.org/10.1016/j.biocon.2018.08.014) proposed threhsold for the two extinction estimates, which were then adopted by the Red List Guidelines.


## Data input

To run the app, only a single excel file is required. This is the IUCN Red List Extinction Probability data template, which can be downloaded from [here](https://www.iucnredlist.org/resources/ex-probability). The template along with its documentation goes into great detail on how to fill it out. The excel file has three important sheets.

## 1. Threats

Besides information on the species, this first sheet requires the extinction probabilities at the local and spatial scale to be entered, based on the methods of [Keith et al. 17](https://doi.org/10.1016/j.biocon.2017.07.026).


## 2. and 3. Records and Surveys

For the correct implementation of this app, I refer you to [Thompson et al. 2017](https://www.sciencedirect.com/science/article/pii/S0006320717300575#s0080). In brief, this application requires two input tables, represented on two different sheets of the input Excel. These summarize the sightings and absence of sightings for years where the target species was actively looked for.

1. Records data - a table with four columns with at least the following headers: year, pci_lower, pci_upper, pci_best
2. Surveys data - a table with ten columns with at least the following headers: year, eps_lower, eps_upper, eps_best, pi_lower, pi_upper, pi_best, pr_lower, pr_upper, pr_best


The parameters refer to:

* eps: the proportion of the taxon's habitat within its likely entire range that was surveyed (0 to 1)
* pi: the probability that the taxon, or recent evidence of it, could have been reliably identified in the survey if it had been recorded (0 to 1)
* pr: the probability that the taxon, or recent evidence of it, would have been recorded in the survey (0 to 1)
* pci: the probability that the taxon is correctly identified as extant (0 to 1)



### Passive Years

In addition to "active" survey years, this model assumes that during "passive" years, i.e. years between active surveys, there might still have been some chance of someone recording the target species. This could have been an amateur naturalist, someone living in the area etc. For these passive survey years, we also need to specify upper and lower eps, pi and pr bounds. The initial values are taken from the appropriate fields in the "Surveys" sheet, but they can be interactively adjusted in the shiny app to see how these affect the resulting model.


## Cite this App

The model was developed by:  

Akçakaya, H. R., D. A. Keith, M. Burgman, S. H. M. Butchart, M. Hoffmann, H. M. Regan, I. Harrison, and E. Boakes. (2017). Inferring extinctions III: A cost-benefit framework for listing extinct species. Biological Conservation 214:336–342.

Butchart, S. H. M., Lowe,  S., Martin, R. W., Symes, A., Westrip, J. R. S., Wheatley, H. (2018). Which bird species have gone extinct? A novel quantitative classification approach. Biological Conservation, 227, 9-18.

Keith, D. A., Butchart, S. H. M.,  Regan, H. M.,  Harrison, I. H., Akçakaya, H. R., Solow, A. R.,  Burgman, M. A. (2017). Inferring extinctions I: A structured method using information on threats. Biological Conservation, 214. 320-327.

Thompson, C. J., Koshkina, V., Burgman, M. A., Butchart, S. H., & Stone, L. (2017). Inferring extinctions II: a practical, iterative model based on records and surveys. Biological Conservation, 214, 328-335.

  
Please cite their publication when using their models, including via this Shiny app. If this shiny app was useful to you, please cite this GitHub repository as well:

Liedtke, H. C. (2024). Extinct: A shiny app for inferring extinction. v1.0.0. https://github.com/hcliedtke/extinct 

# Extinct

flexdashboard

## The App

This is a Shiny app for modeling probability of extinction based on survey and record data, and combines this with extinction probability estimates based on threats to the species, to inform on whether a species should be classified as Critically Endangered or Extinct for the IUCN Red List conservation status assessment. It is essentially a wrapper for the [IUCN Red List Extinction assessment tool](https://www.iucnredlist.org/resources/ex-probability).

Launch the app here: https://hcliedtke.shinyapps.io/extinct/

## Background

[Keith et al. 2017](https://doi.org/10.1016/j.biocon.2017.07.026) Discuss how to use an argument map to try and derive at probability estimates for threats that are impacting the extinction risk of species both at a local and spatial (distribution-wide) scale.

[Thompson et al. 2017](https://www.sciencedirect.com/science/article/pii/S0006320717300575#s0080) published a method for estimating detection probabilities of a target species from survey data. It takes into account successful sightings (records) as well as search efforts that did not result in sightings (surveys), as well as the probabilities of surveys having been adequately conducted. The authors provide R code to execute their model and this Shiny app implements this code to produce a platform for estimating your own detection probabilities and for interactively adjusting survey adequacy probabilities to see how this affects detection probabilities.

[Akçakaya et al. 2017](https://doi.org/10.1016/j.biocon.2017.07.027) Then combine these two extinction probabilities to help determine if a species should be classified as Critically Endangered or Extinct, in line with the IUCN Red List species conservation status assessments.


## Data input

To run the app, only a single excel file is required. This follows the template of the IUCN Red List Extinction Probability data template, which can be downloaded from [here](https://www.iucnredlist.org/resources/ex-probability). The template along with its documentation goes into great detail on how to fill it out. The excel file has three important sheets.

## 1. Threats

Besides information on the species, this first sheet requires the extinction probabilities at the local and spatial scale to be entered, based on the methods of [Keith et al. 17](https://doi.org/10.1016/j.biocon.2017.07.026).


## 2 and 3. Records and Surveys

For the correct implementation of this app, I refer you to [Thompson et al. 2017](https://www.sciencedirect.com/science/article/pii/S0006320717300575#s0080). In brief, this application requires two input tables, represented on two different sheets of the input Excel. These summarize the sightings and absence of sightings for years where the target species was actively looked for.

1. Records data - a table with tree columns with at least the following headers: year, pci_lower, pci_upper
2. Surveys data - a table with seven columns with at least the following headers: year, eps_lower, eps_upper, pi_lower, pi_upper, pr_lower, pr_upper


The lower and upper bounds refer to:

* eps: the proportion of the taxon's habitat within its likely entire range that was surveyed (0 to 1)
* pi: the probability that the taxon, or recent evidence of it, could have been reliably identified in the survey if it had been recorded (0 to 1)
* pr: the probability that the taxon, or recent evidence of it, would have been recorded in the survey (0 to 1)
* pci: the probability that the taxon is correctly identified as extant (0 to 1)


### Example of Records Data

|year|pci_lower|pci_upper|
|----|---------|---------|
|1929|0.95     |0.99     |
|1947|0.1      |0.4      |
|1960|0.95     |0.99     |
|1963|0.75     |0.94     |
|1969|0.75     |0.94     |
|1970|0.1      |0.4      |
|1971|0.1      |0.4      |
|1972|0.6      |0.8      |
|1982|0.6      |0.8      |
|1985|0.6      |0.8      |


### Example of Surveys Data

|year|eps_lower|eps_upper|pi_lower|pi_upper|pr_lower|pr_upper|
|----|---------|---------|--------|--------|--------|--------|
|1986|0.4      |0.8      |0.7     |0.95    |0.7     |0.95    |
|1988|0.4      |0.8      |0.7     |0.95    |0.7     |0.95    |
|1989|0.8      |0.95     |0.7     |0.95    |0.7     |0.95    |
|1999|0.8      |0.95     |0.7     |0.95    |0.7     |0.95    |
|2000|0.7      |0.9      |0.7     |0.95    |0.7     |0.95    |
|2004|0.8      |0.95     |0.7     |0.95    |0.7     |0.95    |
|2009|0.8      |0.95     |0.7     |0.95    |0.7     |0.95    |


### Passive Years

In addition to "active" survey years, this model assumes that during "passive" years, i.e. years between active surveys, there might still have been some chance of someone recording the target species. This could have been an amateur naturalist, someone living in the area etc. For these passive survey years, we also need to specify upper and lower eps, pi and pr bounds. The initial values are taken from the appropriate fields in teh "Surveys" sheet, but they can be interactively adjusted in the shiny app to see how these affect the resulting model.


## Cite this App

The model was developed by:  

Akçakaya, H. R., D. A. Keith, M. Burgman, S. H. M. Butchart, M. Hoffmann, H. M. Regan, I. Harrison, and E. Boakes. (2017). Inferring extinctions III: A cost-benefit framework for listing extinct species. Biological Conservation 214:336–342.

Keith, D. A., Butchart, S. H. M.,  Regan, H. M.,  Harrison, I. H., Akçakaya, H. R., Solow, A. R.,  Burgman, M. A. (2017). Inferring extinctions I: A structured method using information on threats. Biological Conservation, 214. 320-327.

Thompson, C. J., Koshkina, V., Burgman, M. A., Butchart, S. H., & Stone, L. (2017). Inferring extinctions II: a practical, iterative model based on records and surveys. Biological Conservation, 214, 328-335.

Butchart, S. H. M., Lowe,  S., Martin, R. W., Symes, A., Westrip, J. R. S., Wheatley, H. (2017). Which bird species have gone extinct? A novel quantitative classification approach. Biological Conservation, 227, 9-18.

Please cite their publication when using their models, including via this Shiny app. If this shiny app was useful to you, please cite this GitHub repository as well:

Liedtke, H. C. (2024). Extinct: A shiny app for inferring extinction v1.0.0

# Extinct

## The App

This is a Shiny app for modeling probability of extinction based on survey data.

Launch the app here: https://hcliedtke.shinyapps.io/extinct/

## Background

[Thompson et al. 2013](https://www.sciencedirect.com/science/article/pii/S0006320717300575#s0080) published a method for estimating detection probabilities of a target species from survey data. It takes into account successful sightings (records) as well as search efforts that did not result in sightings (surveys), as well as the probabilities of surveys having been adequately conducted. The authors provide R code to execute their model and this Shiny app implements this code to produce a platform for estimating your own detection probabilities and for interactively adjusting survey adequacy probabilities to see how this affects detection probabilities.


## Data input

## Records and Surveys

For the correct implementation of this app, I refer you to [Thompson et al. 2013](https://www.sciencedirect.com/science/article/pii/S0006320717300575#s0080). In brief, this application requires two input tables as .csv files, that summarize the sightings and absence of sightings for years where the target species was actively looked for. 

1. Records data - a table with tree columns with the following headers: year, pci_lower, pci_upper
2. Surveys data - a table with seven columns with the following headers: year, eps_lower, eps_upper, pi_lower, pi_upper, pr_lower, pr_upper
  
    
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


## Passive Years

In addition to "active" survey years, this model assumes that during "passive" years, i.e. years between active surveys, there might still have been some chance of someone recording the target species. This could have been an amateur naturalist, someone living in the area etc. For these passive survey years, we also need to specify upper and lower eps, pi and pr bounds. By default, these are set to the suggested values in the original publication, but they can be interactively adjusted in the shiny app to see how these affect the resulting model.


## Cite this App

The model was developed by:  

Thompson, C. J., Koshkina, V., Burgman, M. A., Butchart, S. H., & Stone, L. (2017). Inferring extinctions II: a practical, iterative model based on records and surveys. Biological Conservation, 214, 328-335.

Please cite their publication when using their models, including via this Shiny app. If this shiny app was useful to you, please cite this GitHub repository as well:

Liedtke, H. C. (2024). Extinct: A shiny app for inferring extinction v1.0.0

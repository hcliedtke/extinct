####################################################################################################
## Implementation of a model to estimate extinction probability from threats, records and surveys
## Colin J. Thompson, Vira Koshkina, Mark A. Burgman, Stuart H. M. Butchart and Lewi Stone
## R code Appendix
#####################################################################################################



## Sampling of the values, counting st dev then setting


require(stats)# function for calculating mid-range values -------------------------
pxt.recording=function(pci,pxt){pci+(1-pci)*pxt}
pxt.survey=function(eps, pi, pr, pxt){(1-eps*pi*pr)*pxt}

px.mid = function(records=records, surveys = all_surveys, all_years=record_years)
{
  
  ### convert input to matrix
  records=as.data.frame(records)
  surveys=as.data.frame(surveys)
  years=all_years$year

  
  
  PXt = NULL
  PXt.min = NULL
  PXt.max = NULL
  sd=NULL
  PX0 = 1 # species is extant at year 0 P(X0)=1
  
  # first year t=1
  rec = records[records[,1]==years[1],]
  pci.mid =rec[,"pci_best"]
  pci.min=rec[,"pci_lower"]
  pci.max=rec[,"pci_upper"]
  
  PXt[1]=pxt.recording(pci.mid, PX0)
  PXt.min[1]=pxt.recording(pci.min, PX0)
  PXt.max[1]=pxt.recording(pci.max, PX0)
  
  
  n=10000 #number of samples
  pxt.sam=rep(PX0,n)
  stdev=(rec[,"pci_upper"] - rec[,"pci_lower"])/4
  pci.sam = rnorm(n,pci.mid,stdev)
  pxt.sam = pxt.recording(pci.sam, pxt.sam)
  
  sd[1]=sd(pxt.sam)
  
  
  for (t in 2:length(years)) {
    
    #calculating rj
    if (all_years$record[t]==1) #if recording
    {
      
      rec = records[records[,1]==years[t],]
      
      #get mid point estimate
      pci.mid=rec[,"pci_best"]
      pci.min=rec[,"pci_lower"]
      pci.max=rec[,"pci_upper"]
      
      
      
      PXt[t]=pxt.recording(pci.mid, PXt[t-1])
      
      PXt.min[t]=pxt.recording(pci.min, PXt.min[t-1])
      PXt.max[t]=pxt.recording(pci.max, PXt.max[t-1])
      
      #sample to get min and max bounds
      stdev=(rec[,"pci_upper"] - rec[,"pci_lower"])/4
      pci.sam = rnorm(n,pci.mid,stdev)
      pxt.sam = pxt.recording(pci.sam, pxt.sam)
      sd[t]=sd(pxt.sam)
      
      
      
      
    }  else #if survey
    {
      sur=surveys[surveys[,1]==years[t],]
      eps.mid = sur[,"eps_best"]
      pi.mid = sur[,"pi_best"]
      pr.mid = sur[,"pr_best"]
      
      
      eps.min = sur[,"eps_lower"]
      pi.min = sur[,"pi_lower"]
      pr.min = sur[,"pr_lower"]
      
      eps.max = sur[,"eps_upper"]
      pi.max = sur[,"pi_upper"]
      pr.max = sur[,"pr_upper"]
      
      
      PXt[t]=pxt.survey(eps.mid, pi.mid, pr.mid, PXt[t-1])
      PXt.min[t] = pxt.survey(eps.max, pi.max, pr.max, PXt.min[t - 1])
      PXt.max[t] = pxt.survey(eps.min, pi.min, pr.min, PXt.max[t - 1])
      
      
      eps.sam = rnorm(n,eps.mid,(eps.max - eps.min) / 4)
      pi.sam = rnorm(n,pi.mid,(sur[,"pi_upper"] - sur[,"pi_lower"]) / 4)
      pr.sam = rnorm(n,pr.mid,(sur[,"pr_upper"] - sur[,"pr_lower"]) / 4)
      pxt.sam = pxt.survey(eps.sam, pi.sam, pr.sam, pxt.sam)
      sd[t]=sd(pxt.sam)
    }
    
  }
  # print(cbind(PXt-3*sd,PXt,PXt+3*sd))
  return (cbind(PXt-3*sd,PXt,PXt+3*sd, PXt.min, PXt.max))
  
}


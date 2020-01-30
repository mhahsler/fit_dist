# fit_dist helper based on R package 

cat("fit_dist helper based on R package fitdistrplus\n") 
cat("This script is distributed under the Creative Commons Attribution 4.0 International License.\n") 
cat("For usage, examples and questions, see https://github.com/mhahsler/fit_dist\n\n")

# check if fitdistrplus is installed
if(!("fitdistrplus" %in% installed.packages()[,"Package"])) install.packages("fitdistrplus")
library("fitdistrplus")

fit_dist <- function(x, distributions = NULL, discrete = NULL, 
  plot = TRUE, ...) {
   
  dists_cont = c("unif", "norm", "lnorm", "exp", "gamma", "beta", "weibull")
  dists_disc = c("binom", "pois", "nbinom", "geom", "hyper")
  
  x <- x[is.finite(x)]
 
  if(is.null(distributions)) {
    if(is.null(discrete)) discrete <- ifelse(all(x == floor(x)), TRUE, FALSE)
    
    if(discrete) distributions <- dists_disc
    else distributions <- dists_cont
  }
 
  cat("Fitting", paste(distributions, collapse = ", "), "\n") 
  
  # fit distributions 
  f <- lapply(distributions, function(d) {
    try(fitdist(x, d, ...), silent = FALSE)
    })

  names(f) <- distributions
  f <- f[!sapply(f, is, "try-error")]
  
  # create plots
  if(plot) {
    oldpar <- par(mfrow = c(1, 2))
    denscomp(f, legendtext = names(f))
    qqcomp(f, legendtext = names(f))
    #cdfcomp(f, legendtext = names(f))
    #ppcomp(f, legendtext = names(f))
    par(oldpar)
  }
  
  # calculate goodness-of-fit statistics
  # Note: if is for a bug in gofstat
  gof <- gofstat(if(length(f)<2) f[[1]] else f, fitnames = names(f))
  attr(f, "gof") <- gof
  
  if(is.null(gof$kstest)) gof$kstest <- rep(NA, times = length(gof$aic))
  if(is.null(gof$cvmtest)) gof$cvmtest <- rep(NA, times = length(gof$aic))
  if(is.null(gof$adtest)) gof$adtest <- rep(NA, times = length(gof$aic))
  if(is.null(gof$chisqpvalue)) gof$chisqpvalue <- rep(NA, times = length(gof$aic))

  cat("Test results:\n")
  print(data.frame(
    "Kolmogorov-iSmirnov test" = gof$kstest,
    "Cramer-von Mises test" = gof$cvmtest,
    "Anderson-Darling test" = gof$adtest,
    "Chi-Square p-value" = gof$chisqpvalue))
  
   cat(paste("\n*** Best fit using the AIC is:", 
    names(which.min(gof$aic)),"***\n")) 
   cat(paste("*** Best fit using the BIC is:", 
    names(which.min(gof$bic)),"***\n\n")) 
  
  f
}

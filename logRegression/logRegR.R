
remove(list = ls())
setwd('C:\\worktemp\\WheelVid_LogReg\\RModelling')

library(gridExtra)
library(ggplot2)
library(runjags)
library(rjags)
library(loo)
library(cowplot)
library(coda)
source("HDIofMCMC.r")
matlabDat = readMat('pupilForRegress.mat', maxLength=NULL, fixNames=TRUE, drop=c("singletonLists"))

correct = as.vector(matlabDat[['allCorrect']])
trialDiff = as.vector(matlabDat[['allTrialDiff']])
base = matlabDat[['base']]
pupSizeTrials = as.vector(matlabDat[['allCorrPupSize']])
basePupSize = as.vector(matlabDat[['allCorrBasePupSize']])


NTotal = as.numeric(length(correct))


# prepare the data for JAGS
dat <- dump.format(list(y=correct, x1 = basePupSize, x2 = trialDiff,  NTotal=NTotal))

# Initialize chains
inits1 <- dump.format(list(beta0=0,beta1=0,beta2=0,  .RNG.name="base::Super-Duper", .RNG.seed=99999 ))
inits2 <- dump.format(list(beta0=1,beta1=1,beta2=1,  .RNG.name="base::Wichmann-Hill", .RNG.seed=1234  ))
inits3 <- dump.format(list(beta0=-1,beta1=-1,beta2=-1, .RNG.name="base::Mersenne-Twister", .RNG.seed=6666 ))

# Tell JAGS which latent variables to monitor
monitor = c("beta0","beta1","beta2")
model='C:\\worktemp\\WheelVid_LogReg\\Rmodelling\\simpleLogistic.txt'
# runjags.options(force.summary=TRUE)
# Run the function that fits the models using JAGS
resultsBASE <- run.jags(method="parallel",model,
                        monitor=monitor, data=dat, 
                        n.chains=3, inits=c(inits1,inits2,inits3), plots = FALSE, burnin=5000, sample=1000, thin=5)

chainsBASE = rbind(resultsBASE$mcmc[[1]], resultsBASE$mcmc[[2]], resultsBASE$mcmc[[3]])

HDIofMCMC(chainsBASE[,2])

resultsBASE


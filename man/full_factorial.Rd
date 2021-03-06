% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fct_full_factorial.R
\name{full_factorial}
\alias{full_factorial}
\title{Generates a Full Factorial Design}
\usage{
full_factorial(
  setfactors = NULL,
  reps = NULL,
  l = 1,
  type = 2,
  plotNumber = 101,
  continuous = FALSE,
  planter = "serpentine",
  seed = NULL,
  locationNames = NULL,
  data = NULL
)
}
\arguments{
\item{setfactors}{Numeric vector with levels of each factor.}

\item{reps}{Number of replicates (full blocks).}

\item{l}{Number of locations. By default \code{l = 1}.}

\item{type}{Option for CRD or RCBD designs. Values are \code{type = 1} (CRD) or \code{type = 2} (RCBD). By default \code{type = 2}.}

\item{plotNumber}{Numeric vector with the starting plot number for each location. By default \code{plotNumber = 101}.}

\item{continuous}{Logical fpr plot number continuous or not. By default \code{continuous = FALSE}.}

\item{planter}{Option for \code{serpentine} or \code{cartesian} plot arrangement. By default  \code{planter = 'serpentine'}.}

\item{seed}{(optional) Real number that specifies the starting seed to obtain reproducible designs.}

\item{locationNames}{(optional) Names for each location.}

\item{data}{(optional) Data frame with the labels of factors.}
}
\value{
A list with information on the design parameters.

Data frame with the full factorial field book.
}
\description{
It randomly generates a full factorial design across locations.
}
\examples{
# Example 1: Generates a full factorial with 3 factors each with 2 levels. 
# This in an RCBD arrangement with 3 reps.
fullFact1 <- full_factorial(setfactors = c(2,2,2), reps = 3, l = 1, type = 2, 
                            plotNumber = 101, 
                            continuous = TRUE, 
                            planter = "serpentine", 
                            seed = 325, 
                            locationNames = "FARGO")
fullFact1$infoDesign
head(fullFact1$fieldBook,10)

# Example 2: Generates a full factorial with 3 factors and each with levels: 2,3, 
# and 2, respectively. 
# This in an RCBD arrangement with 5 reps in 3 locations.
fullFact2 <- full_factorial(setfactors = c(2,3,2), reps = 5, l = 3, type = 2, 
                            plotNumber = c(101,1001,2001), 
                            continuous = FALSE, 
                            planter = "serpentine", 
                            seed = 326, 
                            locationNames = c("Loc1","Loc2","Loc3"))
fullFact2$infoDesign
head(fullFact2$fieldBook,10)

}
\references{
\emph{Design and Analysis of Experiments, Volume 1, Introduction to Experimental Design. Second Edition}.
 Klaus Hinkelmann & Oscar Kempthorne.John Wiley & Sons, Inc., Hoboken, New Jersey.
}

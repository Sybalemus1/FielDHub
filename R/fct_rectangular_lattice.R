#' Generates a Rectangular Lattice Design.
#
#' @description It randomly generates a rectangular lattice design across locations.
#'
#' @param t Number of  treatments.
#' @param r Number of blocks (full resolvable replicates).
#' @param k Size of incomplete blocks (number of unites per incomplete block). 
#' @param l Number of locations. By default \code{l = 1}.
#' @param plotNumber Numeric vector with the starting plot number for each location. By default \code{plotNumber = 101}.
#' @param seed (optional) Real number that specifies the starting seed to obtain reproducible designs.
#' @param locationNames (optional) Names for each location.
#' @param data (optional) Data frame with label list of treatments.
#' 
#' @importFrom stats runif na.omit
#'
#' @return A list with information on the design parameters.
#' @return Data frame with the rectangular lattice design field book.
#' 
#'
#' @references
#' Edmondson, R.N. 2020. Package blocksdesign: Nested and Crossed Block Designs for
#' Factorial and Unstructured Treatment Sets.
#' 
#' @examples
#' # Example 1: Generates a rectangular lattice design with 6 full blocks, 4 units per iblock (k)
#' # and 20 treatments in one location.
#' rectangularLattice1 <- rectangular_lattice(t = 20, k = 4, r = 6, l = 1, 
#'                                            plotNumber = 101,
#'                                            locationNames = "FARGO", 
#'                                            seed = 126)
#' rectangularLattice1$infoDesign
#' head(rectangularLattice1$fieldBook,12)
#' 
#' # Example 2: Generates a rectangular lattice design with 5 full blocks, 7 units per iblock (k)
#' # and 56 treatments across 3 locations.
#' rectangularLattice2 <- rectangular_lattice(t = 56, k = 7, r = 5, l = 3, 
#'                                            plotNumber = c(1001,2001,3001),
#'                                            locationNames = c("Loc1", "Loc2", "Loc3"), 
#'                                            seed = 127)
#' rectangularLattice2$infoDesign
#' head(rectangularLattice2$fieldBook,12)
#' 
#' @export
rectangular_lattice <- function(t = NULL, k = NULL, r = NULL, l = 1, plotNumber = 101, locationNames = NULL,
                                seed = NULL, data = NULL) {
  
  if (is.null(seed) || !is.numeric(seed)) seed <- runif(1, min = -50000, max = 50000)
  set.seed(seed)
  lookup <- FALSE
  if(is.null(data)) {
    if (is.null(t) || is.null(k) || is.null(r) || is.null(l)) {
      shiny::validate('Some of the basic design parameters are missing (t, k, r and l).')
    }
    arg1 <- list(k, r, l);arg2 <- c(k, r, l)
    if (base::any(lengths(arg1) != 1) || base::any(arg2 %% 1 != 0) || base::any(arg2 < 1)) {
      shiny::validate('incomplete_blocks() requires t, k, r and l to be possitive integers.')
    }
    if (is.numeric(t)) {
      if (length(t) == 1) {
        if (t == 1 || t < 1) {
          shiny::validate('incomplete_blocks() requires more than one treatment.')
        } 
        nt <- t
      }else if ((length(t) > 1)) {
        nt <- length(t)
        TRT <- t
      }
    }else if (is.character(t) || is.factor(t)) {
      if (length(t) == 1) {
        shiny::validate('incomplete_blocks() requires more than one treatment.')
      } 
      nt <- length(t)
    }else if ((length(t) > 1)) {
      nt <- length(t)
    }
    data_alpha <- NULL
  }else if (!is.null(data)) {
    if (is.null(r) || is.null(k) || is.null(l)) {
      shiny::validate('Some of the basic design parameters are missing (t, k, r).')
    }
    if(!is.data.frame(data)) shiny::validate("Data must be a data frame.")
    data <- as.data.frame(na.omit(data[,1]))
    colnames(data) <- "Treatment"
    data$Treatment <- as.character(data$Treatment)
    new_t <- length(data$Treatment)
    if (t != new_t) base::stop("Number of treatments do not match with data input.")
    TRT <- data$Treatment
    nt <- length(TRT)
    if (nt != t) shiny::validate('Number of treatment do not match with data input.')
    data_alpha <- data
  }
  s <- nt / k
  if (s %% 1 != 0 || k != (s - 1) || nt != s*(s - 1)) {
    shiny::validate('rectangular_lattice() requires t = s*(s-1), where s is the iBlock numbers per replicate.')
  } 
  if(is.null(locationNames) || length(locationNames) != l) locationNames <- 1:l
  nunits <- k
  matdf <- incomplete_blocks(t = nt, k = nunits, r = r, l = l, plotNumber = plotNumber,
                             seed = seed, locationNames = locationNames,
                             data = data_alpha)
  lambda <- r*(k - 1)/(nt - 1)
  matdf <- matdf$fieldBook
  OutRectagular_Lattice <- as.data.frame(matdf)
  OutRectagular_Lattice$LOCATION <- factor(OutRectagular_Lattice$LOCATION, levels = locationNames)
  rownames(OutRectagular_Lattice) <- 1:nrow(OutRectagular_Lattice)

  infoDesign <- list(Reps = r, iBlocks = s, NumberTreatments = nt, NumberLocations = l, 
                     Locations = locationNames, seed = seed, lambda = lambda)
  
  return(list(infoDesign = infoDesign, fieldBook = OutRectagular_Lattice))
}
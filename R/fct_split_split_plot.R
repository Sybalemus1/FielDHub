#' Generates a Split Split Plot Design
#'
#' @description It randomly generates a split split plot design (SSPD) across locations.
#'
#' @param wp Number of whole plots, as an integer or a vector.
#' @param sp Number of sub plots per whole plot, as an integer or a vector.
#' @param ssp Number of sub-sub plots, as an integer or a vector.
#' @param reps Number of blocks (full replicates).
#' @param type Option for CRD or RCBD designs. Values are \code{type = 1} (CRD) or \code{type = 2} (RCBD). By default \code{type = 2}.
#' @param l Number of locations. By default \code{l = 1}.
#' @param plotNumber Numeric vector with the starting plot number for each location. By default \code{plotNumber = 101}.
#' @param seed (optional) Real number that specifies the starting seed to obtain reproducible designs.
#' @param locationNames (optional) Names for each location.
#' @param data (optional) Data frame with label list of treatments.
#' 
#' 
#' @importFrom stats runif 
#'
#' @return A list with parameters information of design. 
#' @return Data frame with the split split plot field book.
#'
#'
#' @references
#' \emph{Design and Analysis of Experiments, Volume 1, Introduction to Experimental Design. Second Edition}.
#'  Klaus Hinkelmann & Oscar Kempthorne.John Wiley & Sons, Inc., Hoboken, New Jersey.
#'
#' @examples
#' # Example 1: Generates a split split plot design SSPD with 5 whole plots, 2 sub-plots,
#' # 3 sub-sub plots, and 3 reps in an RCBD arrangement. This is for one location.
#' SSPD1 <- split_split_plot(wp = 4, sp = 2, ssp = 3, reps = 5, l = 1, 
#'                           plotNumber = 101, 
#'                           seed = 23, 
#'                           type = 2, 
#'                           locationNames = "FARGO")
#' SSPD1$infoDesign
#' head(SSPD1$fieldBook,12)
#'
#' # Example 2: Generates a split split plot design SSPD with 2 whole plost 
#' # (Irrigation, No irrigation), 5 sub plots (4 types of fungicide + one control), and 
#' # 10 sub-sub plots (Ten varieties of beans), and 4 reps in an RCBD arrangement.
#' # This is for 3 locations.
#' wp <- paste("IRR_", c("NO", "Yes"), sep = "") #Irrigation (2 Whole plots)
#' sp <- c("NFung", paste("Fung", 1:4, sep = "")) #Fungicides (5 Sub plots)
#' ssp <- paste("Beans", 1:10, sep = "") #Beans varieties (10 Sub-sub plots)
#' SSPD2 <- split_split_plot(wp = wp, sp = sp, ssp = ssp, reps = 4, l = 3, 
#'                           plotNumber = c(101, 1001, 2001),
#'                           seed = 23, 
#'                           type = 2, 
#'                           locationNames = c("A", "B", "C"))
#' SSPD2$infoDesign
#' head(SSPD2$fieldBook,12)
#'              
#' @export
split_split_plot <- function(wp = NULL, sp = NULL, ssp = NULL, reps = NULL, type = 2, l = 1, plotNumber = 101, 
                             seed = NULL, locationNames = NULL, data = NULL) {

  if (is.null(seed) || !is.numeric(seed)) seed <- runif(1, min = -50000, max = 50000)
  set.seed(seed)
  if (all(c(1,2) != type)) {
    stop("Input type is unknown. Please, choose one: 1 or 2, for CRD or RCBD, respectively.")
  }
  b <- reps
  args0 <- c(wp, sp, ssp, reps, l)
  args1 <- list(wp, sp, ssp)
  if (any(lengths(list(reps,l)) >  1))  stop("Number of blocks and locations need to be integers.")
  if (any(c(reps, l) %% 1 != 0)) stop("Number of blocks and locations need to be integers.")
  if (is.null(data)) {
    if(all(!is.null(args0))) {
      if(all(is.numeric(args0)) && all(lengths(args1) == 1)) {
        WholePlots <- 1:wp
        SubPlots <- 1:sp
        SubSubPlots <- 1:ssp
      }else if(all(lengths(list(wp, sp, ssp)) > 1)){
        WholePlots <- wp
        wp <- length(WholePlots)
        SubPlots <- sp
        sp <- length(SubPlots)
        SubSubPlots <- ssp
        ssp <- length(SubSubPlots)
      }else if(is.character(wp) || is.numeric(wp)) {
        if (length(wp) > 1) {
          if (is.numeric(sp) && is.numeric(ssp)) {
            if (all(lengths(list(sp, ssp)) == 1)) {
              WholePlots <- wp
              wp <- length(WholePlots)
              SubPlots <- 1:sp
              SubSubPlots <- 1:ssp
            }else if (all(lengths(list(sp, ssp)) > 1)) {
              WholePlots <- wp
              wp <- length(WholePlots)
              SubPlots <- sp
              sp <- length(SubPlots)
              SubSubPlots <- ssp
              ssp <- length(SubSubPlots)
            }
          }else if (is.character(sp) && is.character(ssp)) {
            if (all(lengths(list(sp, ssp)) > 1)) {
              WholePlots <- wp
              wp <- length(WholePlots)
              SubPlots <- sp
              sp <- length(SubPlots)
              SubSubPlots <- ssp
              ssp <- length(SubSubPlots)
            }else {
              stop("The sub plots and sub sub plots should be more than one.")
            }
          }
        }else {
          stop("The whole plots should be more than one.")
        }
      }else {
        stop("Please, check your input variables.")
      }
    }else {
      stop("Input wp, sp, reps and l must be differents of NULL.")
    }
  }else {
    if(!is.data.frame(data)) stop("Data must be a data frame.")
    data <- as.data.frame(data[,1:3])
    colnames(data) <- c("WholePlot", "SubPlot", "SubSubPlot")
    WholePlots <- as.vector(na.omit(data$WholePlot))
    SubPlots <- as.vector(na.omit(data$SubPlot))
    SubSubPlots <- as.vector(na.omit(data$SubSubPlot))
    WholePlots.f <- factor(WholePlots, as.character(unique(WholePlots)))
    SubPlots.f <- factor(SubPlots, as.character(unique(SubPlots)))
    SubSubPlot.f <- factor(SubSubPlots, as.character(unique(SubSubPlots)))
    wp <- length(levels(WholePlots.f))
    sp <- length(levels(SubPlots.f))
    ssp <- length(levels(SubSubPlot.f))
    WholePlots <- as.character(WholePlots.f)
    SubPlots <- as.character(SubPlots.f)
    SubSubPlots <- as.character(SubSubPlot.f)
  }
  if (!is.null(plotNumber)) {
    if (any(!is.numeric(plotNumber)) || any(plotNumber < 1) || any(plotNumber %% 1 != 0) ||
        any(diff(plotNumber) < 0)) {
      shiny::validate("Input plotNumber must be an integer greater than 0 and sorted.")
    } 
  }else {
    plotNumber <- seq(1001, 1000*(l+1), 1000)
    warning("Since plotNumber was NULL, it was set up to its default value for each location.")
  }
  plot.number <- plotNumber
  if (!is.null(plot.number)) {
    if (any(plot.number < 1)) stop ("Plot numbers should be positive values.")
    if (any(plot.number %% 1 != 0)) stop ("Plot numbers should be integer values.")
    if (length(plot.number) == l) {
      plot.number <- plot.number[1:l]
      plot.random <- matrix(data = NA, nrow = wp * b, ncol = l)
      for (k in 1:l) {
        plots <- plot.number[k]:(plot.number[k] + (wp * b) - 1)
        plot.random[,k] <- replicate(1, sample(plots))
      }
    }else if (length(plot.number) < l) {
      plots <- plot.number[1]:(plot.number[1] + (wp * b) - 1)
      plot.random <- replicate(l, sample(plots))
      warning("Length of plot numbers is lessen than location numbers: only the first used.")
    }else if (length(plot.number) > l) {
      plot.number <- plot.number[1:l]
      plot.random <- matrix(data = NA, nrow = wp * b, ncol = l)
      for (k in 1:l) {
        plots <- plot.number[k]:(plot.number[k] + (wp * b) - 1)
        plot.random[,k] <- replicate(1, sample(plots))
      }
      warning("Length of plot numbers is greater than location numbers.")
    }
  }else {
    stop ("Please, input the plot number(s).")
  }
  if (type == 1) crd <- TRUE else crd <- FALSE
  if (crd) {
    loc.list <- vector(mode = "list", length = l)
    for (v in 1:l) {
      sspd.layout <- matrix(data = 0, nrow = wp * b, ncol = 5)
      sspd.layout[,1] <- plot.random[,v]
      sspd.layout[,2] <- rep(1:b, each = wp)
      sspd.layout[,3] <- rep(WholePlots, each = b)
      sspd.layout <- sspd.layout[order(sspd.layout[,1]),]
      rownames(sspd.layout) <- 1:(wp * b)
      colnames(sspd.layout) <- c("PLOT", "REP", "Whole-plot", "Sub-plot", "Sub-Sub Plot")
      loc.list[[v]] <- sspd.layout
    }
    sspd.layout <- paste_by_row(loc.list)
    plots.n <- as.numeric(sspd.layout[,1])
    wp.reps <- as.numeric(sspd.layout[,2])
    wp.random <- as.vector(sspd.layout[,3])
    type <- "CRD"
  }else {
    plot.numbers <- apply(plot.random,2, sort)
    wp.random <- replicate(b * l, sample(WholePlots, replace = FALSE))
    sspd.layout <- matrix(data = 0, nrow = (b * wp) * l, ncol = 5)
    colnames(sspd.layout) <- c("PLOT", "BLOCK", "Whole-plot", "Sub-plot", "Sub-Sub Plot")
    sspd.layout[,1] <- plot.numbers
    sspd.layout[,2] <- rep(1:b, each = wp)
    sspd.layout[,3] <- as.vector(wp.random)
    plots.n <- as.numeric(sspd.layout[,1])
    type <- "RCBD"
  } 
  
  sp.random <- replicate((b * wp) * l, sample(SubPlots, replace = FALSE))
  ssp.random <- replicate((b * wp * sp) * l, sample(SubSubPlots, replace = FALSE))
  k <- (b * wp) * l
  w <- seq(sp, (sp * wp * b) * l, sp)
  z <- 1
  for(i in 1:k) {
    sspd.layout[i,4] <- paste(sp.random[,i],  collapse = " ")
    sspd.layout[i,5] <- paste(ssp.random[,z:w[i]], collapse = " ")
    z <- z + sp
  }
  loc.spd.layout <- vector(mode = "list", length = l)
  y <- seq(1, k, b * wp)
  z <- seq(b * wp, k, b * wp)
  i <- 1;j <- 1
  for(sites in 1:l) {
    loc.spd.layout[[sites]] <- sspd.layout[y[i]:z[j],]
    i <- i + 1
    j <- j + 1
  }
  sspd.layout <- as.data.frame(sspd.layout)
  rownames(sspd.layout) <- 1:nrow(sspd.layout)
  wp.d <- rep(as.vector(wp.random), each = sp*ssp)
  sp.d <- rep(as.vector(sp.random), each = ssp)
  ssp.d <- as.vector(ssp.random)
  if (!is.null(locationNames) && length(locationNames) == l) {
    LOCATION <- rep(locationNames, each = (sp * wp * ssp) * b)
  }else if (is.null(locationNames) || length(locationNames) != l) {
    LOCATION <- rep(1:l, each = (sp * wp * ssp) * b)
  }
  if (crd) {
    PLOT <- rep(plots.n, each = sp * ssp)
    REPS <- rep(wp.reps, each = sp * ssp)
    sspd.output <- data.frame(list(LOCATION = LOCATION, PLOT = PLOT, REP = REPS,
                                   wp = wp.d, sp = sp.d, ssp = ssp.d, TREATMENT = NA))
    colnames(sspd.output) <- c("LOCATION", "PLOT", "REP", "WHOLE-PLOT", "SUB-PLOT", "SUB-SUB-PLOT", "TRT_COMB")
  }else {
    PLOT <- rep(plots.n, each = sp * ssp)
    Block <- rep(rep(1:b, each = wp * sp * ssp), times = l)
    sspd.output <- data.frame(list(LOCATION = LOCATION, PLOT = PLOT, Block = Block,
                                   wp = wp.d, sp = sp.d, ssp = ssp.d, TREATMENT = NA))
    colnames(sspd.output) <- c("LOCATION", "PLOT", "REP", "WHOLE-PLOT", "SUB-PLOT", "SUB-SUB-PLOT", "TRT_COMB")
  }
  z <- 1:nrow(sspd.output)
  for (j in z) {
    sspd.output[j, ncol(sspd.output)] <- paste(sspd.output[j, 4:6], collapse = "|")
  }
  
  info.design <- list(Whole.Plots = WholePlots, Sub.Plots = SubPlots, Sub.Sub.Plots = SubSubPlots,
                      Locations = l, type.design = type, seed = seed)
  # layoutlocations = loc.spd.layout,

  return(list(infoDesign = info.design, fieldBook = sspd.output))
}
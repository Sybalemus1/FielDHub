#' Generates a Latin Square Design 
#'
#' Randomly generates a latin square design of up 10 treatments. 
#'
#' @param t Number of treatments.
#' @param reps Number of full resolvable squares. By default \code{reps = 1}.
#' @param plotNumber Starting plot number. By default \code{plotNumber = 101}.
#' @param planter Option for \code{serpentine} or \code{cartesian} arrangement. By default \code{planter = 'serpentine'}.
#' @param seed (optional) Real number that specifies the starting seed to obtain reproducible designs.
#' @param locationNames Name for each location.
#' @param data optional) Data frame with label list of treatments.
#' 
#' @importFrom stats runif na.omit
#'
#' @return A list with information on the design parameters. 
#' @return Data frame with the latin square field book.
#' 
#'
#' @references
#' \emph{Design and Analysis of Experiments, Volume 1, Introduction to Experimental Design. Second Edition}.
#'  Klaus Hinkelmann & Oscar Kempthorne.John Wiley & Sons, Inc., Hoboken, New Jersey.
#'
#' @examples
#' # Example 1: Generates a latin square design with 5 treatments and 3 reps.
#' latinSq1 <- latin_square(t = 5, reps = 3, plotNumber = 101, planter = "serpentine",
#'                          seed = 1981, locationNames = "FARGO") 
#' latinSq1$squares
#' latinSq1$plotSquares
#' head(latinSq1$fieldBook)
#' 
#'              
#' @export
latin_square <- function(t = NULL, reps = 1, plotNumber = 101,  planter = "serpentine", 
                         seed = NULL, locationNames = NULL, data = NULL) {
  
  if (is.null(seed) || !is.numeric(seed)) seed <- runif(1, min = -50000, max = 50000)
  set.seed(seed)
  if (t > 10) stop("\n'latinsquare()' allows only up to 10 treatments.")
  if (all(c("serpentine", "cartesian") != planter)) {
    base::stop('Input planter is unknown. Please, choose one: "serpentine" or "cartesian"')
  }
  n <- t
  l <- 1
  if (is.null(data)) {
    if (all(!is.null(c(n, reps))) && all(base::lengths(list(n, reps)) == 1)) {
      if (all(is.numeric(c(n, reps))) && all(c(n, reps) %% 1 == 0) & all(c(n, reps) > 0)) {
        ls.len <- n
        Name.Rows <- paste(rep("Row", ls.len), 1:ls.len)
        Name.Columns <- paste(rep("Column", ls.len), 1:ls.len)
        Name.Treatments <- paste(rep("T", ls.len), 1:ls.len,  sep = "")
      }else stop("\n'latinsquare()' requires a possitive integer number for input t")
    }else stop("\n'latinsquare()' requires an possitive integer number for input t")
  }else if (!is.null(reps) && !is.null(data)) {
    if(!is.data.frame(data)) stop("Data must be a data frame.")
    data <- as.data.frame(na.omit(data[,1:3]))
    colnames(data) <- c("Row", "Column", "Treatment")
    Row <- as.vector(na.omit(data$Row))
    Column <- as.vector(na.omit(data$Column))
    Treatment <- as.vector(na.omit(data$Treatment))
    Row.f <- factor(Row, as.character(unique(Row)))
    Column.f <- factor(Column, as.character(unique(Column)))
    Treatment.f <- factor(Treatment, as.character(unique(Treatment)))
    n.rows <- length(levels(Row.f))
    n.cols <- length(levels(Column.f))
    n.treatments <- length(levels(Treatment.f))
    if (any(c(n.rows, n.cols, n.treatments) != n.rows)) stop("\n'latinsquare()' requires a balanced data as input!")
    Name.Rows <- as.character(Row.f)
    Name.Columns <- as.character(Column.f)
    Name.Treatments <- as.character(Treatment.f)
    ls.len <- n.treatments
  }
  
  if(!is.null(l) && is.numeric(l) && length(l) == 1) {
    if (l > 1 && is.null(locationNames)) {
      locationNames <- 1:l
    }else if (l > 1 && !is.null(locationNames)) {
      if (length(locationNames) < l) locationNames <- 1:l
    }
    if (length(plotNumber) < l || is.null(plotNumber)) plotNumber <- seq(1001, 1000*(l+1), 1000)
  }else stop("\n'latinsquare()' requires a integer for number of locations!")
  plot.numbs <- seriePlot.numbers(plot.number = plotNumber, reps = reps, l = l)
  if (!is.null(locationNames) && length(locationNames) == l) {
    locs <- locationNames
  }else locs <- 1:l
  step.random <- vector(mode = "list", length = reps)
  lsd.reps <- vector(mode = "list", length = reps)
  out.ls <- vector(mode = "list", length = reps)
  #lsd.out.l <- vector(mode = "list", length = l)
  plotSquares <- vector(mode = "list", length = reps)
  #z <- 1
  x <- seq(1, reps * l, reps)
  y <- seq(reps, reps * l, reps)
  for (j in 1:reps) {
    D <- plot.numbs[[l]]
    P <- matrix(data = D[j]:(D[j] + (ls.len*ls.len) - 1), nrow = ls.len, ncol = ls.len, 
                byrow = TRUE)
    if(planter == "serpentine") P <- serpentinelayout(P, opt = 2)
    plotSquares[[j]] <- P
    ls.random <- lsq(len = ls.len, reps = 1, seed = NA)
    #get random rows order
    ls.random.r <- ls.random
    row.random <- sample(1:ls.len)
    ls.random.r[,] <- ls.random.r[row.random,]
    rownames(ls.random.r) <- Name.Rows[row.random]
    ls.random.c <- ls.random.r
    #get random columns order
    col.random <- sample(1:ls.len)
    ls.random.c[,] <- ls.random.c[,col.random]
    colnames(ls.random.c) <- Name.Columns[col.random]
    expt.ls <- ls.random.c
    #randomize treatments to the letters
    trt <- Name.Treatments
    trt.r <- sample(trt)
    trt.random <- matrix(c(LETTERS[1:ls.len], trt.r), nrow = 2, ncol = ls.len, byrow = TRUE)
    w <- 1
    for (i in LETTERS[1:ls.len]) {
      expt.ls[expt.ls == i] <- trt.r[w]
      w <- w + 1
    }
    new_expt.ls <- order_ls(S = expt.ls)
    lsd.reps[[j]] <- new_expt.ls
    step.random[[j]] <- list(ls.random, ls.random.r, ls.random.c)
    Row <- rep(rownames(lsd.reps[[j]]), each = ls.len)
    Column <- rep(colnames(lsd.reps[[j]]), times = ls.len)
    out.ls[[j]] <- data.frame(list(LOCATION = locs[l],
                                   PLOT = as.vector(t(P)),
                                   SQUARE = j,
                                   ROW = Row,
                                   COLUMN = Column,
                                   TREATMENT = as.vector(t(new_expt.ls))))
  }
  #for (sites in 1:l) {
    #lsd.out.l[[sites]] <- paste_by_row(out.ls[x[sites]:y[sites]])
  #}
  expt.ls <- paste_by_row(lsd.reps)
  latinsquare.expt <- paste_by_row(out.ls)
  #latinsquare.expt.Loc <- paste_by_row(lsd.out.l)
  #ls.output.Loc <- latinsquare.expt.Loc
  # ls.output.Loc$ROW <- factor(ls.output.Loc$ROW, levels = Name.Rows)
  # ls.output.Loc$COLUMN <- factor(ls.output.Loc$COLUMN, levels = Name.Columns)
  # ls.output.Loc.order <- ls.output.Loc[order(ls.output.Loc$SQUARE, ls.output.Loc$ROW, ls.output.Loc$COLUMN), ]
  ls.output <- latinsquare.expt
  ls.output$ROW <- factor(ls.output$ROW, levels = Name.Rows)
  ls.output$COLUMN <- factor(ls.output$COLUMN, levels = Name.Columns)
  ls.output.order <- ls.output[order(ls.output$PLOT, ls.output$SQUARE, ls.output$ROW), ]
  if (!is.null(locationNames) && length(locationNames) == l) {
    ls.output.order$LOCATION <- rep(locationNames, each = (ls.len * ls.len) * reps)
  }
  rownames(ls.output.order) <- 1:nrow(ls.output.order)
  return(list(squares = lsd.reps, plotSquares = plotSquares, fieldBook = ls.output.order))
}
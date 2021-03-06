#' @importFrom stats dist
pREP <- function(nrows = NULL, ncols = NULL, RepChecks = NULL, checks = NULL, Fillers = NULL,
                 seed = NULL, optim = TRUE, niter = 1000, data = NULL) {
  
  gen.list <- data
  
  if (!is.null(gen.list)) {
    
    gen.list <- as.data.frame(gen.list)
    gen.list <- na.omit(gen.list[,1:3])
    colnames(gen.list) <- c("ENTRY", "NAME", "REPS")
    gen.list.O <- gen.list[order(gen.list$REPS, decreasing = TRUE), ]
    my_REPS <- subset(gen.list.O, REPS > 1)
    my_REPS <- my_REPS[order(my_REPS$REPS, decreasing = TRUE),]
    my_GENS <- subset(gen.list.O, REPS == 1)
    reps.checks <- as.vector(my_REPS[,3])
    
  }else {
    lines <- nrows*ncols - sum(RepChecks)
    checksEntries <- checks
    checks <- length(checksEntries)
    NAME <- c(paste(rep("Check", checks), 1:checks),
              paste(rep("gen", lines), (checksEntries[checks] + 1):(checksEntries[1] + lines + checks - 1)))
    reps.checks <- RepChecks
    REPS <- c(reps.checks, rep(1, lines))
    gen.list <- data.frame(list(ENTRY = checksEntries[1]:(checksEntries[1] + lines + checks - 1),	NAME = NAME,	REPS = REPS))
    gen.list.O <- gen.list[order(gen.list$REPS, decreasing = TRUE), ]
    my_REPS <- subset(gen.list.O, REPS > 1)
    my_GENS <- subset(gen.list.O, REPS == 1)
    
  }
  
  ######################some review on the data entry#####################################
  #my_REPS <- subset(gen.list.O, REPS > 1)
  freq_reps <- table(my_REPS[,3])
  nREPS <- as.vector(as.numeric((names(freq_reps))))
  total.checks <- sum(freq_reps * nREPS)
  
  frequency_reps <- table(gen.list.O[,3])
  
  A <- as.vector(as.numeric((names(frequency_reps))))
  
  my_input <- frequency_reps * A
  
  if (sum(my_input) != nrows*ncols) {
    
    shiny::validate("Your data input does not fit into the field dimensions provided.")
    
  }
  
  ########## Setting up the features of the experiment###########################
  set.seed(seed)
  
  datos <- sample(c(rep(0, nrows*ncols - total.checks),
                    rep(1, total.checks)))
  ######### Building the binary Matrix ##########################################
  field0 <- matrix(data = sample(datos), nrow = nrows, ncol = ncols, byrow = FALSE)
  ################## Get optim the design usin a metric distance#################
  
  if (optim) {
    
    m1 <- as.vector(field0)
    dist_field0 <- sum(dist(field0))
    
    designs <- vector(mode = "list", length = niter)
    dists <- vector(mode = "numeric", length = niter)
    designs[[1]] <- field0
    dists[1] <- dist_field0
    
    for(i in 2:niter){
      
      m <- as.vector(designs[[i-1]])
      k1 <- which(m == 1);k2 <- which(m == 0)
      
      D <- vector(length = 2)
      
      D[1] <- sample(k1, 1, replace = FALSE)
      D[2] <- sample(k2, 1, replace = FALSE)
      
      m1 <- replace(m, D, m[rev(D)])
      
      iter_designs <- matrix(m1, nrow = nrows, ncol = ncols, byrow = FALSE)
      
      iter_dist <- sum(dist(iter_designs))
      
      if(iter_dist > dists[i - 1]){
        
        designs[[i]] <- iter_designs
        
        dists[i] <- iter_dist
        
      }else {
        
        designs[[i]] <- designs[[i - 1]]
        
        dists[i] <- dists[i-1]
        
      }
      
    }
    
    #p.plot <- plot(1:length(dists), dists, col = "blue", xlab = "Iterations", 
    #               ylab = "Euclidean Distance")
    
    ###################################
    field <- designs[[niter]]          # This is one of the "best designs" according to the euclidean distance.
    ###################################
    
    
  }else field <- field0
  
  binary_field <- field
  
  ################## Setting up the samples for the entries genotypes#############
  entry.gens <- as.vector(my_GENS[,1])
  entry.checks <- as.vector(my_REPS[,1])
  
  layout <- field
  ch <- nrow(my_REPS)
  trt.reps <- paste(rep("CH", ch), 1:ch, sep = "")
  #target.checks <- sample(rep(trt.reps, times = reps.checks))
  target.checks <- rep(trt.reps, times = reps.checks)
  layout[layout == 1] <- sample(target.checks)
  #target.checklevels <- levels(factor(target.checks))
  target.checklevels <- levels(factor(target.checks, unique(as.character(target.checks))))
  
  ########## randomize checks to the letters #################################
  trt <- entry.checks
  #trt.r <- sample(trt)
  trt.r <- trt  
  trt.random <- matrix(c(trt.reps, trt.r), nrow = 2, ncol = ch, byrow = TRUE)
  l <- 1
  layout1 <- layout
  for (i in target.checklevels){
    
    layout1[layout1 == i] <- trt.r[l]
    
    l <- l + 1
    
  }
  entries <- list(entry.checks = entry.checks, entry.gens = entry.gens)
  
  layout1[layout1 == 0] <- sample(entry.gens)
  ###################################################
  
  layout <- apply(layout1, c(1,2), as.numeric)
  
  return(list(field.map = layout, gen.entries = entries, gen.list = gen.list, reps.checks = reps.checks,
              entryChecks = entry.checks, binary.field = binary_field))
  
}
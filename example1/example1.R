# Example 1

x <- faithful$waiting

numbins <- 22

bins <- seq(min(x), max(x), length.out = numbins + 1)

hist(x, breaks = bins, col = "#75AADB", border = "white",
     xlab = "Waiting time to next eruption (in mins)",
     main = "Histogram of waiting times")

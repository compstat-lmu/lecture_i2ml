# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)
library(tidyverse)
library(data.table)
library(gridExtra)

options(digits = 3, 
        width = 65, 
        str = strOptions(strict.width = "cut", vec.len = 3))

# HELPERS ----------------------------------------------------------------------

make_line = function(x, a, b) a * x + b

make_line_plot = function(intercept, slope)  {
  
  # Base
  
  p = ggplot(data.frame(x = c(0, 5)), aes(x)) +
    theme_bw()
  
  # Line
  
  p = p + stat_function(
    fun = make_line, 
    args = list(a = slope, b = intercept))
  
  # Marker for intercept
  
  p = p + geom_point(
    data = data.frame(x = 0, y = intercept), 
    aes(x = x, y = y),
    color = "orange",
    size = 4)
  
  p = p + annotate(
    "text",
    x = 0.8,
    y = intercept + 0.3,
    label = expr(paste(theta[0], " = ", !!intercept)),
    size = 4,
    color = "orange")
  
  # Marker for slope
  
  triangle = data.table(
    group = c(1, 1, 1), 
    x = c(1, 2, 2), 
    y = c(intercept + slope, intercept + slope, intercept + 2 * slope))
  
  p = p + geom_polygon(
    triangle, 
    mapping = aes(x = x, y = y, group = group),
    fill = "blue",
    alpha = 0.2)
  
  p = p + annotate(
    "text",
    x = 3,
    y = ifelse(slope < 0, intercept + slope - 0.3, intercept + slope + 0.3),
    label = expr(paste(theta[1], " = ", !!slope)),
    size = 4,
    color = "blue"
  )
  
  # Labs
  
  p = p + labs(
    title = ifelse(
      slope == 0,
      sprintf("f(x) = %.0f", intercept),
      sprintf("f(x) = %.1fx + %.0f", slope, intercept)
    ),
    y = "f(x)"
  )

  p = p + ylim(0, 5)
  p

}

# PLOT -------------------------------------------------------------------------

pdf("../figure/hs-lin-functions.pdf", width = 8, height = 4)

p_1 = make_line_plot(1, 1.8)
p_2 = make_line_plot(2, 0)
p_3 = make_line_plot(3, -0.5)
grid.arrange(p_1, p_2, p_3, ncol = 3)

ggsave("../figure/hs-lin-functions.pdf", width = 8, height = 4)
dev.off()
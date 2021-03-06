# PREREQ -----------------------------------------------------------------------

library(knitr)
library(ggplot2)

# DATA -------------------------------------------------------------------------

set.seed(pi)

x = 1:5
y = x + rnorm(5, 0, 2)
m = lm(y ~ x)

coef1 <- c(1.8, .3)
coef2 <- c(1, .1)
coef3 <- c(0.5, .8)

# FUNCTIONS --------------------------------------------------------------------

colBlue = function(alpha) { rgb(135, 206, 255, alpha, maxColorValue = 255) }
colOrange = function(alpha) { rgb(255, 185,  15, alpha, maxColorValue = 255) }
colRed = function(alpha) { rgb(255, 15,  15, alpha, maxColorValue = 255) }
colGreen = function(alpha) { rgb(188, 238, 104, alpha, maxColorValue = 255) }

data_plot = function(x, y) {
  
  plot(x, 
       y, 
       ylim = c(-2, 6), 
       xlim = c(0, 8), 
       cex = 2, 
       pch = 4, 
       las = 1, 
       ann = "false")
  
  grid()
  
}

add_lm = function(coef, color, coef_label) {
  
  abline(coef = coef, col = color(255), lwd = 3)
  coef <- round(coef, 1)
  
  text(x = coef_label[1], 
       y = coef_label[2], 
       labels = bquote(theta == "("~.(coef[1])~","~.(coef[2])~")"),
       col = color(255))
  
}

add_errors = function(x, y, coef, color, sse_label) {
  
  hat_y = cbind(1, x) %*% coef
  w = abs(y - hat_y)
  
  rect(xleft = x, 
       ybottom = y, 
       xright = x + w, 
       ytop = hat_y, 
       col = color(90),
       border = color(120), 
       lwd = 2)
  
  text(x = sse_label[1], 
       y = sse_label[2], 
       labels = paste0("SSE: ", sum(round(w^2, 2))),
       col = color(255))
  
  points(x, y, cex = 2, pch = 4, lwd = 2)
  
}

frame_plot = function(x, y, coef, color, coef_label, sse_label) {
  
  data_plot(x, y)
  add_lm(coef, color, coef_label)
  add_errors(x, y, coef, color, sse_label)
  
}

sse = function(c1, c2, x, y) {
  
  hat_y = cbind(1, x) %*% c(c1, c2)
  w = abs(y - hat_y)
  sum(w^2)
  
}

sae = function(c1, c2, x, y) {
  
  hat_y = cbind(1, x) %*% c(c1, c2)
  w = abs(y - hat_y)
  sum(w)
  
}

surface_plot = function (z = sse_surf,
                         error_type = "SSE", 
                         title = NULL,
                         palette = clrs_ramp[clrs],
                         ...) {
  
  persp(x = c1_grid, 
        y = c2_grid,
        z = z,
        theta = -130,
        phi = 10, 
        ticktype = "detailed", 
        xlab = "Intercept", 
        ylab = "Slope", 
        zlab = error_type, 
        main = title,
        col = palette, 
        border = rgb(0, 0, 0,.5))
  
}

rect_plots = function(number) {

  frame_plot(x, y, coef1, colBlue, c(2, 5.5), c(x = 6.5, y = -0.5))
  
  if(number > 1) {
    
    frame_plot(x, y, coef2, colOrange, c(2, 5.5), c(x = 6.5, y = -0.5))
    
    if(number > 2) {
      
      frame_plot(x, y, coef3, colRed, c(2, 5.5), c(x = 6.5, y =  -0.5))
      
      if (number > 3) {
        
        frame_plot(x, y, coef(m), colGreen, c(2, 5.5), c(x = 6.5, y =  -0.5))
        
      }
      
    }
    
  }
  
}

# PLOT SETUP -------------------------------------------------------------------

gridlength <- 30
c1_grid = seq(-2, 2, l = gridlength)
c2_grid = seq(0, 1.5, l = gridlength)

sse_surf = outer(c1_grid, c2_grid, Vectorize(sse, c("c1", "c2")), x = x, y = y)
sae_surf = outer(c1_grid, c2_grid, Vectorize(sae, c("c1", "c2")), x = x, y = y)

clrs_ramp = scales::alpha(colorRampPalette(viridisLite::plasma(5))(200), .5)

clrs = sse_surf[-1, -1] + sse_surf[-1, -gridlength] + 
  sse_surf[-gridlength, -1] + sse_surf[-gridlength, -gridlength]

clrs = cut(clrs, length(clrs_ramp))

clrs_sae = sae_surf[-1, -1] + sae_surf[-1, -gridlength] + 
  sae_surf[-gridlength, -1] + sae_surf[-gridlength, -gridlength]

clrs_sae = cut(clrs_sae, length(clrs_ramp))

sse_blank = quote(persp(x = c1_grid, 
                        y = c2_grid, 
                        sse_surf * NA, 
                        theta = -130, 
                        phi = 10, 
                        zlim = range(sse_surf),
                        ticktype = "detailed", 
                        xlab = "Intercept", 
                        ylab = "Slope", 
                        zlab = "SSE", 
                        col = "white", 
                        border = rgb(1, 1, 1, 0)))

opar <- par(no.readonly = FALSE)
par(mar = opar$mar / 2)

# PLOT 1 -----------------------------------------------------------------------

pdf("../figure/reg_lm_plot_31.pdf", height = 3)

par(mfrow = c(1, 3))
rect_plots(1)
#par(opar)

ggsave("../figure/reg_lm_plot_31.pdf", width = 4, height = 3)
dev.off()

# PLOT 2 -----------------------------------------------------------------------

pdf("../figure/reg_lm_plot_32.pdf", height = 3)

par(mfrow = c(1, 3))
rect_plots(2)
#par(opar)

ggsave("../figure/reg_lm_plot_32.pdf", width = 4, height = 3)
dev.off()

# PLOT 3 -----------------------------------------------------------------------

pdf("../figure/reg_lm_plot_33.pdf", height = 3)

par(mfrow = c(1, 3))
rect_plots(3)

#par(opar)

ggsave("../figure/reg_lm_plot_33.pdf", width = 4, height = 3)
dev.off()

# PLOT 4 -----------------------------------------------------------------------

pdf("../figure/reg_lm_plot_34.pdf", width = 9, height = 4)

layout(cbind(c(1, 2), c(3, 0), c(4, 4), c(4, 4)))

rect_plots(3)

p = eval(sse_blank)

points(trans3d(x = cbind(coef1, coef2, coef3)[1, ], 
               y = cbind(coef1, coef2, coef3)[2, ], 
               z = rep(min(sse_surf), 3),
               pmat = p), 
       col = c(colBlue(255), colOrange(255), colRed(255)), 
       pch = 16, 
       cex = 2)

lines(trans3d(x = cbind(coef1, coef1)[1, ], 
              y = cbind(coef1, coef1)[2, ], 
              z = c(min(sse_surf), sse(coef1[1], coef1[2], x, y)),
              pmat = p))

lines(trans3d(x = cbind(coef2, coef2)[1, ], 
              y = cbind(coef2, coef2)[2, ], 
              z = c(min(sse_surf), sse(coef2[1], coef2[2], x, y)),
              pmat = p))

lines(trans3d(x = cbind(coef3, coef3)[1, ], 
              y = cbind(coef3, coef3)[2, ], 
              z = c(min(sse_surf), sse(coef3[1], coef3[2], x, y)),
              pmat = p))

points_3d = trans3d(x = cbind(coef1, coef2, coef3)[1, ], 
                    y = cbind(coef1, coef2, coef3)[2, ], 
                    z = c(sse(coef1[1], coef1[2], x, y), 
                          sse(coef2[1], coef2[2], x, y), 
                          sse(coef3[1], coef3[2], x, y)),
                    pmat = p)

points(points_3d, 
       col = c(colBlue(255), colOrange(255), colRed(255)), 
       pch = 16, 
       cex = 2)

points(points_3d, col = "black", pch = 1, cex = 2, lwd = 2)
#par(opar)

ggsave("../figure/reg_lm_plot_34.pdf", width = 9, height = 6)
dev.off()

# PLOT 5 -----------------------------------------------------------------------

pdf("../figure/reg_lm_plot_35.pdf", width = 4.5, height = 5.5)

par(mfrow = c(1, 1))
surface_plot(zlim = range(sse_surf))

ggsave("../figure/reg_lm_plot_35.pdf", width = 4, height = 0.66)
dev.off()

# PLOT 6 -----------------------------------------------------------------------

pdf("../figure/reg_lm_plot_36.pdf", width = 4.5, height = 5.5)

p = surface_plot(zlim = range(sse_surf))

points_3d = 
  trans3d(x = coef(m)[1], 
          y = coef(m)[2], 
          z = sse(coef(m)[1], coef(m)[2], x, y),
          pmat = p)

points(points_3d, 
       col = c(colGreen(255)), 
       pch = 16, 
       cex = 2)

points(points_3d, col = "black", pch = 1, cex = 2, lwd = 2)

ggsave("../figure/reg_lm_plot_36.pdf", width = 4, height = 0.66)
dev.off()

# PLOT 7 -----------------------------------------------------------------------

pdf("../figure/reg_lm_plot_37.pdf", width = 9, height = 4)

layout(cbind(c(1, 2), c(3, 4), c(5, 5), c(5, 5)))

rect_plots(4)

p = surface_plot(zlim = range(sse_surf))

points_3d = 
  trans3d(x = cbind(coef1, coef2, coef3, coef(m))[1, ], 
          y = cbind(coef1, coef2, coef3, coef(m))[2, ], 
          z = c(sse(coef1[1], coef1[2], x, y), 
                sse(coef2[1], coef2[2], x, y), 
                sse(coef3[1], coef3[2], x, y), 
                sse(coef(m)[1], coef(m)[2], x, y)),
          pmat = p)

points(points_3d,
       col = c(colBlue(255), 
               colOrange(255), 
               colRed(255), 
               colGreen(255)), 
       pch = 16, cex = 2)

points(points_3d, col = "black", pch = 1, cex = 2, lwd = 2)

ggsave("../figure/reg_lm_plot_37.pdf", width = 9, height = 4)
dev.off()

# PLOT 8 -----------------------------------------------------------------------

pdf("../figure/../figure/reg_lm_plot_38.pdf", width = 11, height = 6)

layout(t(c(1, 2)))

p = surface_plot(z = sae_surf,
                 error_type = "Sum of Absolute Errors",
                 title = "L1 Loss Surface",
                 palette = clrs_ramp[clrs_sae])

sae_min = which(sae_surf == min(sae_surf), arr.ind = TRUE)

sae_sol <- trans3d(x = c1_grid[sae_min[1]], 
                   y = c2_grid[sae_min[2]], 
                   z =  min(sae_surf),
                   pmat = p)

points(sae_sol, col = "darkgreen", pch = 16, cex = 2)
points(sae_sol, col = "black", pch = 1, cex = 2, lwd = 2)

p2 = surface_plot(title = "L2 Loss Surface", zlim = range(sse_surf))

points_3d = 
  trans3d(x = coef(m)[1], 
          y = coef(m)[2], 
          z = sse(coef(m)[1], coef(m)[2], x, y),
          pmat = p2)

points(points_3d, col = c(colGreen(255)), pch = 16, cex = 2)
points(points_3d, col = "black", pch = 1, cex = 2, lwd = 2)

ggsave("../figure/../figure/reg_lm_plot_38.pdf", width= 11, height = 6)
dev.off()

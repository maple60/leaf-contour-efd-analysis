pca_plot <- function(x, ...) {
  plt <- plot_PCA(
    x,
    f = ~species,
    palette = my_palette,
    points = FALSE,
    morphospace = FALSE,
    morphospace_position = "range",
    chull = TRUE, # convex hull
    #chullfilled = TRUE,
    zoom = 1,
    eigen = FALSE,
    box = FALSE,
    axesnames = FALSE,
    axesvar = FALSE,
    ...
  )
  plt <- layer_axes(plt, col = "black", lwd = 1)
  plt <- layer_ticks(plt, col = "black", lwd = 1)
  plt <- layer_points(plt, pch = 19, cex = 1, transp = 0.5)
  plt <- layer_morphospace_PCA(plt, size = 1, col = "black")
  plt <- layer_axesnames(plt, cex = 1.5, name = "PC") # add axes names
  plt <- layer_axesvar(plt, cex = 1.5) # add axes variance
}

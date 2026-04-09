pca_plot <- function(x, group = "species", palette = NULL, ...) {
  fac_names <- names(x$fac)
  has_group <- !is.null(fac_names) && group %in% fac_names
  grouping_formula <- if (has_group) stats::reformulate(group) else NULL

  if (is.null(palette)) {
    palette <- if (has_group && exists("my_palette", inherits = TRUE)) {
      get("my_palette", inherits = TRUE)
    } else {
      "grey30"
    }
  }

  plt <- plot_PCA(
    x,
    f = grouping_formula,
    palette = palette,
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

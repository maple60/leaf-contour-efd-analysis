#' Rotate points around an arbitrary origin
#'
#' Rotates 2D coordinates by a specified angle around a given origin.
#'
#' @param df A two-column object (x, y) coercible by `[ , 1:2 ]` indexing.
#' @param angle_deg Rotation angle in degrees (counter-clockwise).
#' @param origin Numeric vector of length 2 specifying rotation origin.
#'
#' @return Data frame with rotated `x` and `y` columns.
#'
#' @sideeffects None.
rotate_xy <- function(df, angle_deg, origin = c(0, 0)) {
  theta <- angle_deg * pi / 180

  x <- df[, 1] - origin[1]
  y <- df[, 2] - origin[2]

  x_new <- x * cos(theta) - y * sin(theta)
  y_new <- x * sin(theta) + y * cos(theta)

  data.frame(x = x_new + origin[1], y = y_new + origin[2])
}

#' Rotate points around their centroid
#'
#' Computes centroid from the first two columns and rotates each point
#' around that centroid by the provided angle.
#'
#' @param df A two-column object (x, y) coercible by `[ , 1:2 ]` indexing.
#' @param angle_deg Rotation angle in degrees (counter-clockwise).
#'
#' @return Data frame with rotated `x` and `y` columns.
#'
#' @sideeffects None.
rotate_xy_centered <- function(df, angle_deg) {
  origin <- c(mean(df[, 1]), mean(df[, 2]))
  rotate_xy(df, angle_deg, origin)
}

#' Rotate rows with per-row custom origins and angles
#'
#' Applies `rotate_xy()` row-wise, using the matching angle and origin for
#' each row.
#'
#' @param df A two-column object where each row is a point.
#' @param angle_deg Numeric vector of angles in degrees, one per row.
#' @param origins List of origin vectors (`c(x, y)`), one per row.
#'
#' @return Data frame of rotated points bound by row order.
#'
#' @sideeffects None.
rotate_xy_custom_origin <- function(df, angle_deg, origins) {
  l <- lapply(seq_along(origins), function(i) {
    rotate_xy(df[i, ], angle_deg[i], origins[[i]])
  })
  do.call(rbind, l)
}

compare_contour_oriented_true_EFD_normalization <- function(
  original,
  ef_normalized,
  label = NULL,
  nb.h = 35,
  mar = c(0, 0, 0, 0),
  cex.text = 2,
  ...
) {
  # Function to compute E* from first-harmonic EFD coefficients
  compute_E_star <- function(ef) {
    A1 <- ef$an[1]
    B1 <- ef$bn[1]
    C1 <- ef$cn[1]
    D1 <- ef$dn[1]
    # Calculate theta
    theta <- 0.5 *
      atan2(
        2 * (A1 * B1 + C1 * D1),
        (A1^2 + C1^2 - B1^2 - D1^2)
      )

    # Calculate a* and c*
    a_star <- A1 * cos(theta) + B1 * sin(theta)
    c_star <- C1 * cos(theta) + D1 * sin(theta)

    # Scale factor (E*)
    E_star <- sqrt(a_star^2 + c_star^2)
    return(E_star)
  }

  center <- coo_centpos(original) # center position
  original_centered <- sweep(original, 2, center, "-") # center the contour
  ef <- efourier(
    original_centered,
    nb.h = nb.h,
    norm = FALSE
  )
  E <- compute_E_star(ef)
  true_ef_coef <- list(
    ao = unique(ef_normalized$ao),
    co = unique(ef_normalized$co),
    an = ef_normalized$an,
    bn = ef_normalized$bn,
    cn = ef_normalized$cn,
    dn = ef_normalized$dn
  )
  # Reconstruct contour from true EFD coefficients
  reconstruct <- efourier_i(true_ef_coef, nb.h = nb.h)
  df_reconstruct <- as.data.frame(reconstruct)
  df_reconstruct <- df_reconstruct * E
  xlim <- range(c(df_reconstruct$x, original_centered[, 1]))
  ylim <- range(c(df_reconstruct$y, original_centered[, 2]))
  par(mar = mar)
  # original centered contour
  plot(
    original_centered,
    type = "l",
    asp = 1,
    col = adjustcolor("black", red = 0.7, green = 0.7, blue = 0.7),
    xlim = xlim,
    ylim = ylim,
    bty = "n",
    xaxt = "n",
    yaxt = "n",
    xlab = "",
    ylab = "",
    ...
  )

  # reconstructed contour
  lines(
    df_reconstruct,
    asp = 1,
    col = adjustcolor("#FF4B00", alpha.f = 0.9),
    ...
  )

  # label
  if (!is.null(label)) {
    text(
      x = mean(par("usr")[1:2]),
      y = mean(par("usr")[3:4]),
      labels = label,
      cex = cex.text,
      col = "black"
    )
  }
}

compare_contour_true_EFD_normalization <- function(
  original,
  label = NULL,
  nb.h = 35,
  mar = c(0, 0, 0, 0),
  cex.text = 2,
  ...
) {
  center <- coo_centpos(original) # center position
  original_centered <- sweep(original, 2, center, "-") # center the contour

  ef <- efourier(
    original_centered,
    nb.h = nb.h,
    norm = FALSE
  )
  true_ef <- true_normalize(ef, output_meta = TRUE)
  true_ef_coef <- true_ef$ef
  true_ef_coef <- list(
    ao = unique(true_ef_coef$ao),
    co = unique(true_ef_coef$co),
    an = true_ef_coef$an,
    bn = true_ef_coef$bn,
    cn = true_ef_coef$cn,
    dn = true_ef_coef$dn
  )
  # Reconstruct contour from true EFD coefficients
  reconstruct <- efourier_i(true_ef_coef, nb.h = nb.h)
  df_reconstruct <- as.data.frame(reconstruct)
  df_reconstruct <- df_reconstruct * true_ef$E

  xlim <- range(c(df_reconstruct$x, original_centered[, 1]))

  par(mar = mar)
  # original centered contour
  plot(
    original_centered,
    type = "l",
    asp = 1,
    col = adjustcolor("black", red = 0.7, green = 0.7, blue = 0.7),
    xlim = xlim,
    bty = "n",
    xaxt = "n",
    yaxt = "n",
    xlab = "",
    ylab = "",
    ...
  )

  # reconstructed contour
  lines(
    df_reconstruct,
    asp = 1,
    col = adjustcolor("#FF4B00", alpha.f = 0.9),
    ...
  )
  if (!is.null(label)) {
    text(
      x = mean(par("usr")[1:2]),
      y = mean(par("usr")[3:4]),
      labels = label,
      cex = cex.text,
      col = "black"
    )
  }
}

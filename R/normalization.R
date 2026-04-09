#' True-normalize a single EFD coefficient set
#'
#' Normalizes EFD coefficients by removing translation (DC terms),
#' enforcing a stable orientation, normalizing scale, and optionally
#' applying symmetry constraints on higher harmonics.
#'
#' @param ef A list with numeric vectors `an`, `bn`, `cn`, and `dn`.
#'   Optional `ao`/`co` fields are set to zero when present.
#' @param EPS Numeric tolerance used for degeneracy checks.
#' @param y_sy Logical; whether to enforce y-axis symmetry convention.
#' @param x_sy Logical; whether to enforce x-axis symmetry convention.
#' @param output_meta Logical; if `TRUE`, return normalization metadata.
#' @param skip_rotation Logical; if `TRUE`, skip orientation normalization.
#'
#' @return Either the normalized coefficient list (`output_meta = FALSE`)
#'   or a list containing normalized coefficients and metadata (`output_meta = TRUE`).
#'
#' @sideeffects Emits warnings for missing DC terms or degenerate first harmonics.
true_normalize <- function(
  ef,
  EPS = 1e-10,
  y_sy = TRUE,
  x_sy = TRUE,
  output_meta = FALSE,
  skip_rotation = FALSE
) {
  stopifnot(!is.null(ef$an), !is.null(ef$bn), !is.null(ef$cn), !is.null(ef$dn))

  names(ef) <- gsub("^A0$", "ao", names(ef), ignore.case = TRUE)
  names(ef) <- gsub("^C0$", "co", names(ef), ignore.case = TRUE)

  if ("ao" %in% names(ef)) {
    ef$ao <- 0
  } else {
    warning("ao is not found.")
  }
  if ("co" %in% names(ef)) {
    ef$co <- 0
  } else {
    warning("co is not found.")
  }

  a1 <- ef$an[1]
  b1 <- ef$bn[1]
  c1 <- ef$cn[1]
  d1 <- ef$dn[1]

  omega <- a1 * d1 - c1 * b1
  if (is.na(omega) || abs(omega) < EPS) {
    warning(
      "First harmonic is degenerate (near-circular or ill-defined). Results may be unstable."
    )
  }
  if (!is.na(omega) && omega < 0) {
    ef$bn <- -ef$bn
    ef$dn <- -ef$dn
    b1 <- -b1
    d1 <- -d1
  }

  if (skip_rotation) {
    theta_t <- 0
  } else {
    theta_t <- 0.5 * atan2(2 * (a1 * b1 + c1 * d1), (a1^2 + c1^2 - b1^2 - d1^2))
    if (theta_t < 0) {
      theta_t <- theta_t + pi / 2
    }

    sin_2theta_t <- sin(2 * theta_t)
    cos_2theta_t <- cos(2 * theta_t)
    cos_theta_square <- (1 + cos_2theta_t) / 2
    sin_theta_square <- (1 - cos_2theta_t) / 2

    axis_theta_1 <- sqrt(
      (a1^2 + c1^2) *
        cos_theta_square +
        (a1 * b1 + c1 * d1) * sin_2theta_t +
        (b1^2 + d1^2) * sin_theta_square
    )
    axis_theta_2 <- sqrt(
      (a1^2 + c1^2) *
        sin_theta_square -
        (a1 * b1 + c1 * d1) * sin_2theta_t +
        (b1^2 + d1^2) * cos_theta_square
    )

    if (axis_theta_1 < axis_theta_2) {
      theta_t <- theta_t + pi / 2
    }
  }

  cos_theta <- cos(theta_t)
  sin_theta <- sin(theta_t)
  a_star <- a1 * cos_theta + b1 * sin_theta
  c_star <- c1 * cos_theta + d1 * sin_theta
  psi <- atan2(c_star, a_star)
  if (psi < 0) {
    psi <- psi + 2 * pi
  }

  E <- sqrt(a_star^2 + c_star^2)
  if (E < EPS) {
    stop("Scale E is ~0; cannot normalize.")
  }

  ef$an <- ef$an / E
  ef$bn <- ef$bn / E
  ef$cn <- ef$cn / E
  ef$dn <- ef$dn / E

  if (!skip_rotation) {
    cos_psi <- cos(psi)
    sin_psi <- sin(psi)
    R_left <- matrix(c(cos_psi, sin_psi, -sin_psi, cos_psi), 2, byrow = TRUE)

    res <- lapply(seq_along(ef$an), function(i) {
      M <- matrix(c(ef$an[i], ef$bn[i], ef$cn[i], ef$dn[i]), 2, byrow = TRUE)
      Rr <- matrix(
        c(cos(theta_t * i), -sin(theta_t * i), sin(theta_t * i), cos(theta_t * i)),
        2,
        byrow = TRUE
      )
      as.vector(t(R_left %*% M %*% Rr))
    })
    mat <- do.call(rbind, res)
    ef$an <- mat[, 1]
    ef$bn <- mat[, 2]
    ef$cn <- mat[, 3]
    ef$dn <- mat[, 4]
  }

  n <- length(ef$an)
  if (y_sy && n > 1 && ef$an[2] < -EPS) {
    j <- 2:n
    sign_ad <- (-1)^((j %% 2) + 1)
    sign_bc <- (-1)^(j %% 2)
    ef$an[j] <- sign_ad * ef$an[j]
    ef$dn[j] <- sign_ad * ef$dn[j]
    ef$bn[j] <- sign_bc * ef$bn[j]
    ef$cn[j] <- sign_bc * ef$cn[j]
  } else {
    y_sy <- FALSE
  }

  if (x_sy && n > 1 && ef$cn[2] < -EPS) {
    idx <- 2:n
    ef$bn[idx] <- -ef$bn[idx]
    ef$cn[idx] <- -ef$cn[idx]
  } else {
    x_sy <- FALSE
  }

  if (output_meta) {
    return(list(
      ef = ef,
      theta_t = theta_t,
      psi = psi,
      E = E,
      omega = omega,
      y_sy = y_sy,
      x_sy = x_sy
    ))
  }

  ef
}

#' True-normalize an EFD coefficient matrix
#'
#' Applies `true_normalize()` row-wise to a coefficient matrix or data frame
#' containing `A1..AH`, `B1..BH`, `C1..CH`, and `D1..DH` columns.
#'
#' @param ef_coe Matrix/data frame of EFD coefficients by specimen.
#' @param EPS Numeric tolerance passed to `true_normalize()`.
#' @param y_sy Logical; whether to enforce y-axis symmetry convention.
#' @param x_sy Logical; whether to enforce x-axis symmetry convention.
#' @param skip_rotation Logical; whether to skip orientation normalization.
#' @param verbose Logical; if `TRUE`, emit progress messages.
#'
#' @return Numeric matrix with the same row count and normalized
#'   `A/B/C/D` harmonic columns.
#'
#' @sideeffects May emit warnings from `true_normalize()`.
true_normalize_coe <- function(
  ef_coe,
  EPS = 1e-10,
  y_sy = TRUE,
  x_sy = TRUE,
  skip_rotation = FALSE,
  verbose = FALSE
) {
  ef_mat <- as.matrix(ef_coe)
  storage.mode(ef_mat) <- "double"

  get_H <- function(cn) {
    idx <- grep("^[ABCD][0-9]+$", cn)
    if (!length(idx)) {
      stop("A/B/C/D indexed columns were not found.")
    }
    max(as.integer(sub("^[ABCD]", "", cn[idx])))
  }

  H <- get_H(colnames(ef_mat))
  nmA <- paste0("A", 1:H)
  nmB <- paste0("B", 1:H)
  nmC <- paste0("C", 1:H)
  nmD <- paste0("D", 1:H)

  need <- c(nmA, nmB, nmC, nmD)
  stopifnot(all(need %in% colnames(ef_mat)))

  norm_one <- function(row) {
    ef <- list(
      an = as.numeric(row[nmA]),
      bn = as.numeric(row[nmB]),
      cn = as.numeric(row[nmC]),
      dn = as.numeric(row[nmD]),
      ao = 0,
      co = 0
    )

    ef_true <- true_normalize(
      ef,
      EPS = EPS,
      y_sy = y_sy,
      x_sy = x_sy,
      skip_rotation = skip_rotation
    )

    if (verbose && skip_rotation) {
      message("skip_rotation is TRUE")
    }

    c(
      setNames(ef_true$an, nmA),
      setNames(ef_true$bn, nmB),
      setNames(ef_true$cn, nmC),
      setNames(ef_true$dn, nmD)
    )
  }

  ef_mat_norm <- t(apply(ef_mat, 1, norm_one))

  rownames(ef_mat_norm) <- rownames(ef_mat)
  ef_mat_norm <- ef_mat_norm[, need, drop = FALSE]
  storage.mode(ef_mat_norm) <- "double"
  ef_mat_norm
}

#' Compute EFDs and apply true normalization
#'
#' Runs `Momocs::efourier()` without built-in normalization and then applies
#' `true_normalize_coe()` to resulting coefficients.
#'
#' @param coo_out A contour object accepted by `Momocs::efourier()`.
#' @param nb_h Number of harmonics to compute.
#' @param x_sy Logical; whether to enforce x-axis symmetry convention.
#' @param y_sy Logical; whether to enforce y-axis symmetry convention.
#' @param ... Additional arguments forwarded to `true_normalize_coe()`.
#'
#' @return `efourier` result with normalized `coe` slot.
#'
#' @sideeffects Calls `Momocs::efourier()` and may emit downstream warnings/messages.
efourier_true_norm <- function(
  coo_out,
  nb_h = 35,
  x_sy = TRUE,
  y_sy = TRUE,
  ...
) {
  ef <- efourier(coo_out, nb.h = nb_h, norm = FALSE)
  ef$coe <- true_normalize_coe(ef$coe, y_sy = y_sy, x_sy = x_sy, ...)
  ef
}

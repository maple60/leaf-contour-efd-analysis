# https://github.com/wpwupingwp/ellishape_cli/blob/695be9dc70b85b93710c0cb6f7459dab948553d4/src/ellishape_cli/cli.py
true_normalize <- function(
  ef,
  EPS = 1e-10,
  y_sy = TRUE,
  x_sy = TRUE,
  output_meta = FALSE
) {
  stopifnot(!is.null(ef$an), !is.null(ef$bn), !is.null(ef$cn), !is.null(ef$dn))

  # 列名の標準化 ----
  names(ef) <- gsub("^A0$", "ao", names(ef), ignore.case = TRUE)
  names(ef) <- gsub("^C0$", "co", names(ef), ignore.case = TRUE)

  # DC 成分の0化 ----
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

  # 1次係数の取り出し
  a1 <- ef$an[1]
  b1 <- ef$bn[1]
  c1 <- ef$cn[1]
  d1 <- ef$dn[1]

  # クロス積の計算 ----
  omega <- a1 * d1 - c1 * b1
  if (is.na(omega) || abs(omega) < EPS) {
    warning(
      "First harmonic is degenerate (near-circular or ill-defined). Results may be unstable."
    )
  }
  if (!is.na(omega) && omega < 0) {
    # 全次数について bn,dn を反転
    ef$bn <- -ef$bn
    ef$dn <- -ef$dn
    b1 <- -b1
    d1 <- -d1
  }

  # 主軸候補角 θ_t の計算 ----
  theta_t <- 0.5 * atan2(2 * (a1 * b1 + c1 * d1), (a1^2 + c1^2 - b1^2 - d1^2))
  # 主軸の候補角を正の象限にそろえる
  if (theta_t < 0) {
    theta_t <- theta_t + pi / 2
  }
  # 軸の長さの計算
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
  # theta_1 < theta_2 なら theta_t を90度回転にして長軸にする
  if (axis_theta_1 < axis_theta_2) {
    theta_t <- theta_t + pi / 2
  }

  # 長軸の角度 ψ の計算 ----
  cos_theta <- cos(theta_t)
  sin_theta <- sin(theta_t)
  a_star <- a1 * cos_theta + b1 * sin_theta
  c_star <- c1 * cos_theta + d1 * sin_theta
  psi <- atan2(c_star, a_star)
  if (psi < 0) {
    psi <- psi + 2 * pi
  }

  # 長軸の長さ
  E <- sqrt(a_star^2 + c_star^2)
  if (E < EPS) {
    stop("Scale E is ~0; cannot normalize.")
  }

  # 大きさの正規化 ----
  ef$an <- ef$an / E
  ef$bn <- ef$bn / E
  ef$cn <- ef$cn / E
  ef$dn <- ef$dn / E

  # 回転に関する正規化 ----
  cos_psi <- cos(psi)
  sin_psi <- sin(psi)
  R_left <- matrix(c(cos_psi, sin_psi, -sin_psi, cos_psi), 2, byrow = TRUE)
  res <- lapply(seq_along(ef$an), function(i) {
    M <- matrix(c(ef$an[i], ef$bn[i], ef$cn[i], ef$dn[i]), 2, byrow = TRUE)
    Rr <- matrix(
      c(
        cos(theta_t * i),
        -sin(theta_t * i),
        sin(theta_t * i),
        cos(theta_t * i)
      ),
      2,
      byrow = TRUE
    )
    as.vector(t(R_left %*% M %*% Rr)) # a', b', c', d'
  })
  mat <- do.call(rbind, res)
  ef$an <- mat[, 1]
  ef$bn <- mat[, 2]
  ef$cn <- mat[, 3]
  ef$dn <- mat[, 4]

  # 対称性の正規化 ----
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
  } else {
    return(ef)
  }
}

true_normalize_coe <- function(ef_coe, EPS = 1e-10, y_sy = TRUE, x_sy = TRUE) {
  ef_mat <- as.matrix(ef_coe)
  storage.mode(ef_mat) <- "double"

  # ハーモニック数 H と列名セット
  get_H <- function(cn) {
    idx <- grep("^[ABCD][0-9]+$", cn)
    if (!length(idx)) {
      stop("A/B/C/D の番号付き列が見つかりません。")
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

  # 1行（1個体）を正規化して、元の順序・名前で返す関数
  norm_one <- function(row) {
    ef <- list(
      an = as.numeric(row[nmA]),
      bn = as.numeric(row[nmB]),
      cn = as.numeric(row[nmC]),
      dn = as.numeric(row[nmD]),
      ao = 0, # A0/C0 を使うなら row["A0"], row["C0"] 等に差し替え
      co = 0
    )
    ef_true <- true_normalize(ef, EPS = EPS, y_sy = y_sy, x_sy = x_sy)

    c(
      setNames(ef_true$an, nmA),
      setNames(ef_true$bn, nmB),
      setNames(ef_true$cn, nmC),
      setNames(ef_true$dn, nmD)
    )
  }

  # ===== 実行 =====
  # apply は列方向に積むので t() で転置して「個体×係数」に戻す
  ef_mat_norm <- t(apply(ef_mat, 1, norm_one))

  # 行名・列名を整える
  rownames(ef_mat_norm) <- rownames(ef_mat)
  ef_mat_norm <- ef_mat_norm[, need, drop = FALSE] # 列順を保証
  storage.mode(ef_mat_norm) <- "double"
  return(ef_mat_norm)
}

efourier_true_norm <- function(coo_out, nb_h = 35, x_sy = TRUE, y_sy = TRUE) {
  ef <- efourier(coo_out, nb.h = nb_h, norm = FALSE)
  ef$coe <- true_normalize_coe(ef$coe, y_sy = y_sy, x_sy = x_sy)
  return(ef)
}

# 指定した原点を中心に回転する関数
rotate_xy <- function(df, angle_deg, origin = c(0, 0)) {
  # 角度をラジアンに変換
  theta <- angle_deg * pi / 180

  # 原点を移動
  x <- df[, 1] - origin[1]
  y <- df[, 2] - origin[2]

  # 回転行列適用
  x_new <- x * cos(theta) - y * sin(theta)
  y_new <- x * sin(theta) + y * cos(theta)

  # 元の位置に戻す
  return(data.frame(x = x_new + origin[1], y = y_new + origin[2]))
}

# 輪郭の重心を中心に回転する関数
rotate_xy_centered <- function(df, angle_deg) {
  origin <- c(mean(df[, 1]), mean(df[, 2]))
  rotate_xy(df, angle_deg, origin)
}

# 任意の点を中心に回転する関数クロージャ
rotate_xy_custom_origin <- function(df, angle_deg, origins) {
  l <- lapply(seq_along(origins), function(i) {
    rotate_xy(df[i, ], angle_deg[i], origins[[i]])
  })
  do.call(rbind, l)
}

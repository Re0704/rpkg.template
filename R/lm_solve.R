# 内部辅助函数：用最小二乘法计算拟合值和误差
lm_solve <- function(design, response, only.SSE = FALSE, ...) {
  fit <- stats::lm.fit(design, response, ...)
  fitted <- as.vector(design %*% fit$coefficients)
  SSE <- sum(fit$residuals^2)

  if (only.SSE) return(list(SSE = SSE))

  list(
    coef = fit$coefficients,
    fitted = fitted,
    resi = as.vector(fit$residuals),
    SSE = SSE
  )
}

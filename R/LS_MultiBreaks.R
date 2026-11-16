#' 多突变点线性拟合：各段斜率相同，截距不同
#' @param Y 观测序列
#' @param X 自变量（函数内部会中心化）
#' @param Ips 各段末尾的位置，最后一个值为序列长度
#' @param ... 传递给 lm_solve()
#' @return 包含 coef、fitted、resi 和 SSE 的列表
#' @export
LS_MultiBreaks <- function(Y, X, Ips, ...) {
  n <- length(Y)
  if (length(X) != n) stop("Y 和 X 的长度必须相同")
  if (length(Ips) < 1 || anyNA(Ips) || any(diff(Ips) <= 0) ||
      Ips[1] < 1 || tail(Ips, 1) != n || any(Ips != floor(Ips))) {
    stop("Ips 应为递增的分段末尾位置，最后一个值等于序列长度")
  }

  design <- cbind(intercept = 1, slope = X - mean(X))
  n_breaks <- length(Ips) - 1

  for (i in seq_len(n_breaks)) {
    segment <- numeric(n)
    segment[(Ips[i] + 1):Ips[i + 1]] <- 1
    design <- cbind(design, segment)
    colnames(design)[ncol(design)] <- paste0("segment_", i + 1)
  }

  lm_solve(design, Y, ...)
}

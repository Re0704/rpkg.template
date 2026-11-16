#' 单突变点线性拟合：两段斜率相同，截距不同
#' @param Y 观测序列
#' @param X 自变量（如年份）
#' @param Ic 第一段末尾的位置；NA 表示不设突变点
#' @param ... 传递给 lm_solve()
#' @return 包含 coef、fitted、resi 和 SSE 的列表
#' @export
LS_OneBreak <- function(Y, X, Ic, ...) {
  n <- length(Y)
  if (length(X) != n) stop("Y 和 X 的长度必须相同")

  design <- cbind(intercept = 1, slope = X)
  if (!is.na(Ic)) {
    if (Ic < 1 || Ic >= n || Ic != floor(Ic)) stop("Ic 应是第一段末尾的位置")
    design <- cbind(design, shift_after_Ic = as.integer(seq_len(n) > Ic))
  }

  lm_solve(design, Y, ...)
}

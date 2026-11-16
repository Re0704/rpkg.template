# 单突变点案例：2005年后气温距平发生一次水平变化（模拟数据）
source("R/lm_solve.R")
source("R/LS_OneBreak.R")

years <- 1991:2020
index <- seq_along(years)
x <- years - mean(years)
Ic <- 15L  # 前15个观测值为第一段（1991—2005年）
y <- 0.015 * x + 0.85 * (index > Ic) + 0.14 * sin(1.6 * index)

# 已知突变位置：两段共用斜率，截距可以不同
fit <- LS_OneBreak(y, x, Ic = Ic)
fit_no_break <- LS_OneBreak(y, x, Ic = NA_integer_, only.SSE = TRUE)

cat("单突变点：", years[Ic], "年之后\n")
print(round(fit$coef, 4))
cat("无突变 SSE：", round(fit_no_break$SSE, 3), "\n")
cat("单突变 SSE：", round(fit$SSE, 3), "\n")

dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)
png("results/figures/one_break.png", width = 1100, height = 570, res = 130)

plot(years, y, pch = 16, col = "#4F8C9B", cex = 0.9,
     xlab = "年份", ylab = "气温距平（℃）",
     main = "年气温距平的单突变点拟合（模拟数据）")
lines(years[1:Ic], fit$fitted[1:Ic], col = "#B65D43", lwd = 2.5)
lines(years[(Ic + 1L):length(years)],
      fit$fitted[(Ic + 1L):length(years)], col = "#B65D43", lwd = 2.5)
abline(v = years[Ic] + 0.5, lty = 2, col = "#9D724C", lwd = 1.5)

legend("topleft", legend = c("模拟观测值", "分段拟合线", "已知突变点"),
       pch = c(16, NA, NA), lty = c(NA, 1, 2), lwd = c(NA, 2.5, 1.5),
       col = c("#4F8C9B", "#B65D43", "#9D724C"), bty = "n")
dev.off()

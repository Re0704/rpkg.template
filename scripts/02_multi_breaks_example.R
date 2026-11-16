# 多突变点案例：降水距平存在两次水平变化（模拟数据）
source("R/lm_solve.R")
source("R/LS_MultiBreaks.R")

years <- 1985:2020
index <- seq_along(years)
x <- years - mean(years)
Ips <- c(12L, 25L, length(years))  # 三段分别结束于1996、2009、2020年

segment_2 <- index > Ips[1] & index <= Ips[2]
segment_3 <- index > Ips[2]
y <- 1.15 * x - 22 * segment_2 + 27 * segment_3 +
     4 * sin(2.1 * index) + cos(2.9 * index)

# 已知两个突变位置：三段共用斜率，截距可以不同
fit <- LS_MultiBreaks(y, x, Ips = Ips)
fit_no_break <- LS_MultiBreaks(y, x, Ips = length(y), only.SSE = TRUE)

cat("多突变点：1996年后、2009年后\n")
print(round(fit$coef, 4))
cat("无突变 SSE：", round(fit_no_break$SSE, 3), "\n")
cat("多突变 SSE：", round(fit$SSE, 3), "\n")

dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)
png("results/figures/multi_breaks.png", width = 1100, height = 570, res = 130)

plot(years, y, pch = 16, col = "#4F8C9B", cex = 0.9,
     xlab = "年份", ylab = "降水距平（毫米）",
     main = "年降水距平的多突变点拟合（模拟数据）")

# 分段画线，避免把突变处的拟合值连成斜线
starts <- c(1L, head(Ips, -1L) + 1L)
for (j in seq_along(Ips)) {
  ids <- starts[j]:Ips[j]
  lines(years[ids], fit$fitted[ids], col = "#B65D43", lwd = 2.5)
}
abline(v = years[head(Ips, -1L)] + 0.5,
       lty = 2, col = "#9D724C", lwd = 1.5)

legend("topleft", legend = c("模拟观测值", "分段拟合线", "已知突变点"),
       pch = c(16, NA, NA), lty = c(NA, 1, 2), lwd = c(NA, 2.5, 1.5),
       col = c("#4F8C9B", "#B65D43", "#9D724C"), bty = "n")
dev.off()

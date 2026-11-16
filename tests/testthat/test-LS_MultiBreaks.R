
# 多突变点最小二乘拟合测试

test_that("多突变点模型能正确拟合已知数据", {
  x <- 1:12
  Ips <- c(4L, 8L, 12L)

  # 三个区段具有相同斜率和不同截距
  y <- 10 + 0.8 * x +
       5 * (x > 4 & x <= 8) -
       3 * (x > 8)

  fit <- LS_MultiBreaks(
    Y = y, X = x, Ips = Ips
  )

  # 验证拟合值和SSE
  expect_equal(as.numeric(fit$fitted),
               as.numeric(y),
               tolerance = 1e-8)
  expect_equal(as.numeric(fit$SSE), 0,
               tolerance = 1e-8)

  # 与不分段的模型比较
  fit0 <- LS_MultiBreaks(
    Y = y, X = x,
    Ips = length(y), only.SSE = TRUE
  )

  expect_gt(fit0$SSE, fit$SSE)
})

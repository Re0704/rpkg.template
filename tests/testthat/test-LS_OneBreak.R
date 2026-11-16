
# 单突变点最小二乘拟合测试

test_that("单突变点模型能正确拟合已知数据", {
  x <- 1:10
  Ic <- 5L

  # 已知斜率为2，第5个观测值后水平增加5
  y <- 1 + 2 * x + 5 * (x > Ic)

  fit <- LS_OneBreak(Y = y, X = x, Ic = Ic)

  # 无噪声数据应该能够被准确拟合
  expect_equal(as.numeric(fit$fitted),
               as.numeric(y),
               tolerance = 1e-8)
  expect_equal(as.numeric(fit$SSE), 0,
               tolerance = 1e-8)

  # 与普通线性回归比较
  fit0 <- LS_OneBreak(
    Y = y, X = x,
    Ic = NA_integer_, only.SSE = TRUE
  )

  expect_gt(fit0$SSE, fit$SSE)
})

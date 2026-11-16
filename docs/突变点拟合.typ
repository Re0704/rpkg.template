#let ink = rgb("#2C343A")
#let heading-ink = rgb("#244650")
#let quiet = rgb("#657177")

#set page(
  paper: "a4",
  margin: (top: 22mm, bottom: 22mm, x: 25mm),
  footer: align(center)[#text(size: 8pt, fill: quiet)[水文气象学 · R 语言方法讲义]],
)
#set text(font: ("Noto Serif CJK SC", "Source Han Serif SC", "SimSun"),
          size: 11.5pt, lang: "zh", fill: ink)
#set par(justify: true, leading: 0.72em)
#set table(stroke: 0.5pt, inset: 6pt)
#show heading.where(level: 1): set text(size: 14pt, weight: "bold", fill: heading-ink)
#show heading.where(level: 2): set text(size: 12pt, weight: "bold", fill: heading-ink)
#show raw.where(block: true): set text(size: 9pt)

#align(center)[
  #text(size: 18pt, weight: "bold", fill: ink)[水文气象序列的已知突变点拟合]
  #v(0.35em)
  #text(size: 10pt, fill: quiet)[单突变与多突变线性模型的原理及 R 案例]
]
#v(0.7em)

#block(fill: luma(245), inset: 10pt, radius: 4pt)[
  *本节重点：* 在突变位置已知的条件下，使用 `LS_OneBreak()` 和 `LS_MultiBreaks()` 拟合气温或降水序列，理解“共同斜率、不同截距”的含义。
]

= 1 方法与数学模型

== 1.1 为什么要考虑突变点？

气温、降水等水文气象序列可能具有长期趋势，也可能在某个时刻出现水平变化。例如，测站迁移或仪器更换可能改变序列的平均水平。此时，使用一条直线可能无法准确描述不同阶段的差异。

本节的两个函数均假定*突变位置事先已知*，仅拟合该位置前后的线性关系，*不自动搜索突变点*。

== 1.2 单突变点拟合：`LS_OneBreak()`

设 $Y_t$ 为第 $t$ 个观测值，$X_t$ 为自变量。若不考虑突变，普通线性模型为：

$ Y_t = alpha + beta X_t + epsilon_t $

假设第 $tau$ 个观测是第一段的最后一个值，且突变位置已经知道。为了表示突变后的水平变化，在原模型中加入一个指示变量：

$ Y_t = alpha + beta X_t + delta I(t > tau) + epsilon_t $

这里，$I(t > tau)$ 在突变前取 0，突变后取 1。因此，第一段的拟合值为 $alpha + beta X_t$，第二段为 $(alpha + delta) + beta X_t$。$delta$ 表示第二段相对于第一段的截距变化：$delta > 0$ 表示整体升高，$delta < 0$ 表示整体降低。

*需要注意：* 两段的斜率始终是同一个 $beta$，并不是分别拟合两条斜率不同的直线。在 `LS_OneBreak()` 中，用 `Ic` 指定第一段结束的*观测位置*，函数只估计给定位置前后的趋势与水平差异。

== 1.3 多突变点拟合：`LS_MultiBreaks()`

如果同一序列存在多个已知突变位置，就可以将它分成 $m$ 个区段。多突变点模型沿用单突变点的思路：保留一条共同的趋势项，再为第 2 段及之后的区段分别加入指示变量：

$ Y_t = alpha + beta (X_t - mu_X) + sum_(j=2)^m delta_j I(t in S_j) + epsilon_t $

其中，$mu_X$ 是 $X$ 的均值，$S_j$ 表示第 $j$ 段观测，$I(t in S_j)$ 表示观测是否属于该段。$delta_j$ 是第 $j$ 段*相对于第一段*的水平偏移，而不是相对于前一段的偏移。

例如，36 个观测按照 `Ips = c(12, 25, 36)` 分为三段：位置 1—12、13—25 和 26—36。模型需要两个指示变量，分别估计后两段相对于第一段的截距差异；三段仍使用同一个斜率 $beta$。

因此，*多突变点拟合不是重复做几次单独的线性回归*，而是在同一模型中同时估计共同趋势与各段的水平差异。`LS_MultiBreaks()` 的 `Ips` 给出各段最后一个观测的位置，最后一项应等于序列长度。

== 1.4 两个函数如何划分区间？

#table(
  columns: (1.5fr, 1.55fr, 2fr),
  [*函数*], [*分段参数*], [*结果特点*],
  [`LS_OneBreak()`], [`Ic`：第一段末尾位置], [一次水平变化，分成两段],
  [`LS_MultiBreaks()`], [`Ips`：各段末尾位置], [多个水平变化，分成多段],
)

#pagebreak()

= 2 单突变点拟合案例：

== 2.1 案例设置

使用 *1991—2020 年的模拟气温距平*，假设在 2005 年之后发生一次水平变化。因为 2005 年是序列中的第 15 个观测，所以 `Ic = 15`，即前 15 个观测为第一段。

== 2.2 关键 R 代码

```r
years <- 1991:2020
t <- seq_along(years)
x <- years - mean(years)
Ic <- 15L
y <- 0.015*x + 0.85*(t > Ic) + 0.14*sin(1.6*t)
fit <- LS_OneBreak(y, x, Ic = Ic)
round(fit$coef, 3)
```

`Ic` 指的是*观测位置*，而不是直接填写年份。`fit$coef` 给出截距、共同斜率及突变后的水平偏移，`fit$SSE` 表示拟合残差平方和。

== 2.3 拟合图及其含义

#figure(
  image("../results/figures/one_break.png", width: 94%),
  caption: [模拟气温距平的单突变点拟合。圆点为模拟观测值，实线为分段拟合线，虚线为已知突变位置。],
)

*如何读图：* 两段实线斜率相同，但 2005 年后拟合线整体向上移动，体现了模型中的水平偏移 $delta$。这里的突变点是预先指定的，不是函数自动检测出来的。

#pagebreak()

= 3 多突变点拟合案例：

== 3.1 案例设置

使用 *1985—2020 年的模拟降水距平*，假设 1996 年之后、2009 年之后各发生一次水平变化。36 个观测被分为三段：1985—1996 年、1997—2009 年、2010—2020 年。

== 3.2 关键 R 代码

```r
years <- 1985:2020
t <- seq_along(years)
x <- years - mean(years)
Ips <- c(12L, 25L, length(years))
s2 <- t > Ips[1] & t <= Ips[2]
s3 <- t > Ips[2]
y <- 1.15*x - 22*s2 + 27*s3 +
     4*sin(2.1*t) + cos(2.9*t)
fit <- LS_MultiBreaks(y, x, Ips = Ips)
round(fit$coef, 2)
```

`Ips = c(12, 25, 36)` 表示三段各自*末尾观测的位置*，即产生两个突变边界；最后一个值必须是序列长度。各段水平偏移均以第一段为参照。

== 3.3 拟合图及其含义

#figure(
  image("../results/figures/multi_breaks.png", width: 94%),
  caption: [模拟降水距平的多突变点拟合。两条虚线标出已知的分段位置，三段实线具有相同斜率。],
)

*如何读图：* 三段拟合线具有共同斜率，但水平位置不同。这与单突变点模型的思路一致，只是增加了分段数量。


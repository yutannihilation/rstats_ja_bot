library(ggplot2)


f <- systemfonts::system_fonts() |>
  dplyr::filter(family == "Iosevka", style == "Heavy") |>
  dplyr::pull(path)

d_rstatsj <- string2path::string2fill("rstatsj", f[1])

set.seed(120)
n <- 400
d <- data.frame(
  x = rnorm(n, 1.7, 1.0),
  y = rnorm(n, 0.1, 1.0),
  text = sample(
    c("<-", "plot()", "runif()", "if (", "} else {",
      "df", "stop()",
      "<-", "=", "^", "@", "$", "[[", "]]",
      "<-", "=", "^", "@", "$", "[[", "]]",
      "<-", "=", "^", "@", "$", "[[", "]]",
      "data.frame()", "+", "*", "%*%", "\\(x)", "q()",
      "*", "&&", "||", "[", "]", "|>",
      "*", "&&", "||", "[", "]", "|>",
      "*", "&&", "||", "[", "]", "|>",
      "%in%", "mean()", "sd()", "?", "1:10", "tidyverse"),
    size = n,
    replace = TRUE
  ),
  angle = runif(n, -20, 60)
)

p <- ggplot(mapping = aes(x, y)) +
  geom_text(data = d, aes(label = text, angle = angle), size = 11, colour = alpha("white", 0.4), family = "Iosevka") +
  geom_polygon(data = d_rstatsj, aes(group = triangle_id, fill = triangle_id)) +
  scale_fill_viridis_c(option = "F", guide = "none") +
  coord_equal(
    xlim = c(0,  3),
    ylim = c(-1.3, 1.7)
  ) +
  theme_void() +
  theme(plot.background = element_rect(fill = "grey"))

ggsave("icon.png", p, width = 7, height = 7)

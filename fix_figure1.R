library(ggplot2)
library(dplyr)
library(tidyr)
library(broom)

# Just the 4 valid ones
retention_data <- data.frame(
  Activity = c("Listening to Music", "Reading Newspaper", "Following Sports", "Reading Books"),
  Retention_Rate = c(97.1, 96.9, 87.4, 84.3)
)

p1 <- ggplot(retention_data, aes(x = reorder(Activity, Retention_Rate), y = Retention_Rate)) +
  geom_col(fill = "steelblue", alpha = 0.8) +
  geom_text(aes(label = paste0(Retention_Rate, "%")), hjust = -0.2, size = 4) +
  coord_flip() +
  scale_y_continuous(limits = c(0, 105), breaks = seq(0, 100, 20)) +
  labs(
    title = "Extremely High Over-Time Taste Stability (5-Year Window)",
    subtitle = "Percentage of respondents retaining cultural tastes",
    x = "Cultural Activity",
    y = "Retention Rate (%)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave("tex/taste_retention.png", p1, width = 8, height = 3)

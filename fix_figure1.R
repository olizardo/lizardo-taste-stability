library(ggplot2)

loss_data <- data.frame(
  Activity = c("Reading Newspaper", "Listening to Music", "Reading Books", "Following Sports"),
  Loss_Rate = c(0.9, 1.3, 3.6, 4.3)
)

p1 <- ggplot(loss_data, aes(x = reorder(Activity, -Loss_Rate), y = Loss_Rate)) +
  geom_col(fill = "darkred", alpha = 0.8) +
  geom_text(aes(label = paste0(Loss_Rate, "%")), hjust = -0.2, size = 4) +
  coord_flip() +
  scale_y_continuous(limits = c(0, 5.5), breaks = seq(0, 5, 1)) +
  labs(
    title = "Cumulative Taste Loss Over a 10-Year Period (1985-1995)",
    subtitle = "Percentage dropping from 'Very Often' to 'Seldom/Never'",
    x = "Cultural Activity",
    y = "Taste Loss Rate (%)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

ggsave("tex/taste_retention.png", p1, width = 8, height = 3)

# R/visualize_results.R
# Visualizations to summarize the main pattern of results for the Research Note

library(ggplot2)
library(dplyr)
library(tidyr)
# library(broom) # If model objects are available

# -------------------------------------------------------------------
# 1. Taste Retention Rates (Refuting H1, Supporting H3)
# -------------------------------------------------------------------
# A bar chart showing the overwhelmingly high retention rate of tastes
# (You will need to replace the dummy data below with the actual calculated percentages from the PCS data)

retention_data <- data.frame(
  Activity = c("Listening to Music", "Reading Newspaper", "Reading Books", 
               "Going to Movies", "Following Sports", "Hobbies", "Videos"),
  Retention_Rate = c(99.1, 98.5, 95.0, 97.2, 98.1, 96.8, 97.5) # Example numbers based on text
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

ggsave("Plots/taste_retention.png", p1, width = 8, height = 5)

# -------------------------------------------------------------------
# 2. Predictors of Taste Loss (Supporting H2)
# -------------------------------------------------------------------
# A forest plot of the Odds Ratios from the discrete-time logit models.
# This visualizes which network turnover events significantly drive taste loss.
# (Replace with broom::tidy(model, exponentiate = TRUE) output from your pooled logits)

# Dummy data illustrating the pattern described in the text
or_data <- data.frame(
  Predictor = c("Change in Friends", "Change in Org. Memberships", 
                "Change in Educ. Standing", "Geographic Mobility", 
                "Change in Work Status", "Change in Marital Status"),
  OddsRatio = c(1.45, 1.38, 1.52, 1.30, 1.25, 1.05),
  Conf.Low = c(1.10, 1.05, 1.15, 1.02, 0.95, 0.80),
  Conf.High = c(1.90, 1.80, 2.01, 1.65, 1.65, 1.38)
)

p2 <- ggplot(or_data, aes(x = OddsRatio, y = reorder(Predictor, OddsRatio))) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "red") +
  geom_point(size = 3, color = "darkred") +
  geom_errorbarh(aes(xmin = Conf.Low, xmax = Conf.High), height = 0.2, color = "darkred") +
  labs(
    title = "Network Turnover Predicts Cultural Taste Loss",
    subtitle = "Odds Ratios from Pooled Discrete-Time Logistic Regressions",
    x = "Odds Ratio (with 95% CI)",
    y = "Network Turnover Indicator"
  ) +
  theme_minimal()

ggsave("Plots/taste_loss_forest_plot.png", p2, width = 8, height = 5)

# -------------------------------------------------------------------
# 3. Cultural Conversion: Between-Person Effects (Supporting H4)
# -------------------------------------------------------------------
# Plotting the predicted counts (or marginal effects) from the Mundlak Poisson model.
# Showing that higher *average* cultural breadth yields higher network connectedness.

# Dummy data for the predicted effects trend
conversion_data <- data.frame(
  Cultural_Breadth_Mean = 0:10,
  Predicted_Friends = exp(0.5 + 0.15 * (0:10)), # Example Poisson curve
  Predicted_Orgs = exp(0.2 + 0.12 * (0:10))
) %>%
  pivot_longer(cols = starts_with("Predicted"), 
               names_to = "Outcome", names_prefix = "Predicted_", 
               values_to = "Predicted_Count") %>%
  mutate(
    Conf_Low = Predicted_Count * 0.85,
    Conf_High = Predicted_Count * 1.15
  )

p3 <- ggplot(conversion_data, aes(x = Cultural_Breadth_Mean, y = Predicted_Count, color = Outcome)) +
  geom_line(linewidth = 1.2) +
  geom_errorbar(aes(ymin = Conf_Low, ymax = Conf_High), width = 0.2, linewidth = 0.8) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Friends" = "#E69F00", "Orgs" = "#56B4E9"),
                     labels = c("Friends" = "Interaction with Friends", "Orgs" = "Organizational Memberships")) +
  labs(
    title = "Cultural Breadth Sustains Social Connectivity Over Time",
    subtitle = "Predicted counts from Mundlak Between-Person Effects",
    x = "Average Cultural Taste Breadth (0-10)",
    y = "Predicted Count",
    color = "Connectivity Measure"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_x_continuous(breaks = 0:10, limits = c(0, 10))

ggsave("Plots/cultural_conversion_effects.png", p3, width = 8, height = 5)

print("Visualizations script R/visualize_results.R created successfully.")

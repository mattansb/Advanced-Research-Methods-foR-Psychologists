
library(dplyr)
library(parameters)
library(performance) # for `compare_performance()`
library(emmeans) # for simple slope analysis
library(ggeffects) # for model plotting

parental_iris <- read.csv("parental_iris.csv")

glimpse(parental_iris)
head(parental_iris)

# Last time we saw that R doesn't need you to make dummy variables - if can deal
# with factors just fine. Today we will see that this is also true for
# moderation and interactions!
# (I will not be showing how to do these the long way...)





# Categorical moderator ---------------------------------------------------

# Let's prep the data for modeling:
parental_iris <- parental_iris %>%
  mutate(attachment = relevel(factor(attachment), ref = "secure"),
         involvement_c = scale(parental_involvement, center = TRUE, scale = FALSE))
# Here we don't want to get z scores (or maybe we do?) just to center the
# variable around 0.





## 1. Fit the model(s) ----------------------------------------------------
m_additive <- lm(child_satisfaction ~ involvement_c + attachment,
                 data = parental_iris)


# all you need is to tell R to add an interaction!
m_moderation <- lm(child_satisfaction ~ involvement_c + attachment + involvement_c:attachment,
                   data = parental_iris)
# or use `*` -- A * B = A + B + A:B
m_moderation <- lm(child_satisfaction ~ involvement_c * attachment,
                   data = parental_iris)

anova(m_additive, m_moderation)
compare_performance(m_additive, m_moderation)


# Look at the parameters. What do they mean?
model_parameters(m_moderation)






## 2. Explore the model  --------------------------------------------------
# simple slope analysis!

# We don't (just) care about the model's parameters - what we usually care about
# are the different estimates the model can give us - the simple (conditional)
# slopes.

emtrends(m_moderation, ~ attachment, var = "involvement_c") %>%
  summary(infer = TRUE)

# we can also use contrasts here to COMPARE slopes:
emtrends(m_moderation, ~ attachment, var = "involvement_c") %>%
  contrast(method = "pairwise")


## Plot
plot(ggemmeans(m_moderation, c("involvement_c","attachment")),
     add.data = TRUE, jitter = 0)





# Continuous moderator ----------------------------------------------------

## Prep the data
parental_iris <- parental_iris %>%
  mutate(strictness_c = scale(parental_strictness, TRUE, FALSE))



## 1. Fit the model(s) ----------------------------------------------------

m_additive <- lm(child_satisfaction ~ involvement_c + strictness_c,
                 data = parental_iris)
m_moderation <- lm(child_satisfaction ~ involvement_c * strictness_c,
                   data = parental_iris)

# compare models:
anova(m_additive, m_moderation)
compare_performance(m_additive, m_moderation)


# Look at the parameters. What do they mean?
model_parameters(m_moderation)








## 2. Explore the model  --------------------------------------------------
# simple slope analysis!

mean_plus_minus_sd <- function(x) {
  m <- mean(x)
  s <- sd(x)

  c(m - s, m, m + s)
}

emtrends(m_moderation, ~strictness_c, "involvement_c",
         # Condition on the mean+-sd of `strictness_c`:
         cov.reduce = list(strictness_c = mean_plus_minus_sd)) %>%
  summary(infer = TRUE)


plot(ggemmeans(m_moderation, c("involvement_c","strictness_c [meansd]")),
     add.data = TRUE, jitter = 0)
# See how ggemmeans took the mean +- sd? So smart...




# Once again, note that in R, model fitting and hypothesis testing are not as
# closely knit as they are in SPSS. For simple slope analysis, in SPSS, we would
# re-fit new models for each simple slope, in R we instead (1) fit a model, (2)
# test the simple slope of interest.





# Categorical by Categorical ----------------------------------------------

# What about a categorical variable moderating the effect of another categorical
# variable? We can do that just the same! We will see more of this in a few
# weeks, when we talk about ANOVAs...




# Exercise ----------------------------------------------------------------

# 1. Using the `interactions` package, plot a Johnson-Neyman plot
#   (`interactions::johnson_neyman()`). What does it do? (Note, both the
#   predictor and the moderator must be continuous.)
# 2. Fit the same moderation model with the original *non-centered* predictors.
#   How does it differ from the moderation model with the centered predictors?
#   A. How do the parameters differ? Interpret them.
#   B. How does the model fit (R^2) differ?
#   C. How do the simple slopes analysis differ?



load("data/prepped_data.RData")
colnames(df)
library(tidyverse)

d <- df %>%  
  mutate_if(is.factor, as.numeric) %>%
  as.data.frame() %>%
  drop_na()

library(sl3)
library(sherlock)

lrn_ranger100 <- Lrnr_ranger$new(num.trees = 100, seed = 666)
xgb_fast <- Lrnr_xgboost$new()
xgb_100 <- Lrnr_xgboost$new(nrounds = 100, max_depth = 6, eta = 0.001)
lrn_enet_interaction <- Lrnr_glmnet$new(alpha = 0.5)

interactions <- list(c("EXPTRT", "RWA"),
                     c("EXPTRT", "collective_narcissism"),
                     c("EXPTRT", "RWA", "collective_narcissism"))
propensity_score_learner_spec <- xgb_100
outcome_regression_learner_spec <- list(lrn_ranger100, xgb_fast,
                                        list(interactions, lrn_enet_interaction))
cond_avg_trt_eff_learner_spec <- Lrnr_sl$new(
  learners = list(lrn_ranger100, xgb_fast),
  metalearner = Lrnr_cv_selector$new()
)

sherlock_results <- sherlock_calculate(
  data_from_case = d,
  baseline = c("BornIn", "political_orientation",
               "RWA", "collective_narcissism",
               "populism_pre"),
  exposure = "EXPTRT",
  outcome = "populism_post",
  segment_by = c("RWA", "collective_narcissism"),
  cv_folds = 10L,
  ps_learner = propensity_score_learner_spec,
  or_learner = outcome_regression_learner_spec,
  cate_learner = cond_avg_trt_eff_learner_spec
)
plot(sherlock_results, plot_type = "cate")

sherlock_results <- watson_segment(
  sherlock_results,
  segment_fun = cost_threshold,
  threshold = 0,
  type = "inferential"
)
plot(sherlock_results, plot_type = "treatment_decisions")

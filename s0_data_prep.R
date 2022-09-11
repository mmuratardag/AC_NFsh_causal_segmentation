
load("data/data.RData")
colnames(df)
library(tidyverse)

ntile_na <- function(var, ntile_n) {
  notna <- !is.na(var)
  out <- rep(NA_real_, length(var))
  out[notna] <- ntile(var[notna], ntile_n)
  return(out)
}

df <- df %>%
  select(
    id,
    BornIn,
    populism_pre,
    political_orientation,
    RWA,
    collective_narcissism,
    EXPTRT,
    populism_post
  ) %>%
  mutate(
    political_orientation = as_factor(political_orientation),
    political_orientation = fct_collapse(political_orientation,
      Left = c("1", "2", "3"),
      Center = c("4", "5", "6"),
      Right = c("7", "8", "9")
    ),
    RWA = as_factor(ntile_na(RWA, 2)),
    RWA = fct_recode(RWA, lower = "1", higher = "2"),
    collective_narcissism = as_factor(ntile_na(collective_narcissism, 2)),
    collective_narcissism = fct_recode(collective_narcissism, lower = "1", higher = "2")
  )

save(df, file = "data/prepped_data.RData")

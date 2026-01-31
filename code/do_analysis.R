# ------------------------------------------------------------------------------
# Purpose: Replication of Kleinman & Lin (2017)
# Research question: Does audit regulation vary systematically across countries? 
# ------------------------------------------------------------------------------

# Read config

source("code/utils.R")

# Read theme

source("code/theme_trr.R")

# Read data 

log_info("Reading prepared sample ...")
log_info("Input file: '{global_cfg$replication_dataset}'")

replication_dataset <- read_csv(global_cfg$replication_dataset)

log_info("Total rows: {nrow(replication_dataset)}") 

# Construct replication samples

# Countries excluded by the authors due to data availability
excluded_countries <- c("ARG", "HKG", "ROU", "TWN", "UKR")

# 1. Excluding the same countries as authors excluded
replication_dataset_excluded <- replication_dataset %>%
filter(!COUNTRY_CODE %in% excluded_countries)

log_info("Total rows after country exclusions: {nrow(replication_dataset_excluded)}") 

# Following Kleinman & Lin's logic, countries with missing variables are dropped.

# 2. No NA + excluding the same countries as authors excluded
final_replication_dataset <- replication_dataset_excluded %>%
  drop_na()

log_info("Total rows after dropping NA and excluding countries: {nrow(final_replication_dataset)}") 

# 3. No NA
alternative_replication_dataset <- replication_dataset %>%
  drop_na()

log_info("Total rows after dropping NA: {nrow(alternative_replication_dataset)}") 

# ------------------------------------------------------------------------------
# Research hypotheses
# ------------------------------------------------------------------------------

log_info("Constructing Table 1 (Research hypotheses) ...")

# Define hypotheses exactly as stated in Kleinman & Lin (2017)
hypotheses_df <- tibble::tibble(
  Hypothesis = c("H1", "H2", "H3", "H4", "H5", "H6", "H7"),
  Statement = c(
    "Religion will not be associated with the level of auditing regulatory enforcement.",
    "The importance ascribed to religion by individuals will not be associated with the level of auditing regulatory enforcement.",
    "Individualism (IND) will not be associated with the level of auditing regulatory enforcement",
    "Power distance (PD) will not be associated with the level of auditing regulatory enforcement.",
    "Uncertainty Avoidance (UA) will not be associated with the level of auditing regulatory enforcement.",
    "Legal family will not be associated with the level of auditing regulatory enforcement.",
    "Markets with greater liquidity will not be positively associated with greater auditing regulatory enforcement."
  )
)

log_info("Formatting hypotheses table ...")

tab1_hypotheses <- gt::gt(hypotheses_df) %>%
  gt::tab_header(
    title = "Table 1. Research hypotheses"
  ) %>%
  gt::cols_label(
    Hypothesis = gt::md("**Hypothesis**"),
    Statement  = gt::md("**Statement**")
  ) %>%
  gt::cols_align(
    align = "left",
    columns = everything()
  ) %>%
  gt::opt_row_striping() %>%
  gt::tab_source_note(
    gt::md(
      "**Notes:** Hypotheses are based on Kleinman and Lin (2017), Audit regulation in an international setting: Testing the impact of religion, culture, market factors, and legal code on national regulatory efforts."
    )
  )

log_info("Table 1 (hypotheses) constructed successfully.")

# ------------------------------------------------------------------
# Country coverage table
# ------------------------------------------------------------------

log_info("Constructing country coverage table (Kleinman & Lin, Table 1) ...")

# All countries appearing in Brown et al. dataset
all_countries <- replication_dataset %>%
  dplyr::distinct(COUNTRY_CODE, COUNTRY)

# Countries excluded by Kleinman & Lin
countries_kl_excluded <- tibble::tibble(
  COUNTRY_CODE = excluded_countries
)

# Countries excluded from this replication (missing data after listwise deletion)
countries_replication_excluded <- all_countries %>%
  dplyr::filter(!COUNTRY_CODE %in% alternative_replication_dataset$COUNTRY_CODE)

log_info("Assign footnote markers ...")

country_list <- all_countries %>%
  dplyr::mutate(
    mark_kl = ifelse(COUNTRY_CODE %in% countries_kl_excluded$COUNTRY_CODE, "[a]", ""),
    mark_rep = ifelse(COUNTRY_CODE %in% countries_replication_excluded$COUNTRY_CODE, "[b]", ""),
    country_display = paste0(COUNTRY, mark_kl, mark_rep)
  ) %>%
  dplyr::arrange(COUNTRY)

log_info("Total countries listed: {nrow(country_list)}")

log_info("Arrange countries into three columns ...")

n_cols <- 4
n_rows <- ceiling(nrow(country_list) / n_cols)

country_table_df <- tibble::tibble(
  col1 = country_list$country_display[1:n_rows],
  col2 = country_list$country_display[(n_rows + 1):(2 * n_rows)],
  col3 = country_list$country_display[(2 * n_rows + 1):(3 * n_rows)],
  col4 = country_list$country_display[(3 * n_rows + 1):(4 * n_rows)]
) %>%
  dplyr::mutate(dplyr::across(everything(), ~ ifelse(is.na(.), "", .)))

log_info("Create table ...")

tab2_countries <- gt::gt(country_table_df) %>%
  gt::tab_header(
    title = "Table 2. Countries included in Brown et al. (2014)"
  ) %>%
  gt::cols_label(
    col1 = "",
    col2 = "",
    col3 = "",
    col4 = ""
  ) %>%
  gt::opt_all_caps(FALSE) %>%
  gt::opt_row_striping() %>%
  gt::tab_source_note(
    gt::md(
      "[a] Country excluded from Kleinman and Lin (2017) due to missing data.  
       [b] Country excluded from the present replication due to missing data."
    )
  )

log_info("Country coverage table constructed successfully.")

# ------------------------------------------------------------------------------
# Descriptive statistics
# ------------------------------------------------------------------------------

log_info("Constructing Table 3 (descriptive statistics) ...")

# Variables in the same order as in Kleinman & Lin (Table 3)
desc_vars <- c(
  "AUDIT_2008",
  "IND",
  "PD",
  "UA",
  "PROT_PCT",
  "CHRST_OTH",
  "BUDH_PCT",
  "ISLM_PCT",
  "HIND_PCT",
  "RELG_OTH",
  "RELIGION_IMPORTANT",
  "LEGAL",
  "MARKET_LIQUIDITY2008",
  "ChAUDIT08_02",
  "DIF_LIQUID08_02"
)

desc_df <- replication_dataset_excluded %>%
  dplyr::select(all_of(desc_vars)) %>%
  purrr::map_dfr(
    ~ tibble::tibble(
      N    = sum(!is.na(.x)),
      Min  = min(.x, na.rm = TRUE),
      Max  = max(.x, na.rm = TRUE),
      Mean = mean(.x, na.rm = TRUE),
      SD   = sd(.x, na.rm = TRUE)
    ),
    .id = "Variable"
  )

tab3_descriptive <- gt::gt(desc_df) %>%
  gt::tab_header(
    title = "Table 3. Descriptive statistics of collected data"
  ) %>%
  gt::cols_label(
    Variable = "",
    N = "N",
    Min = "Min",
    Max = "Max",
    Mean = "Mean",
    SD = "Std. deviation"
  ) %>%
  gt::fmt_number(
    columns = c(Min, Max, Mean, SD),
    decimals = 3
  ) %>%
  gt::fmt_number(
    columns = N,
    decimals = 0
  ) %>%
  gt::opt_row_striping() %>%
  gt::tab_source_note(
    gt::md(
      "**Notes:** Following the original study, Argentina, Hong Kong, Romania, Taiwan, and Ukraine are excluded due to data availability. 
      Descriptive statistics for the following variables are identical to the original study: AUDIT_2008, IND, UA, PROT_PCT, CHRST_OTH, BUDH_PCT, ISLM_PCT, HIND_PCT, RELG_OTH, ChAUDIT08_02 (see Table 3 in Kleinman & Lin). 
      Values for IND, PD, and UA for Egypt, Jordan, and Ukraine were retrieved from Hofstede's website (https://geerthofstede.com/country-comparison-bar-charts/) and addet to a sample manually to match the Kleinman & Lin paper, though these estimates are not scientifically validated and not recommended for academic use. The LEGAL variable was sourced from Brown et al. (2014) and independently verified; differences in its summary statistics likely reflect classification discrepancies.
      Deviations in other variables may stem from updated or revised source data. Variable definitions and data sources are reported in Appendix 1."
      )
  )

log_info("Table 3 constructed successfully.")

# ------------------------------------------------------------------------------
# Correlation analysis
# ------------------------------------------------------------------------------

log_info("Constructing Table 4 (Pearson correlations) ...")

# Variables used in the correlation table (same order as Kleinman & Lin, Table 4)
corr_vars <- c(
  "AUDIT_2008",
  "ChAUDIT08_02",
  "IND",
  "PD",
  "UA",
  "PROT_PCT",
  "CHRST_OTH",
  "BUDH_PCT",
  "ISLM_PCT",
  "HIND_PCT",
  "RELG_OTH",
  "RELIGION_IMPORTANT",
  "LEGAL",
  "MARKET_LIQUIDITY2008",
  "DIF_LIQUID08_02"
)

corr_data <- final_replication_dataset %>%
  dplyr::select(dplyr::all_of(corr_vars))

log_info("Computing Pearson correlation matrix (listwise deletion) ...")

corr_matrix <- cor(
  corr_data,
  use = "complete.obs",
  method = "pearson"
)

log_info("Computing p-values for correlations ...")

cor_test <- function(x, y) {
  test <- cor.test(x, y)
  test$p.value
}

p_matrix <- matrix(
  NA,
  nrow = ncol(corr_data),
  ncol = ncol(corr_data)
)

for (i in seq_len(ncol(corr_data))) {
  for (j in seq_len(ncol(corr_data))) {
    p_matrix[i, j] <- cor_test(corr_data[[i]], corr_data[[j]])
  }
}

colnames(p_matrix) <- colnames(corr_data)
rownames(p_matrix) <- colnames(corr_data)

log_info("Adding significance stars to correlation coefficients ...")

add_stars <- function(r, p) {
  if (p < 0.01) {
    paste0(round(r, 3), "***")
  } else if (p < 0.05) {
    paste0(round(r, 3), "**")
  } else if (p < 0.10) {
    paste0(round(r, 3), "*")
  } else {
    round(r, 3)
  }
}

corr_stars <- matrix(
  "",
  nrow = nrow(corr_matrix),
  ncol = ncol(corr_matrix)
)

for (i in seq_len(nrow(corr_matrix))) {
  for (j in seq_len(ncol(corr_matrix))) {
    if (i == j) {
      corr_stars[i, j] <- "1"
    }
    if (i > j) {
      corr_stars[i, j] <- add_stars(
        corr_matrix[i, j],
        p_matrix[i, j]
      )
    }
  }
}

colnames(corr_stars) <- colnames(corr_matrix)
rownames(corr_stars) <- rownames(corr_matrix)

corr_df <- as.data.frame(corr_stars) %>%
  tibble::rownames_to_column(" ")

tab4_correlations <- gt::gt(corr_df) %>%
  gt::tab_options(
    table.width = gt::pct(100),
  ) %>%
  gt::tab_header(
    title = "Table 4. Correlations"
  ) %>%
  gt::cols_align(
    align = "left",
    columns = -1
  ) %>%
  gt::cols_width(
    everything() ~ gt::px(55)
  ) %>%
  gt::opt_all_caps() %>%
  gt::opt_table_outline() %>%
  gt::tab_source_note(
    gt::md(
      "**Notes:** Pearson correlation coefficients are based on the final country-level sample (N = 32). The sample is constructed by excluding countries omitted in Kleinman & Lin (2016) due to data availability and applying listwise deletion to retain only complete observations across all variables included. Two-tailed significance tests are reported. * p < 0.10; ** p < 0.05; *** p < 0.01."
    )
  )

log_info("Table 4 constructed successfully.")

# ------------------------------------------------------------------------------
# OLS regression analysis
# Main model: AUDIT_2008 (final_replication_dataset and 
# alternative_replication_dataset)
# ------------------------------------------------------------------------------

log_info("Running OLS estimation with AUDIT_2008 as dependent variable with a 
         final dataset (N=32)...")

ols_audit_final <- lm(
  AUDIT_2008 ~ 
    IND + PD + UA +
    PROT_PCT + BUDH_PCT + ISLM_PCT + HIND_PCT + RELG_OTH +
    RELIGION_IMPORTANT + LEGAL + MARKET_LIQUIDITY2008,
  data = final_replication_dataset
)

log_info("Running OLS estimation with AUDIT_2008 as dependent variable with an 
         alternative dataset (N=35)...")

ols_audit_alternative <- lm(
  AUDIT_2008 ~ 
    IND + PD + UA +
    PROT_PCT + BUDH_PCT + ISLM_PCT + HIND_PCT + RELG_OTH +
    RELIGION_IMPORTANT + LEGAL + MARKET_LIQUIDITY2008,
  data = alternative_replication_dataset
)

log_info("OLS estimation completed.")

# ------------------------------------------------------------------------------
# Multicollinearity diagnostics: Variance Inflation Factors (VIF)
# ------------------------------------------------------------------------------

log_info("Computing VIFs for main regression (AUDIT_2008) ...")

vif_audit_final <- car::vif(ols_audit_final)
vif_audit_alternative <- car::vif(ols_audit_alternative)

# ------------------------------------------------------------------------------
# OLS regression analysis
# Change model: ChAUDIT08_02
# ------------------------------------------------------------------------------

log_info("Running OLS estimation with ChAUDIT08_02 as dependent variable with a 
         final dataset (N=32)...")

ols_chaudit_final <- lm(
  ChAUDIT08_02 ~ 
    IND + PD + UA +
    PROT_PCT + BUDH_PCT + ISLM_PCT + HIND_PCT + RELG_OTH +
    RELIGION_IMPORTANT + LEGAL + DIF_LIQUID08_02,
  data = final_replication_dataset
)

log_info("Running OLS estimation with ChAUDIT08_02 as dependent variable with an 
         alternative dataset (N=35)...")

ols_chaudit_alternative <- lm(
  ChAUDIT08_02 ~ 
    IND + PD + UA +
    PROT_PCT + BUDH_PCT + ISLM_PCT + HIND_PCT + RELG_OTH +
    RELIGION_IMPORTANT + LEGAL + DIF_LIQUID08_02,
  data = alternative_replication_dataset
)

log_info("OLS estimation (change regression) completed.")

# ------------------------------------------------------------------------------
# Multicollinearity diagnostics: Variance Inflation Factors (VIF)
# ------------------------------------------------------------------------------

log_info("Computing VIFs for change regression (ChAUDIT08_02) ...")

vif_chaudit_final <- car::vif(ols_chaudit_final)
vif_chaudit_alternative <- car::vif(ols_chaudit_alternative)

# ------------------------------------------------------------------------------
# Results Table
# ------------------------------------------------------------------------------

log_info("Defining helper function to extract formatted regression coefficients ...")

extract_model_results <- function(model, coef_labels) {
  
  broom::tidy(model) %>%
    dplyr::mutate(
      stars = dplyr::case_when(
        p.value < 0.01 ~ "***",
        p.value < 0.05 ~ "**",
        p.value < 0.10 ~ "*",
        TRUE ~ ""
      ),
      estimate_fmt = sprintf("%.3f%s", estimate, stars),
      t_fmt        = sprintf("(%.3f)", statistic),
      value        = paste0(estimate_fmt, " ", t_fmt),
      Variable     = coef_labels[term]
    ) %>%
    dplyr::select(Variable, value)
}

log_info("Defining helper function to extract model statistics ...")

extract_model_stats <- function(model) {
  
  s <- summary(model)
  
  tibble::tibble(
    F = sprintf("%.3f***", unname(s$fstatistic[1])),
    `Adjusted R-squared` = sprintf("%.3f", s$adj.r.squared),
    `R-squared` = sprintf("%.3f", s$r.squared)
  )
}

log_info("Defining helper function for dynamic column names ...")

model_colname <- function(label, model) {
  paste0(label, " (N = ", nobs(model), ")")
}

coef_labels <- c(
  "(Intercept)" = "Constant",
  "IND" = "Individualism (IND)",
  "PD" = "Power Distance (PD)",
  "UA" = "Uncertainty Avoidance (UA)",
  "PROT_PCT" = "Protestant (%)",
  "BUDH_PCT" = "Buddhist (%)",
  "ISLM_PCT" = "Islam (%)",
  "HIND_PCT" = "Hindu (%)",
  "RELG_OTH" = "Other religions (%)",
  "RELIGION_IMPORTANT" = "Importance of religion",
  "LEGAL" = "Legal origin",
  "MARKET_LIQUIDITY2008" = "Market liquidity (2008)",
  "DIF_LIQUID08_02" = "Change in market liquidity (2002-2008)"
)

log_info("Extracting regression results for all model specifications ...")

audit_32 <- extract_model_results(ols_audit_final, coef_labels) %>%
  dplyr::rename(
    !!model_colname("AUDIT_2008", ols_audit_final) := value
  )

audit_35 <- extract_model_results(ols_audit_alternative, coef_labels) %>%
  dplyr::rename(
    !!model_colname("AUDIT_2008", ols_audit_alternative) := value
  )

chaudit_32 <- extract_model_results(ols_chaudit_final, coef_labels) %>%
  dplyr::rename(
    !!model_colname("ChAUDIT08_02", ols_chaudit_final) := value
  )

chaudit_35 <- extract_model_results(ols_chaudit_alternative, coef_labels) %>%
  dplyr::rename(
    !!model_colname("ChAUDIT08_02", ols_chaudit_alternative) := value
  )

log_info("Merging coefficient estimates into a joint comparison table ...")

final_results_table <- audit_32 %>%
  dplyr::full_join(audit_35,   by = "Variable") %>%
  dplyr::full_join(chaudit_32, by = "Variable") %>%
  dplyr::full_join(chaudit_35, by = "Variable")

log_info("Appending model statistics (F, Adjusted R-squared, R-squared) ...")

stats_block <- tibble::tibble(
  Variable = c("F", "Adjusted R-squared", "R-squared"),
  !!model_colname("AUDIT_2008", ols_audit_final) :=
    as.character(extract_model_stats(ols_audit_final)),
  !!model_colname("AUDIT_2008", ols_audit_alternative) :=
    as.character(extract_model_stats(ols_audit_alternative)),
  !!model_colname("ChAUDIT08_02", ols_chaudit_final) :=
    as.character(extract_model_stats(ols_chaudit_final)),
  !!model_colname("ChAUDIT08_02", ols_chaudit_alternative) :=
    as.character(extract_model_stats(ols_chaudit_alternative))
)

final_results_table <- dplyr::bind_rows(final_results_table, stats_block)

final_results_table <- final_results_table %>%
  dplyr::mutate(dplyr::across(-Variable, ~ ifelse(is.na(.), "-", .)))

log_info("Rendering final regression results table ...")

tab5_results <- gt::gt(final_results_table) %>%
  gt::tab_header(
    title = "Table 5. The impact of cultural, religious, legal and economic variables on audit regulation"
  ) %>%
  gt::tab_options(
    table.width = gt::pct(100),
  ) %>%
  gt::opt_row_striping() %>%
  gt::tab_source_note(
    gt::md(
      "**Notes:** OLS regressions on levels and changes in audit enforcement. Coefficients are reported with t-values in parentheses. CHRST_OTH (Other Christian, %) is the omitted reference religion category. * p < 0.10; ** p < 0.05; *** p < 0.01."
    )
  )

log_info("Table 5 constructed successfully.")

log_info("Saving tables to results file '{global_cfg$results_r}' ...")

save(tab1_hypotheses, tab2_countries, tab3_descriptive, tab4_correlations, tab5_results, file = global_cfg$results_r)

save_gt <- function(tab, filename,
                    vwidth = 2400,
                    vheight = 1800,
                    zoom = 2) {
  gt::gtsave(
    tab,
    filename,
    vwidth = vwidth,
    vheight = vheight,
    zoom = zoom
  )
}

save_gt(tab1_hypotheses, "output/tab1_hypotheses.png", vwidth = 800)
save_gt(tab2_countries,  "output/tab2_countries.png", vwidth = 1000)
save_gt(tab3_descriptive,"output/tab3_descriptive.png", vwidth = 900)
save_gt(tab4_correlations,"output/tab4_correlations.png", vwidth = 1600)
save_gt(tab5_results,    "output/tab5_results.png", vwidth = 900)


log_info("Final regression table saved successfully.")


# Accounting II: Corporate Decision-Making and Quantitative Analysis. Assignment 3

This project answers the question **does audit regulation vary systematically across countries?** by replicating the paper by Kleinman & Lin (2017)

## Project structure

-   `config/global_cfg.yaml` — main configuration (file paths for input/output)
-   `code/R/do_analysis.R` — constructs audit mandate indicators and summary tables
-   `doc/paper_r.qmd` — renders to a PDF
-   `output/` — generated outputs (prepared PDF) and tables

## Run full pipeline step-by-step

This repository is set up so that the entire analysis can be reproduced in a straightforward way, from data preparation to the final results. Starting from the raw input data, the code prepares the analysis sample, generates all intermediate tables and results, and then produces the final PDF report.

To run the full pipeline, simply execute the following commands from the project root directory, in the order shown below:

`Rscript --encoding=UTF-8 code/do_analysis.R` - Prepares and cleans the replication data and runs the main analysis on the prepared data and saves the remaining result tables.

`quarto render doc/paper_r.qmd` - Builds the paper and inserts the saved tables into the final PDF output.

Run these three commands, give your computer a minute, and the answer to the research question will appear:)

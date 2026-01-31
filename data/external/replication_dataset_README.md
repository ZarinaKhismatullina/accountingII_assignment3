---
editor_options: 
  markdown: 
    wrap: 72
---

**Replication Project:** Kleinman, G., Lin, B.B. Audit regulation in an
international setting: Testing the impact of religion, culture, market
factors, and legal code on national regulatory efforts. Int J Discl Gov
14, 62–94 (2017). <https://doi.org/10.1057/s41310-016-0016-1>

`replication_dataset.xlsx` — final merged country-level dataset used for
the replication.

**Data sources and variable descriptions**

Audit enforcement indices (AUDIT, ENFORCE, TOTAL; 2002, 2005, 2008)
Country-level audit enforcement measures taken directly from Brown et
al. (2014), as reported in the published tables (Wiley, Table 5).\
Link: <https://doi.org/10.1111/jbfa.12066>

Cultural indices (PD, UA, IND) Hofstede’s cultural dimensions: Power
Distance (PD), Uncertainty Avoidance (UA), and Individualism (IND),
obtained from Hofstede (2001) and the official Hofstede author database
(2015) for extended country coverage.\
Link:
<https://geerthofstede.com/research-and-vsm/dimension-data-matrix/>

Religious composition variables (PROT_PCT, CHRST_OTH, HINDU_PCT,
BUDH_PCT, ISLM_PCT, RELG_OTH) Percentage shares of religious affiliation
by country, taken from Mensah’s dataset as reported in Springer (Table
10). Link: <https://doi.org/10.1007/s10551-013-1696-0>

Importance of religion (RELIGION_IMPORTANT) Percentage of respondents
answering “Yes” to the question “Is religion an important part of your
daily life?”, from the Gallup World Poll (2009).\
Link:
<https://news.gallup.com/poll/142727/religiosity-highest-world-poorest-nations.aspx>

Market liquidity in 2008 (2002) (MARKET_LIQUIDITY2008) Average total
value of stocks traded as a percentage of GDP over the period 2005–2008
(1999-2002), obtained from the World Bank World Development Indicators
(WDI).\
Link:
<https://databank.worldbank.org/reports.aspx?source=world-development%20indicators#>

**Self-constructed variables**

Change in audit enforcement (ChAUDIT08_02) Difference between the audit
enforcement index in 2008 and 2002: ChAUDIT08_02 = AUDIT2008 −
AUDIT2002.

Change in market liquidity (DIF_LIQUID08_02) Difference between market
liquidity in 2008 and 2002: DIF_LIQUID08_02 = MARKET_LIQUIDITY2008 −
MARKET_LIQUIDITY2002.

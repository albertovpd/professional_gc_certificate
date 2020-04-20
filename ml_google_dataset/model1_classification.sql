-- before this create a datset called ecommerce

CREATE OR REPLACE MODEL `ecommerce.classification_model`
OPTIONS
(
model_type='logistic_reg',
labels = ['will_buy_on_return_visit']
)
AS

#standardSQL
SELECT
  * EXCEPT(fullVisitorId)
FROM

  # features
  (SELECT
    fullVisitorId,
    IFNULL(totals.bounces, 0) AS bounces,
    IFNULL(totals.timeOnSite, 0) AS time_on_site
  FROM
    `data-to-insights.ecommerce.web_analytics`
  WHERE
  -- this is for separate between training, crossvalidation and set
    totals.newVisits = 1
    AND date BETWEEN '20160801' AND '20170430') # train on first 9 months
  JOIN
  (SELECT
    fullvisitorid,
    IF(COUNTIF(totals.transactions > 0 AND totals.newVisits IS NULL) > 0, 1, 0) AS will_buy_on_return_visit
  FROM
      `data-to-insights.ecommerce.web_analytics`
  GROUP BY fullvisitorid)
  USING (fullVisitorId)
;
-- once finished go to model

-- For classification problems in ML, you want to minimize the False Positive Rate (predict that the user will 
--return and purchase and they don't) and maximize the True Positive Rate (predict that the user will return and 
--purchase and they do).

-- This relationship is visualized with a ROC (Receiver Operating Characteristic) curve like the one shown here, 
--where you try to maximize the area under the curve or AUC


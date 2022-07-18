CREATE TABLE `pandasfraude.detectionfraud.fraude_notnull` AS
SELECT 
  gender, 
  city,
  state,
  city_pop,
  job,
  profile,
  category,
  amt,
  is_fraud,
  merchant
FROM
  `pandasfraude.detectionfraud.fraude`
WHERE is_fraud IS NOT NULL

CREATE OR REPLACE MODEL `detectionfraud.fraudelogreg`
OPTIONS(model_type='logistic_reg',AUTO_CLASS_WEIGHTS = TRUE) AS
SELECT
  * EXCEPT(state, city_pop, is_fraud),
  is_fraud AS label,
FROM
  `detectionfraud.fraude_notnull`
ORDER BY
  profile
LIMIT 24906;

SELECT * FROM  ML.TRAINING_INFO(MODEL `detectionfraud.fraudelogreg`)

SELECT
  *
FROM
  ML.EVALUATE(
    MODEL `detectionfraud.fraudelogreg`, (
      SELECT
        * EXCEPT(state, city_pop, is_fraud),
        is_fraud AS label,
      FROM
        `detectionfraud.fraude_notnull`
      ORDER BY profile DESC
      LIMIT 4395
    )
);

SELECT
  *
FROM
  ml.PREDICT(
    MODEL `detectionfraud.fraudelogreg`,(
    SELECT
      * EXCEPT(state, city_pop)
    FROM
      `detectionfraud.fraude_notnull`
  )
);

SELECT * FROM ML.WEIGHTS(MODEL `detectionfraud.fraudelogreg`)

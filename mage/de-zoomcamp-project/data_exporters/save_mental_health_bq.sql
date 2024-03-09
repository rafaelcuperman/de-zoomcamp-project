-- Docs: https://docs.mage.ai/guides/sql-blocks
-- SELECT * FROM {{ df_1 }}

CREATE OR REPLACE EXTERNAL TABLE `de-zoomcamp-project-416612.mental_health.mental_health`
OPTIONS (
  format = 'CSV',
  uris = ['gs://mental-health-bucket/mental_health.csv']
);
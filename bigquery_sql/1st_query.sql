CREATE OR REPLACE TABLE
`<mygoogleproject>.<mygoogletable>.sentiment_analysis_160221` AS
-- list of themes http://data.gdeltproject.org/api/v2/guides/LOOKUP-GKGTHEMES.TXT
SELECT
-- this select is just to avoid nulls regarding news_in_Spain
  *
FROM (
  SELECT
    EXTRACT (date
    FROM
      PARSE_TIMESTAMP('%Y%m%d%H%M%S',CAST(date AS string))) AS Date,
    SourceCommonName, -- id of media
    	DocumentIdentifier, -- full url
    ROUND(CAST(SPLIT(V2Tone, ",") [
      OFFSET
        (0)] AS FLOAT64),2) AS Sentiment, -- gdelt sentiment
    (CASE
        WHEN V2Themes LIKE "%UNEMPLOYMENT%" THEN "desempleo"
        else null
    END
      ) AS news_in_Spain,
  --  v2counts,
  --  v2locations
  FROM
    `gdelt-bq.gdeltv2.gkg_partitioned`
  WHERE
    v2counts LIKE '%#SP#%'  -- my kind-of-filter by country
    AND counts LIKE '%#SP#%'
    AND V2Locations LIKE '%#SP#%'
    AND DATE(_PARTITIONTIME) >= "2019-01-01" and date(_partitiontime) < "2021-01-15" --i'll append weekly from this day
    AND ( SourceCommonName IN (
      SELECT
        spanish_newspapers
      FROM
        `<mygoogleproject>.<mygoogletable>.spanish_newspapers_SourceCommonName_160620`)))
WHERE
  news_in_Spain IS NOT NULL 
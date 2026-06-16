-- STEP 1: Insert new records
INSERT INTO DimAsset (
    AssetID,
    AssetName,
    AssetValue,
    EffectiveFrom,
    EffectiveTo,
    IsCurrent
)
SELECT
    s.AssetID,
    s.AssetName,
    s.AssetValue,
    GETDATE() AS EffectiveFrom,
    NULL AS EffectiveTo,
    1 AS IsCurrent
FROM Stage_Asset s
LEFT JOIN DimAsset d
    ON s.AssetID = d.AssetID
WHERE d.AssetID IS NULL;


-- STEP 2: Handle changes (expire old records)
UPDATE d
SET
    d.EffectiveTo = GETDATE(),
    d.IsCurrent = 0
FROM DimAsset d
INNER JOIN Stage_Asset s
    ON d.AssetID = s.AssetID
WHERE d.IsCurrent = 1
AND (
    d.AssetName <> s.AssetName
    OR d.AssetValue <> s.AssetValue
);

-- STEP 3: Insert new version of changed records
INSERT INTO DimAsset (
    AssetID,
    AssetName,
    AssetValue,
    EffectiveFrom,
    EffectiveTo,
    IsCurrent
)
SELECT
    s.AssetID,
    s.AssetName,
    s.AssetValue,
    GETDATE(),
    NULL,
    1
FROM Stage_Asset s
INNER JOIN DimAsset d
    ON s.AssetID = d.AssetID
WHERE d.IsCurrent = 0
AND d.EffectiveTo IS NOT NULL;

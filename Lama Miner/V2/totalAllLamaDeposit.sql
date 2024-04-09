SELECT
    Date,
    Total_Deposit,
    SUM(Total_Deposit) OVER () AS Total_All_Deposits
FROM (
    SELECT
        DATE(block_time) AS Date,
        SUM(TRY_CAST(REPLACE(value, ',', '') AS DECIMAL(38, 0))) AS Total_Deposit
    FROM (
        SELECT
            block_time,
            "from" AS Address,
            Action,
            hash,
            SUBSTRING(TRY_CAST(t2.value AS VARCHAR), 1, LENGTH(TRY_CAST(t2.value AS VARCHAR)) - 18) AS value
        FROM (
            SELECT
                block_time,
                "from",
                CASE
                    WHEN SUBSTRING(TRY_CAST(data AS VARCHAR), 1, 10) = '0xf7e24b67'
                    THEN 'Deposit LAMA'
                    ELSE TRY_CAST(data AS VARCHAR)
                END AS Action,
                hash
            FROM avalanche_c.transactions
            WHERE
                "to" = 0x1f4292cf1c0fda5ef1c3e9d1e59c13bd1808dd10 
                AND SUBSTRING(TRY_CAST(data AS VARCHAR), 1, 10) = '0xf7e24b67'
        ) AS t1
        JOIN (
            SELECT
                evt_tx_hash,
                MAX(value) AS value
            FROM erc20_avalanche_c.evt_transfer
            WHERE
                "to" = 0x1f4292cf1c0fda5ef1c3e9d1e59c13bd1808dd10 
            GROUP BY
                evt_tx_hash
        ) AS t2
        ON t1.hash = t2.evt_tx_hash
    ) AS deposits
    GROUP BY
        DATE(block_time)
) AS daily_deposits
ORDER BY
    Date DESC;

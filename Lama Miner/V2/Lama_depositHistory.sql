SELECT
    TIME,
    Address,
    Action,
    HASH,
    SUBSTRING(CAST(value AS VARCHAR), 1, LENGTH(CAST(value AS VARCHAR)) - 18) AS VALUE
FROM
    (
        SELECT
            t1.TIME,
            t1.Address,
            t1.Action,
            t1.HASH,
            t2.value AS value
        FROM
            (
                SELECT
                    block_time AS TIME,
                    "from" AS Address,
                    CASE 
                        WHEN SUBSTRING(CAST(data AS VARCHAR), 1, 10) = '0xf7e24b67' THEN 'Deposit LAMA' 
                        ELSE CAST(data AS VARCHAR) 
                    END AS Action,
                    hash AS HASH
                FROM
                    avalanche_c.transactions
                WHERE
                    "to" = 0x1f4292cf1c0fda5ef1c3e9d1e59c13bd1808dd10 
                    AND SUBSTRING(CAST(data AS VARCHAR), 1, 10) = '0xf7e24b67'
                ORDER BY
                    block_time DESC
                LIMIT 2000
            ) AS t1
        JOIN
            (
                SELECT 
                    evt_tx_hash,
                    MAX(value) AS value
                FROM 
                    erc20_avalanche_c.evt_transfer
                WHERE    
                    "to" = 0x1f4292cf1c0fda5ef1c3e9d1e59c13bd1808dd10 
                GROUP BY
                    evt_tx_hash
                ORDER BY
                    MAX(evt_block_time) DESC
                LIMIT 2000
            ) AS t2
        ON
            t1.HASH = t2.evt_tx_hash
    ) AS result
ORDER BY
    TIME DESC;

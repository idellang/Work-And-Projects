SELECT 
    bar.country_name,
    bar.vendor_name,
    ROUND(baz.total_gmv, 2)AS total_gmv
FROM
    (SELECT 
        foo.country_name,
        MAX(foo.total_gmv) AS total_gmv
    FROM
        (SELECT 
            orders.country_name,
            SUM(gmv_local) AS total_gmv
        FROM 
            `food-panda-exam.FoodPandaData.orders` AS orders
        JOIN
            `food-panda-exam.FoodPandaData.vendors` AS vendors
        ON
            orders.vendor_id = vendors.id
        GROUP BY
            orders.country_name,
            vendors.vendor_name) AS foo
    GROUP BY
        foo.country_name) AS baz
LEFT JOIN
    (SELECT 
        orders.country_name,
        vendors.vendor_name,
        SUM(gmv_local) AS total_gmv
    FROM 
        `food-panda-exam.FoodPandaData.orders` AS orders
    JOIN
        `food-panda-exam.FoodPandaData.vendors` AS vendors
    ON
        orders.vendor_id = vendors.id
    GROUP BY
        orders.country_name,
        vendors.vendor_name) AS bar
ON
    baz.country_name = bar.country_name
AND 
    baz.total_gmv = bar.total_gmv
	
	
	
--top 2 per year per country 
SELECT
    baz.year,
    baz.country_name,
    baz.vendor_name,
    ROUND(baz.total_gmv, 2) AS total_gmv
FROM
    (SELECT 
        foo.year,
        foo.country_name,
        foo.vendor_name,
        foo.total_gmv,
        RANK() OVER (PARTITION BY foo.year, foo.country_name ORDER BY foo.total_gmv DESC) AS rank
    FROM 
        (SELECT 
            EXTRACT(year FROM date_local) AS year,
            orders.country_name,
            vendors.vendor_name,
            SUM(gmv_local) AS total_gmv
        FROM 
            `food-panda-exam.FoodPandaData.orders` AS orders
        JOIN
            `food-panda-exam.FoodPandaData.vendors` AS vendors
        ON
            vendors.id = orders.vendor_id
        GROUP BY 
            EXTRACT(year FROM date_local),
            orders.country_name,
            vendors.vendor_name) AS foo) AS baz
WHERE rank IN (1,2)
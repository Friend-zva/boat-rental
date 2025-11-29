-- ========== Requests ==========
\echo '=== Текущая аренда ==='
SELECT
    lessee,
    unit_type,
    info,
(rental_date +(rental_hours || ' hours')::interval) AS rental_end
FROM
    V_Rental_Details
WHERE (rental_date +(rental_hours || ' hours')::interval) > CURRENT_TIMESTAMP
ORDER BY
    rental_end DESC;

\echo '=== Свободные единицы сейчас + в ближайший час ==='
SELECT
    *
FROM
    GetFreeUnits(CURRENT_TIMESTAMP::timestamp)
UNION
SELECT
    *
FROM
    GetFreeUnits(CURRENT_TIMESTAMP::timestamp + INTERVAL '1 hour');

\echo '=== На сколько часов чаще арендуют ==='
SELECT
    hours_ AS rental_hours,
    COUNT(*) AS count
FROM
    Rental
GROUP BY
    hours_
ORDER BY
    count DESC;

\echo '=== Какую единицу чаще арендуют ==='
SELECT
    unit_id,
    COUNT(*) AS count
FROM
    Rental
GROUP BY
    unit_id
ORDER BY
    count DESC;

\echo '=== Какой тип единицы чаще арендуют ==='
SELECT
    tu.name_ AS type_unit,
    COUNT(*) AS count
FROM
    Rental r
    JOIN Unit u ON r.unit_id = u.id
    JOIN Type_Unit tu ON u.type_id = tu.id
GROUP BY
    tu.name_;

\echo '=== Самые дешевые единицы ==='
SELECT
    unit_id,
    price,
    degree_wear,
    CASE WHEN (rental_date +(rental_hours || ' hours')::interval) <= CURRENT_TIMESTAMP THEN
        'free'
    ELSE
        (rental_date +(rental_hours || ' hours')::interval)::text
    END AS rental_end
FROM
    V_Rental_Details
ORDER BY
    price DESC
LIMIT 10;

\echo '=== Самые качественные единицы ==='
SELECT
    unit_id,
    price,
    degree_wear,
    CASE WHEN (rental_date +(rental_hours || ' hours')::interval) < CURRENT_TIMESTAMP THEN
        'free'
    ELSE
        (rental_date +(rental_hours || ' hours')::interval)::text
    END AS rental_end
FROM
    V_Rental_Details
ORDER BY
    price DESC
LIMIT 10;

\echo '=== Свободные лодки дешевле 1000 ==='
SELECT
    unit_id,
    price,
    info AS seats,
    color
FROM
    V_Free_Units
WHERE
    unit_type = 'boat'
    AND price < 1000
ORDER BY
    price ASC;

\echo '=== ТОП-5 работников ==='
SELECT
    employee,
    rentals,
    ROUND(profit, 2) AS profit
FROM
    V_Employee_Stats
ORDER BY
    profit DESC
LIMIT 5;

\echo '=== ТОП-5 посетителей ==='
SELECT
    l.first_name,
    l.last_name,
    COUNT(*) AS count
FROM
    Rental r
    JOIN Lessee l ON r.lessee_id = l.id
GROUP BY
    r.lessee_id,
    l.first_name,
    l.last_name
ORDER BY
    count DESC
LIMIT 5;

\echo '=== Аренды за последнюю неделю ==='
SELECT
    lessee,
    unit_type,
    info,
    rental_date,
    rental_hours,
    price * rental_hours AS profit
FROM
    V_Rental_Details
WHERE
    rental_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY
    profit DESC;

\echo '=== Велосипеды конкретного производителя, доступные сейчас ==='
SELECT
    unit_id,
    price,
    degree_wear,
    info AS maker,
    color
FROM
    GetFreeUnits(CURRENT_TIMESTAMP::timestamp)
WHERE
    unit_type = 'water_bike'
    AND info = 'Yamaha'
ORDER BY
    price;

\echo '=== Некачественные единицы ==='
SELECT
    rental_id,
    lessee,
    unit_type,
    degree_wear,
    rental_date
FROM
    V_Rental_Details
WHERE
    degree_wear >= 80
ORDER BY
    degree_wear DESC;

-- ==========  Tests   ==========
\echo '=== Добавление работника ==='
\echo '= before ='
SELECT
    *
FROM
    Employee;

CALL AddEmployee('122', 'homka', '89780000122', 'Сибирь');

\echo '= after  ='
SELECT
    *
FROM
    Employee;

\echo '=== Удаление истории прокатов ==='
\echo '= before ='
SELECT
    *
FROM
    Rental;

INSERT INTO Rental(datetime_, hours_, unit_id, employee_id, lessee_id)
    VALUES ('2025-11-30 15:00', 1, 2, 1, 3);

\echo '= after  ='
SELECT
    *
FROM
    Rental;

\echo '=== Удаление пользователя ==='
DELETE FROM Lessee
WHERE id = 3;

\echo '=== Изменение опции единицы ==='
SELECT
    *
FROM
    Unit;

CALL UpdDelUnit('UPD', 8, 2500, 40, 'Scratched wing');

SELECT
    *
FROM
    Unit;


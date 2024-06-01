USE SAKILA;

-- 1. Calcular la duración media del alquiler (en días) para cada película:

SELECT 
    f.title AS "TITLE",
    AVG(DATEDIFF(r.return_date, r.rental_date)) AS AVG_RENTAL_DUR
FROM 
    rental r
JOIN 
    inventory i ON r.inventory_id = i.inventory_id
JOIN 
    film f ON i.film_id = f.film_id
GROUP BY 
    f.film_id
ORDER BY 
    AVG_RENTAL_DUR DESC
    
    LIMIT 10;
    
    -- Calcular el importe medio de los pagos para cada miembro del personal
    
    SELECT 
    s.staff_id AS STAFF_ID,
    s.first_name AS FNAME,
    s.last_name AS LNAME,
    AVG(p.amount) AS AVG_PAYMENT
FROM 
    staff s
JOIN 
    payment p ON s.staff_id = p.staff_id
GROUP BY 
    s.staff_id, s.first_name, s.last_name
ORDER BY 
    AVG_PAYMENT DESC;
    
    -- 3. Calcular los ingresos totales para cada cliente, mostrando el total acumulado dentro del historial de alquileres de cada cliente:
    
    SELECT 
    c.customer_id AS CUSTOMER_ID,
    c.first_name AS FNAME,
    c.last_name AS LNAME,
    SUM(p.amount) AS TOTAL_REV
FROM 
    customer c
JOIN 
    payment p ON c.customer_id = p.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
ORDER BY 
    TOTAL_REV DESC
    Limit 10;
    
    -- 4. Determinar el cuartil para las tarifas de alquiler de las películas
    /*
    In statistics, a quartile is a type of quantile that divides a set of data into four equal parts, each containing a quarter of the data points. These quartiles are:

First Quartile (Q1): The median of the lower half of the dataset (25th percentile).
Second Quartile (Q2): The median of the dataset (50th percentile).
Third Quartile (Q3): The median of the upper half of the dataset (75th percentile).
Quartiles are useful for understanding the distribution and spread of the data, particularly in identifying outliers and the data's central tendency.
 */
 
WITH rental_rates AS (
    SELECT title, rental_rate
    FROM film
),
sorted_rates AS (
    SELECT title, rental_rate,
           NTILE(4) OVER (ORDER BY rental_rate) AS quartile
    FROM rental_rates
)
SELECT title, rental_rate, quartile
FROM sorted_rates
ORDER BY quartile, rental_rate;

-- 5. Determinar la primera y última fecha de alquiler para cada cliente: 


SELECT 
    customer_id,
    MIN(rental_date) AS first_rental_date,
    MAX(rental_date) AS last_rental_date
FROM 
    rental
GROUP BY 
    customer_id
ORDER BY 
    customer_id;
    
    
    
    -- Other querry for curiosity 
    
    SELECT 
    customer_id,
    MIN(rental_date) AS first_rental_date,
    MAX(rental_date) AS last_rental_date,
    DATEDIFF(MAX(rental_date), MIN(rental_date)) AS rental_period_days
FROM 
    rental
GROUP BY 
    customer_id
ORDER BY 
    rental_period_days DESC;
    
    
-- ### 6. Calcular el rango de los clientes basado en el número de sus alquileres:

SELECT 
    customer_id,
    COUNT(rental_id) AS rental_count,
    RANK() OVER (ORDER BY COUNT(rental_id) DESC) AS rental_count_rank
FROM 
    rental
GROUP BY 
    customer_id
ORDER BY 
    rental_count_rank;
    
    -- 7. Calcular el total acumulado de ingresos por día para la categoría de películas 'Familiar':
    
    WITH daily_revenue AS (
    SELECT 
        c.name AS film_category,
        r.rental_date,
        SUM(p.amount) AS amount
    FROM 
        rental r
    JOIN 
        inventory i ON r.inventory_id = i.inventory_id
    JOIN 
        film_category fc ON i.film_id = fc.film_id
    JOIN 
        category c ON fc.category_id = c.category_id
    JOIN 
        payment p ON r.rental_id = p.rental_id
    WHERE 
        c.name = 'Family'
    GROUP BY 
        c.name, r.rental_date
)
SELECT 
    film_category,
    rental_date,
    amount,
    SUM(amount) OVER (ORDER BY rental_date) AS daily_revenue
FROM 
    daily_revenue
ORDER BY 
    rental_date;


-- ### 8. Asignar un ID único a cada pago dentro del historial de pagos de cada cliente:

SELECT 
    customer_id,
    payment_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_sequence_id
FROM 
    payment
ORDER BY 
    customer_id, payment_sequence_id;


-- 9. Calcular la diferencia en días entre cada alquiler y el alquiler anterior para cada cliente:



SELECT 
    customer_id,
    rental_id,
    rental_date,
    LAG(rental_date, 1) OVER (PARTITION BY customer_id ORDER BY rental_date) AS previous_rental_date,
    DATEDIFF(rental_date, LAG(rental_date, 1) OVER (PARTITION BY customer_id ORDER BY rental_date)) AS days_between_rentals
FROM 
    rental
ORDER BY 
    customer_id, days_between_rentals;

    
    
    



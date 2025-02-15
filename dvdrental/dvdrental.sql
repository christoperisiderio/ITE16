
-- 1. Action-packed romance
SELECT 
    film.title, 
    category.name AS category_name, 
    COUNT(rental.rental_id) AS rental_count
FROM 
    film
INNER JOIN 
    film_category ON film.film_id = film_category.film_id
INNER JOIN 
    category ON film_category.category_id = category.category_id
INNER JOIN 
    inventory ON film.film_id = inventory.film_id
INNER JOIN 
    rental ON inventory.inventory_id = rental.inventory_id
WHERE 
    category.name = 'Action'
GROUP BY 
    film.title, category.name
ORDER BY 
    rental_count DESC
LIMIT 5;

-- 2.Classics for couples
SELECT *
FROM (
    SELECT 
        film.title, 
        category.name AS category_name, 
        COUNT(rental.rental_id) AS rental_count,
        EXTRACT(YEAR FROM rental.rental_date) as year,
        EXTRACT(MONTH FROM rental.rental_date) as month,
        EXTRACT(DAY FROM rental.rental_date) as day
    FROM 
        film
    INNER JOIN 
        film_category ON film.film_id = film_category.film_id
    INNER JOIN 
        category ON film_category.category_id = category.category_id
    INNER JOIN 
        inventory ON film.film_id = inventory.film_id
    INNER JOIN 
        rental ON inventory.inventory_id = rental.inventory_id
    GROUP BY 
        film.title, category.name, year, month, day
) subquery
WHERE 
    day = 14 AND month = 2 AND year < 2007
ORDER BY 
    rental_count DESC
LIMIT 3;

-- 3. Family-friendly fun
SELECT 
    film.title, 
    category.name AS category_name, 
    COUNT(rental.rental_id) AS rental_count
FROM 
    film
INNER JOIN 
    film_category ON film.film_id = film_category.film_id
INNER JOIN 
    category ON film_category.category_id = category.category_id
INNER JOIN 
    inventory ON film.film_id = inventory.film_id
INNER JOIN 
    rental ON inventory.inventory_id = rental.inventory_id
WHERE 
     category.name='Children' OR category.name='Animation'
GROUP BY 
    film.title, category.name
ORDER BY 
    rental_count DESC
LIMIT 5;


-- 4. Hidden Gems
WITH global_avg AS (
    SELECT 
        AVG(rental_count) AS avg_rental_count
    FROM (
        SELECT 
            COUNT(r.rental_id) AS rental_count
        FROM 
            rental r
        INNER JOIN 
            inventory i ON r.inventory_id = i.inventory_id
        GROUP BY 
            i.film_id
    ) subquery
)
SELECT 
    film.title,
    film.rental_rate,
    category.name AS category_name, 
    COUNT(rental.rental_id) AS rental_count,
    ROUND((SELECT avg_rental_count FROM global_avg), 2) AS average_rental_count
FROM 
    film
INNER JOIN 
    film_category ON film.film_id = film_category.film_id
INNER JOIN 
    category ON film_category.category_id = category.category_id
INNER JOIN 
    inventory ON film.film_id = inventory.film_id
INNER JOIN 
    rental ON inventory.inventory_id = rental.inventory_id
WHERE 
    film.rental_rate > 4.0
GROUP BY 
    film.title, film.rental_rate, category.name
HAVING 
    COUNT(rental.rental_id) < (SELECT avg_rental_count FROM global_avg)
ORDER BY 
    rental_count DESC
LIMIT 5;



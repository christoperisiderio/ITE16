
-- 1. Action-packed romance
-- Retrieve the top 5 most rented action films.
-- This query joins multiple tables to calculate the rental count for each action film.
SELECT
    film.title, -- The title of the film.
    category.name AS category_name, -- The category of the film (Action in this case).
    COUNT(rental.rental_id) AS rental_count -- The total number of rentals for the film.
FROM
    film
INNER JOIN
    film_category ON film.film_id = film_category.film_id -- Links films with their respective categories.
INNER JOIN
    category ON film_category.category_id = category.category_id -- Retrieves the category name.
INNER JOIN
    inventory ON film.film_id = inventory.film_id -- Links films with inventory.
INNER JOIN
    rental ON inventory.inventory_id = rental.inventory_id -- Links inventory with rentals.
WHERE
    category.name = 'Action' -- Filter for action films.
GROUP BY
    film.title, category.name -- Group results by film title and category name.
ORDER BY
    rental_count DESC -- Sort films by rental count in descending order.
LIMIT 5; -- Return only the top 5 results.

-- 2.Classics for couples
-- Retrieve the top 3 most rented films for Valentine's Day (February 14) before 2007.
-- This query extracts the year, month, and day from the rental date to filter rentals by specific dates.
SELECT *
FROM (
    SELECT
        film.title, -- The title of the film.
        category.name AS category_name, -- The category of the film.
        COUNT(rental.rental_id) AS rental_count, -- The total number of rentals for the film.
        EXTRACT(YEAR FROM rental.rental_date) as year, -- Extract the year from the rental date.
        EXTRACT(MONTH FROM rental.rental_date) as month, -- Extract the month from the rental date.
        EXTRACT(DAY FROM rental.rental_date) as day -- Extract the day from the rental date.
    FROM
        film
    INNER JOIN
        film_category ON film.film_id = film_category.film_id -- Links films with their respective categories.
    INNER JOIN
        category ON film_category.category_id = category.category_id -- Retrieves the category name.
    INNER JOIN
        inventory ON film.film_id = inventory.film_id -- Links films with inventory.
    INNER JOIN
        rental ON inventory.inventory_id = rental.inventory_id -- Links inventory with rentals.
    GROUP BY
        film.title, category.name, year, month, day -- Group results by film title, category, and rental date components.
) subquery
WHERE
    day = 14 AND month = 2 AND year < 2007 -- Filter for Valentine's Day rentals before 2007.
ORDER BY
    rental_count DESC -- Sort films by rental count in descending order.
LIMIT 3; -- Return only the top 3 results.


-- 3. Family-friendly fun
-- Retrieve the top 5 most rented films in the "Children" or "Animation" categories.
-- This query calculates the rental count for family-friendly films.
SELECT
    film.title, -- The title of the film.
    category.name AS category_name, -- The category of the film.
    COUNT(rental.rental_id) AS rental_count -- The total number of rentals for the film.
FROM
    film
INNER JOIN
    film_category ON film.film_id = film_category.film_id -- Links films with their respective categories.
INNER JOIN
    category ON film_category.category_id = category.category_id -- Retrieves the category name.
INNER JOIN
    inventory ON film.film_id = inventory.film_id -- Links films with inventory.
INNER JOIN
    rental ON inventory.inventory_id = rental.inventory_id -- Links inventory with rentals.
WHERE
    category.name = 'Children' OR category.name = 'Animation' -- Filter for "Children" or "Animation" categories.
GROUP BY
    film.title, category.name -- Group results by film title and category name.
ORDER BY
    rental_count DESC -- Sort films by rental count in descending order.
LIMIT 5; -- Return only the top 5 results.


-- 4. Hidden Gems
-- Retrieve films with high rental rates (>4.0) that are rented less than the global average rental count.
-- This query calculates the global average rental count and identifies less popular, high-quality films.
WITH global_avg AS (
    -- Calculate the global average rental count.
    SELECT
        AVG(rental_count) AS avg_rental_count
    FROM (
        SELECT
            COUNT(r.rental_id) AS rental_count -- The total number of rentals for each film.
        FROM
            rental r
        INNER JOIN
            inventory i ON r.inventory_id = i.inventory_id -- Links rentals with inventory.
        GROUP BY
            i.film_id -- Group results by film.
    ) subquery
)
SELECT
    film.title, -- The title of the film.
    film.rental_rate, -- The rental rate of the film.
    category.name AS category_name, -- The category of the film.
    COUNT(rental.rental_id) AS rental_count, -- The total number of rentals for the film.
    ROUND((SELECT avg_rental_count FROM global_avg), 2) AS average_rental_count -- The global average rental count (rounded to 2 decimal places).
FROM
    film
INNER JOIN
    film_category ON film.film_id = film_category.film_id -- Links films with their respective categories.
INNER JOIN
    category ON film_category.category_id = category.category_id -- Retrieves the category name.
INNER JOIN
    inventory ON film.film_id = inventory.film_id -- Links films with inventory.
INNER JOIN
    rental ON inventory.inventory_id = rental.inventory_id -- Links inventory with rentals.
WHERE
    film.rental_rate > 4.0 -- Filter for films with rental rates higher than 4.0.
GROUP BY
    film.title, film.rental_rate, category.name -- Group results by film title, rental rate, and category name.
HAVING
    COUNT(rental.rental_id) < (SELECT avg_rental_count FROM global_avg) -- Filter for films rented less than the global average rental count.
ORDER BY
    rental_count DESC -- Sort films by rental count in descending order.
LIMIT 5; -- Return only the top 5 results.

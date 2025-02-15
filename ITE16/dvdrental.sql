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



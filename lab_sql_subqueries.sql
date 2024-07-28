USE sakila;

-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT f.title, COUNT(i.inventory_id)
FROM film AS f
JOIN inventory as i
ON f.film_id = i.film_id
WHERE f.title = 'HUNCHBACK IMPOSSIBLE';
-- List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT f.title, ROUND(AVG(f.length),2) AS 'Average'
FROM film as f
GROUP BY f.title
HAVING Average > (SELECT ROUND(AVG(f.length),2) AS 'Average1' FROM film AS f);
-- Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT CONCAT(a.first_name, ' ', a.last_name) AS 'ACTOR', f.title
FROM actor AS a
JOIN film_actor AS fa 
ON a.actor_id = fa.actor_id
JOIN film as f
ON f.film_id = fa.film_id
WHERE f.title = 'ALONE TRIP';

SELECT CONCAT(a.first_name, ' ', a.last_name) AS 'ACTOR', subquery.title
FROM actor AS a
JOIN (
    SELECT fa.actor_id, f.title
    FROM film_actor AS fa
    JOIN film AS f
    ON f.film_id = fa.film_id
    WHERE f.title = 'ALONE TRIP'
) AS subquery
ON a.actor_id = subquery.actor_id;
-- ales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title, ca.name AS 'CATEGORY'
FROM film AS f
JOIN film_category AS fa
ON f.film_id = fa.film_id
JOIN category AS ca
ON fa.category_id = ca.category_id
WHERE ca.name = 'Family';
-- Retrieve the name and email of customers from Canada using both subqueries and joins. 
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customers_name, c.email,
       (SELECT co.country
        FROM country AS co
        WHERE co.country_id =
              (SELECT ci.country_id
               FROM city AS ci
               WHERE ci.city_id = a.city_id)
       ) AS country
FROM customer AS c
JOIN address AS a
ON c.address_id = a.address_id
WHERE a.city_id IN (
    SELECT ci.city_id
    FROM city AS ci
    WHERE ci.country_id = (
        SELECT co.country_id
        FROM country AS co
        WHERE co.country = "Canada"
    )
);
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.
-- Determine which films were starred by the most prolific actor in the Sakila database.
SELECT f.title, fa.actor_id
FROM film AS f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
);
-- Find the films rented by the most profitable customer in the Sakila database. 
SELECT f.title, cu.customer_id FROM film AS f
JOIN inventory AS i 
ON f.film_id = i.film_id
JOIN rental as r
ON i.inventory_id = r.inventory_id
JOIN customer as cu
ON r.customer_id = cu.customer_id
WHERE cu.customer_id = (SELECT cu.customer_id FROM customer AS cu
JOIN payment AS pa
ON pa.customer_id = cu.customer_id
GROUP BY cu.customer_id
ORDER BY SUM(pa.amount) DESC LIMIT 1);
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.
WITH client_totals AS (
    SELECT customer_id AS client_id, SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
),
average_total AS (
    SELECT AVG(total_amount_spent) AS avg_total_amount_spent
    FROM client_totals
)
SELECT client_totals.client_id, client_totals.total_amount_spent
FROM client_totals
JOIN average_total
ON client_totals.total_amount_spent > average_total.avg_total_amount_spent;
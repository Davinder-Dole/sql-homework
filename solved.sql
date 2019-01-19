use sakila;

#Display the first and last names of all actors from the table `actor`.
Select first_name,last_name from actor;

#Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
Select concat((first_name),' ',upper(last_name)) as ActorName from actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
Select actor_id,first_name,last_name from actor where first_name='Joe';

#Find all actors whose last name contain the letters `GEN`:
select * from actor where last_name like "%gen%" ;

#Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select last_name,first_name from actor where last_name like "%li%" ;

#* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id,country from country where country IN ('Afghanistan', 'Bangladesh', 'China');

# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor ADD description BLOB;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP COLUMN description;

# 4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(last_name) as No_Of_Persons_having_this_last_name 
from actor group by last_name;

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name,count(last_name) as No_Of_Persons_having_this_last_name 
from actor group by last_name having (count(last_name)>1) ;

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor SET first_Name = 'HARPO' WHERE first_Name="Groucho" and last_name="williams";

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_Name = "Groucho" where first_Name= 'HARPO';


# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
show create table address;

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select s.first_name,s.last_name,a.address from staff s
join address a on (s.address_id=a.address_id) ;

#6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT s.staff_id,first_name, last_name, SUM(amount) FROM staff s
INNER JOIN payment p ON s.staff_id = p.staff_id
WHERE p.payment_date LIKE '2005-08%' GROUP BY p.staff_id;

# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
Select f.film_id,f.title,count(actor_id) as Number_Of_Actors from film_actor 
inner join film f ON f.film_id=film_actor.film_id group by film_id;

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select count(*) from inventory where film_id
IN(select film_id from film where title="Hunchback Impossible");

#6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name,c.last_name,sum(amount) as Total_Paid_By_Customer
from payment p Join customer c on c.customer_id=p.customer_id 
group by p.customer_id order by c.last_name Asc;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select * from film where (title like 'K%') or (title like 'Q%') 
and language_id in(select language_id from language where name="English");

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select * from actor where actor_id in
(Select actor_id from film_actor where film_id in
(Select film_id from film where title="Alone Trip"));

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name,last_name,email from customer c
join address a on c.address_id=a.address_id
left join city ci on ci.city_id=a.city_id
left join country co on ci.country_id=co.country_id
where country="Canada";

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
Select * from film where film_id in
(select film_id from film_category where category_id in
(select category_id from category where name="Family"));

#7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(*) AS 'rent_count' FROM film, inventory, rental 
WHERE (film.film_id = inventory.film_id AND rental.inventory_id = inventory.inventory_id)
GROUP BY inventory.film_id ORDER BY COUNT(*) DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) AS 'Total_Amount' FROM store s, inventory i, rental r,payment p
WHERE (s.store_id = i.store_id AND i.inventory_id = r.inventory_id AND r.rental_id=p.rental_id)
GROUP BY  s.store_id;

#7g. Write a query to display for each store its store ID, city, and country.
select s.store_id,c.city,co.country from store s, country co,address a,city c 
where (s.address_id=a.address_id AND a.city_id=c.city_id AND c.country_id=co.country_id);

# 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, SUM(p.amount) AS gross_revenue FROM category c 
INNER JOIN film_category fc ON fc.category_id = c.category_id 
INNER JOIN inventory i ON i.film_id = fc.film_id 
INNER JOIN rental r ON r.inventory_id = i.inventory_id 
RIGHT JOIN payment p ON p.rental_id = r.rental_id GROUP BY name 
ORDER BY gross_revenue DESC LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
Create view Top_Five_Genres AS
SELECT name, SUM(p.amount) AS gross_revenue FROM category c 
INNER JOIN film_category fc ON fc.category_id = c.category_id 
INNER JOIN inventory i ON i.film_id = fc.film_id 
INNER JOIN rental r ON r.inventory_id = i.inventory_id 
RIGHT JOIN payment p ON p.rental_id = r.rental_id GROUP BY name 
ORDER BY gross_revenue DESC LIMIT 5;

# 8b. How would you display the view that you created in 8a?
select * from Top_Five_Genres;

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
Drop View Top_Five_Genres;
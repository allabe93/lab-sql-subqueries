-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
-- With a subquery:
select count(inventory_id) from inventory where film_id in 
(select film_id from film where title = 'Hunchback Impossible');

-- Without a subquery, but with a join (adding 'film_id' and 'title' as the two first columns):
select f.film_id, f.title, count(i.inventory_id) 
from film f join inventory i
on f.film_id = i.film_id
where f.title = 'Hunchback Impossible' and f.film_id = 439; -- Here we have to hard code the film_id for the query to work.

-- 2. List all films whose length is longer than the average of all the films.
select title from sakila.film 
where length > (select
avg(length) from sakila.film);

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
-- Only with a subquery:
select actor_id from sakila.film_actor where film_id in 
(select film_id from sakila.film where title = 'Alone Trip');

-- With a join + a subquery (to add actor´s full names as well):
select fa.actor_id, concat(a.first_name,' ',a.last_name)
from film_actor fa join actor a using (actor_id)
where film_id in (select film_id from sakila.film where title = 'Alone Trip');

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- Only with subqueries:
select title from sakila.film 
where film_id in (select film_id from sakila.film_category
where category_id in (select category_id from sakila.category where name = 'family'));

-- With a join + a subquery (to add the name of the category as well):
select f.title, c.name 
from sakila.film f join sakila.film_category fa using (film_id)
join sakila.category c using (category_id)
where category_id in (select category_id from sakila.category where name = 'family');

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
-- With subqueries:
select concat(first_name,' ',last_name), email from sakila.customer
where address_id in (select address_id from sakila.address 
where city_id in (select city_id from sakila.city
where country_id in (select country_id from sakila.country where country = 'Canada'))); 

-- With a join (here I am adding 'country' as a fourth column):
select concat(cu.first_name,' ',cu.last_name), cu.email, co.country
from customer cu join address using (address_id)
join city using (city_id)
join country co using (country_id)
where country = 'Canada';

-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
select title from sakila.film
where film_id in (select film_id from sakila.film_actor
where actor_id = (select actor_id from sakila.film_actor
group by actor_id order by count(film_id) desc limit 1));

-- 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
select title from film where film_id in (select film_id from inventory
where inventory_id in (select inventory_id from rental
where rental_id in (select rental_id from payment
where customer_id = (select c.customer_id
from customer c join rental r using (customer_id)
join payment p using (customer_id)
group by c.customer_id order by sum(p.amount) desc
limit 1)))); 

-- 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
select c.customer_id, concat(first_name, ' ', last_name) as customer_name, sum(p.amount) as total_amount_spent 
from customer c 
join payment p on c.customer_id = p.customer_id 
group by c.customer_id, concat(first_name, ' ', last_name)
having total_amount_spent > (
select avg(total_amount_spent) 
from (select customer_id, SUM(amount) as total_amount_spent 
from payment b group by customer_id) as b)
order by total_amount_spent asc;


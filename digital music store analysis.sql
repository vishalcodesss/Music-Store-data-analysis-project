create database musicstore;

use musicstore;
select * from album2;
select * from employee;

-- Question set 1 - [Easy]

-- Q1. Who is the senior most employee based on job title
 
select * from employee
order by levels desc
limit 1;

-- Q2.  Which countries have the most invoices

select billing_country, count(*) as invoice_count
from invoice
group by billing_country
order by invoice_count desc;

-- Q3. What are the top 3 values of total invoice

select total
from invoice
order by total desc
limit 3;

 /*
 Q4. Which city has the best customers? We would like to throw a
promotional Music Festival in the city we made the most money. Write a
query that returns one city that has the highest sum of invoice totals.
Return both the city name & sum of all invoice totals
*/

select billing_city, sum(total) as invoice_totals
from invoice
group by billing_city
order by invoice_totals desc
limit 1;

/*
Q5: Who is the best customer? The customer who has spent the most
money will be declared the best customer. Write a query that returns
the person who has spent the most money.
*/
select i.customer_id, concat(c.first_name, " ", c.last_name) as customer_name, sum(i.total) as total_amount
from invoice i
join customer c
on i.customer_id = c.customer_id
group by i.customer_id, customer_name
order by total_amount desc
limit 1;


-- Question set 2 - [Moderate]
/*
Q1: Write query to return the email, first name, last name, & Genre
of all Rock Music listeners. Return your list ordered alphabetically
by email starting with A
*/
select distinct c.email, c.first_name, c.last_name, g.name
from genre g
join track t on g.genre_id = t.genre_id
join invoice_line il on t.track_id = il.track_id
join invoice i on il.invoice_id = i.invoice_id
join customer c on i.customer_id = c.customer_id
where g.genre_id = 1
order by email;

/*
Q2: Let's invite the artists who have written the most rock music in
our dataset. Write a query that returns the Artist name and total
track count of the top 5 rock bands
*/

select ar.artist_id, ar.name, count(t.name) as track_count
from artist ar
join album2 al on ar.artist_id = al.artist_id
join track t on al.album_id = t.album_id
join genre g on t.genre_id = g.genre_id
where g.name like 'Rock'
group by ar.artist_id, ar.name
order by track_count desc
limit 5;

/*
Q3: Return all the track names that have a song length longer than
the average song length. Return the Name and length in seconds for
each track. Order by the song length with the longest songs listed first.
*/

select name, (milliseconds/1000) as track_length 
from track
where milliseconds > (select avg(milliseconds) from track)
order by track_length desc;


-- Question set 3 - [Advanced]

/*
Q1: Find how much amount spent by each customer on artists? Write a
query to return customer name, artist name and total spent
*/

select c.customer_id,
		concat(c.first_name, " ", c.last_name) as full_name, 
        ar.name as artist_name, 
        round(sum(il.unit_price * il.quantity),2) as total_amount_spent
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album2 a on t.album_id = a.album_id
join artist ar on a.artist_id = ar.artist_id
group by 1,2,3
order by 4 desc;

/*
Q2: We want to find out the most popular music Genre for each country.
We determine the most popular genre as the genre with the highest
amount of purchases. Write a query that returns each country along with
the top Genre. For countries where the maximum number of purchases
is shared return all Genres.
*/

WITH popular_genre as(
	select c.country, g.name, g.genre_id, count(il.quantity) as purchases,
    row_number() over(partition by c.country order by count(il.quantity) desc) as Row_no
    from customer c
    join invoice i on c.customer_id = i.customer_id
    join invoice_line il on i.invoice_id = il.invoice_id
    join track t on t.track_id = il.track_id
    join genre g on t.genre_id = g.genre_id
    group by 1,2,3
    order by 1 , 4 desc
)

select *
from popular_genre
where Row_no = 1;

/*
Q3: Write a query that determines the customer that has spent the most
on music for each country. Write a query that returns the country along
with the top customer and how much they spent. For countries where
the top amount spent is shared, provide all customers who spent this
amount
*/

with top_customer_spent as (
	select c.country,c.customer_id, c.first_name, c.last_name, round(sum(i.total),2) as total_amount_spent,
    row_number() over (partition by c.country order by sum(i.total) desc) as rowno
    from customer c
    join invoice i on c.customer_id = i.customer_id
    group by 1,2,3,4
    order by 1, 5 desc
)
select * 
from top_customer_spent
where rowno = 1;
--Q.1:List of sellers selling car model CAR001 or CAR002 (Cars are to be purchased so need to find unsold cars).

select s.sellerid, s.seller_fname, s.seller_lname, ac.carid, c.car_name, c.model
from availablecars ac
natural join car c
join (
    select mid, sellerid from new_car where issold = false
    union
    select mid, sellerid from old_car where issold = false
) as unsold 
on ac.mid = unsold.mid
join seller s on unsold.sellerid = s.sellerid
where ac.carid in ('CAR001', 'CAR002');


--Q.2:Important Details for contact  of sellers (with price) selling car models CAR001,CAR002 and are from Gujarat.

select r1.sellerid, r1.seller_rating, r1.e_mail, r1.seller_fname, r1.seller_lname, nc.nprice from 
(select s.sellerid, s.seller_rating, s.e_mail, s.seller_fname, s.seller_lname from 
seller s where s.state = 'Gujarat') as r1
natural join new_car as nc
join availablecars on nc.mid = availablecars.mid
where nc.nprice > 900000 and nc.issold = false and availablecars.carid in ('CAR001','CAR002');


--Q.3: List of cars(models) whose company is Indian Or japanese and are avilable for purchase

select distinct cinfo.companyid, carid from
(select r2.companyid,r2.carid,ac.mid from  
(select car.companyid,car.carid from
(select companyid from company where country in ('India','Japan') )as r1
join car on car.companyid=r1.companyid) as r2
join 
availablecars as ac on ac.carid=r2.carid )as cinfo
join 
(select mid from availablecars a where mid not in 
(select mid from new_car union all select mid from old_car)) as accar 

 on cinfo.mid=accar.mid
 
--Q.4: List of OldCars whose Statecode is 'MH' ans series code is 'XY'

select * from old_car where statecode='MH' and seriescode='XY'


--Q.5: Statewise Count of OldCars with stateCode of respective state

select statecode,count(statecode) as number_of_cars from old_car group by statecode order by number_of_cars desc


--Q.6: Me being Seller with Seller ID ='SEL001', Give the list of users who have bought a car from me and also 
--have service order from me

select distinct r3.userid from 
(select mid, sellerid from 
(select mid, sellerid from new_car where sellerid = 'SEL001'
 union all
 select mid, sellerid from old_car where sellerid = 'SEL001') as r1
join 
market on r1.mid = market.itemid) as r2
join orders on orders.itemid = r2.mid
join 
(select distinct userid, serviceproviderid from service where service.serviceproviderid = 'SEL001') 
as r3 on r3.serviceproviderid = r2.sellerid;


--Q.7: Total sales for Each seller comprising total in Car and Accessories both.

select items.sellerid, sum(items.price * orders.quantity) as total_sales from 
(select mid as itemid, nprice as price, sellerid from new_car
 union 
 select mid as itemid, oprice as price, sellerid from old_car
 union 
 select aid as itemid, price, sellerid from accessories) as items
natural join orders
group by items.sellerid order by items.sellerid;


--Q.8: Total Sales Done Through the Car_Bazaar Platform

select sum(items.price * orders.quantity) as total_sales from 
(select mid as itemid, nprice as price, sellerid from new_car
 union 
 select mid as itemid, oprice as price, sellerid from old_car
 union 
 select aid as itemid, price, sellerid as sellerid from accessories) as items
natural join orders;



--Q.9: Total Stock Available on the Car_bazaar. Stock is measured per each carModel and ordered in Ascending order

select carid,count(carid) as qty from
(select ac.carid from market 
 join availablecars as ac on market.itemid = ac.mid
 where market.iscar = 'true' and market.itemid not in 
 (select itemid from orders)) as unsold_cars
group by carid order by qty asc;


--Q.10: Services user(i.e USR002) had used in the Last 6 Months

select s.mid, c.car_name, s.start_date, s.end_date, s.status, s.charges
from service s
join availablecars ac on s.mid=ac.mid
join car c on ac.carid=c.carid
where s.userid='USR002'
and s.start_date >= current_date-interval '6 months';


--Q.11: Top 5 users with most reviews

select userid,count(userid) as nos_reviews from review group by userid order by nos_reviews desc limit 5;


--Q.12: List of users who have Done the payment through Credit Card

select distinct userid from orders where payment_type='Credit Card';


--Q.13: Top 10 items in wishlist excluding oldcars

select r1.item_detail_id,count(r1.item_detail_id) as quantity from
(select carid as item_detail_id,ac.mid as itemid from availablecars as ac join new_car as nc on ac.mid=nc.mid  
union all
select adetailid as item_detail_id,aid as itemid from accessories) as r1
join wishlist on r1.itemid=wishlist.itemid group by r1.item_detail_id order by quantity desc limit 10;


--Q.14:Find Out Car which got more than 4 rating from User002's owned cars'

select *from car natural join availablecars
where mid in (select itemid from review where userid = 'USR002' and rating >= 4);


--Q.15: Find most purchased car from residents of Ahemdabad

select carid, car_name, model, count(*) as purchase_count
from orders join availablecars ac on itemid = mid natural join car 
where userid in ( select userid from users where city = 'Ahmedabad')
and itemid in ( select mid from market where iscar = true)
group by carid, car_name, model
order by purchase_count desc
limit 1;


--Q.16: Find the district in Gujarat with the most old cars available for sale

select district, count(*) as old_car_count
from old_car natural join seller
where "state" = 'Gujarat' and issold = false
group by district
order by old_car_count desc
limit 1;


--Q.17: Find The Cars being Sold By Mahrashtra's seller

select seller_fname,seller_lname, contact_no, car_name, model, district, city, "state"
from seller 
natural join seller_contact 
natural join old_car 
natural join availablecars 
natural join car 
where "state" = 'Maharashtra' and issold = false;


--Q.18: Most Sold Accessory from Year 2025

select adetailid, aname, count(*) as sold_count
from orders natural join market join accessories on itemid = aid natural join accessory_details
where extract(year from "Date") = 2025 group by adetailid, aname
order by sold_count desc
limit 1;


--Q.19: Top 3 Accessory Sellers with Highest Total Revenue (From Sold Accessories)

select sellerid, seller_fname, seller_lname, sum(price * quantity) as total_revenue
from seller natural join accessories  join market m on aid = itemid natural join orders
where iscar = false
group by sellerid, seller_fname, seller_lname
order by total_revenue desc
limit 3;


--Q.20: Monthly sales trends – Number of orders each month

select date_trunc('month', "Date") as month, count(*) as total_orders
from orders
group by month
order by month desc;


--Q.21: Top 3 cities with highest order volumes

select u.city, count(*) as orders
from orders o
join users u on o.userid=u.userid
group by u.city
order by orders desc
limit 3;


--Q.22: Top selling car companies by unit sold

select cmp.company_name, count(*) as cars_sold
from new_car nc
join availablecars ac on nc.mid=ac.mid
join car c on ac.carid = c.carid
join company cmp on c.companyid=cmp.companyid
where nc.issold=true
group by cmp.company_name
order by cars_sold desc limit 5;


--Q.23: Seller performance dashboard (i.e total cars sold and rating)

select s.sellerid, s.seller_fname, count(nc.mid)+count(oc.mid) as total_cars_sold, 
round(avg(s.seller_rating), 2) as avg_rating
from seller s
left join new_car nc on s.sellerid=nc.sellerid and nc.issold=true
left join old_car oc on s.sellerid=oc.sellerid and oc.issold=true
group by s.sellerid
order by total_cars_sold desc;


--Q.24: Most expensive item purchase of user (i.e USR002) 

select o.itemid, o."Date", o.payment_type,
( select nprice from new_car nc where nc.mid=o.itemid
union all
select oprice from old_car oc where oc.mid=o.itemid
union all
select price from accessories a where a.aid=o.itemid
limit 1
) as price
from orders o
join market m on o.itemid=m.itemid
where o.userid = 'USR002'
order by price desc
limit 1;


--Q.25: User's (i.e USR002) total spend on the platform.

select sum(cost) as total_spent from
(
select nc.nprice as cost
from orders o
join new_car nc on nc.mid=o.itemid
where o.userid='USR002'
union all

select oc.oprice as cost
from orders o
join old_car oc on oc.mid=o.itemid
where o.userid='USR002'
union all

select a.price*o.quantity as cost
from orders o
join accessories a on a.aid=o.itemid
where o.userid='USR002'
union all

select s.charges as cost
from service s
where s.userid='USR002'
) as total;


--Q.26: Compare available two new cars (i.e Scorpio-N and Punch)
 
select distinct c.carid,car_name,car_type,model,companyid,
year,transmission_type,seating_capacity,fuel_capacity,colour,fuel_type,
safety_rating,max_speed,mileage,air_bags,sunroof from car c
join availablecars ac on c.carid=ac.carid
join new_car nc on ac.mid=nc.mid
where nc.issold=false
and c.carid in ('CAR001', 'CAR002')


--Q.27: Top 10 higest safety rated new available cars

select distinct c.carid,car_name,car_type,model,c.companyid,
year,transmission_type,seating_capacity,fuel_capacity,colour,fuel_type,
c.safety_rating,max_speed,mileage,air_bags,sunroof
from new_car nc
join availablecars ac on nc.mid = ac.mid
join car c on ac.carid = c.carid
join company comp on c.companyid = comp.companyid
where nc.issold = false
order by c.safety_rating desc
limit 10;


--Q.28: Old availabe cars not used for more than 6 years and not driven more than 60000 KM

select * from old_car oc
join availablecars ac on oc.mid = ac.mid
join car c on ac.carid = c.carid
where oc.issold = false 
and oc.kmdriven <= 60000 
and oc.time_used <= 6;



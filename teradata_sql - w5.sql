week 5:
--q2;

select count(distinct sku) from skuinfo 
where brand = 'Polo fas' and (color = 'black' or size = 'XXL');

--q3;

select b.store, c.state,c.city from(select a.store, a.syear, a.smonth from 
(select distinct store, extract(year from saledate) as syear, extract(month from saledate) as smonth,
extract(day from saledate) as sday from trnsact) as a
group by a.store, a.syear, a.smonth
having count(*) = 11) as b
join store_msa c
on b.store = c.store;

--q4;
select a.sku, a.revenue12 - b.revenue11 from (select sku, extract(month from saledate) as smonth, sum(amt) as revenue12  from trnsact
where stype = 'P'
group by sku, smonth
having smonth = 12) as a
join
(select sku, extract(month from saledate) as smonth, sum(amt) as revenue11  from trnsact
where stype = 'P'
group by sku, smonth
having smonth = 11) as b
on a.sku = b.sku
order by 2 desc;

--q5;

select b.vendor, count(distinct b.sku) from skuinfo b 
join
(select distinct c.sku from skstinfo a 
right join trnsact c
on a.sku = c.sku and a.store = c.store
where c.stype = 'P' and a.sku is NULL) as d
on b.sku = d.sku
group by b.vendor
order by 2 desc;


--q6;

select a.sku, a.brand, b.sd from skuinfo a join
(select sku, stddev_samp(sprice) as sd from trnsact
where stype = 'P'
group by sku
having count(*) > 100) b
on a.sku = b.sku
order by 3 desc;

--q7;

select d.store, d.city, d.state from store_msa d join
(select a.store, b.drev12 - a.drev11 as differ from(
select store, extract(year from saledate) as syear,
extract(month from saledate) as smonth, count(distinct saledate) as sdays, sum(amt)/sdays as drev11 from trnsact
where stype = 'P'
group by store, syear, smonth
having smonth = 11) a join
(select store, extract(year from saledate) as syear,
extract(month from saledate) as smonth, count(distinct saledate) as sdays, sum(amt)/sdays as drev12 from trnsact
where stype = 'P'
group by store, syear, smonth
having smonth = 12) b
on a.store = b.store) as c
on c.store = d.store 
order by differ desc;

--q8;

select store, city, state, median(msa_income) from store_msa
group by store, state, city
order by 4 desc;

--q9;

select ingroup, (sum(amt)/count(distinct saledate))/count(distinct d.store) from (select store, (case when msa_income >=1 and msa_income <= 20000 then 'low'
            when msa_income >= 20001 and msa_income <= 30000 then 'med-low'
            when msa_income >= 30001 and msa_income <= 40000 then 'med-high'
            else 'high' end) AS ingroup from store_msa) c join (
select a.store, a.amt, a.saledate, a.stype from trnsact a 
join(
select store, extract(year from saledate) as syear, extract(month from saledate) as smonth from trnsact 
where stype = 'P' and saledate < '2005-08-01'
group by store, syear, smonth
having count(distinct saledate) > 20) b
on a.store = b.store and extract(year from a.saledate) = b.syear and extract(month from a.saledate) = b.smonth
where stype = 'P') d
on c.store = d.store
group by ingroup
order by 2 desc;

--q10;
select store, (case when msa_pop >= 1 and msa_pop <= 100000 then 'very small'
                   when msa_pop >= 100001 and msa_pop <= 200000 then 'small'
                   when msa_pop >= 200001 and msa_pop <= 500000 then 'med_small'
                   when msa_pop >= 500001 and msa_pop <= 1000000 then 'med_large'
                   when msa_pop >= 1000001 and msa_pop <= 5000000 then 'large'
                   else 'very_large' end) as popgroup from store_msa

select popgroup, (sum(amt)/count(distinct d.store))/count(distinct saledate) from (select store, (case when msa_pop >= 1 and msa_pop <= 100000 then 'very small'
                   when msa_pop >= 100001 and msa_pop <= 200000 then 'small'
                   when msa_pop >= 200001 and msa_pop <= 500000 then 'med_small'
                   when msa_pop >= 500001 and msa_pop <= 1000000 then 'med_large'
                   when msa_pop >= 1000001 and msa_pop <= 5000000 then 'large'
                   else 'very_large' end) as popgroup from store_msa) c join (
select a.store, a.amt, a.saledate, a.stype from trnsact a 
join(
select store, extract(year from saledate) as syear, extract(month from saledate) as smonth from trnsact 
where stype = 'P' and saledate < '2005-08-01'
group by store, syear, smonth
having count(distinct saledate) > 20) b
on a.store = b.store and extract(year from a.saledate) = b.syear and extract(month from a.saledate) = b.smonth
where stype = 'P') d
on c.store = d.store
group by popgroup
order by 2 desc;


--q11;

select d.store, d.dept, (e.drev12 - d.drev11) / d.drev11 as revper from
(select store, dept, extract(year from saledate) as syear, extract(month from saledate) as smonth,
sum(amt)/count(distinct saledate) as drev11 from (select store, amt, saledate, dept, stype from trnsact a join skuinfo b
on a.sku = b.sku) as c
WHERE STYPE = 'P'
group by store, dept, syear, smonth
having smonth = 11 and sum(amt) > 1000) d
join
(select store, dept, extract(year from saledate) as syear, extract(month from saledate) as smonth,
sum(amt)/count(distinct saledate) as drev12 from (select store, amt, saledate, dept, stype from trnsact a join skuinfo b
on a.sku = b.sku) as c
WHERE STYPE = 'P'
group by store, dept, syear, smonth
having smonth = 12 and sum(amt) > 1000) e
on d.store = e.store and d.dept = e.dept
ORDER BY 3 DESC;

select * from deptinfo 
where dept = 7205;

select CITY, state from store_msa
where store = 3403;

--q12;

select d.store, d.dept, (e.drev9 - d.drev8) as revper from
(select store, dept, extract(year from saledate) as syear, extract(month from saledate) as smonth,
sum(amt)/count(distinct saledate) as drev8 from (select store, amt, saledate, dept, stype from trnsact a join skuinfo b
on a.sku = b.sku) as c
WHERE STYPE = 'P'
group by store, dept, syear, smonth
having syear = 2004 and smonth = 8) d
join
(select store, dept, extract(year from saledate) as syear, extract(month from saledate) as smonth,
sum(amt)/count(distinct saledate) as drev9 from (select store, amt, saledate, dept, stype from trnsact a join skuinfo b
on a.sku = b.sku) as c
WHERE STYPE = 'P'
group by store, dept, syear, smonth
having syear = 2004 and smonth = 9) e
on d.store = e.store and d.dept = e.dept
ORDER BY 3;

select * from deptinfo 
where dept = 800;

select CITY, state from store_msa
where store = 9103;

--q13;

select d.store, d.dept, (e.num9 - d.num8) as numdif from
(select store, dept, extract(year from saledate) as syear, extract(month from saledate) as smonth,
sum(quantity) as num8 from (select store, amt, saledate, dept, stype,quantity from trnsact a join skuinfo b
on a.sku = b.sku) as c
WHERE STYPE = 'P'
group by store, dept, syear, smonth
having syear = 2004 and smonth = 8) d
join
(select store, dept, extract(year from saledate) as syear, extract(month from saledate) as smonth,
sum(quantity) as num9 from (select store, amt, saledate, dept, stype, quantity from trnsact a join skuinfo b
on a.sku = b.sku) as c
WHERE STYPE = 'P'
group by store, dept, syear, smonth
having syear = 2004 and smonth = 9) e
on d.store = e.store and d.dept = e.dept
ORDER BY 3;


select * from deptinfo 
where dept = 800;

select CITY, state from store_msa
where store = 9103;

--q14;

select d.smonth, count(d.store) from (select a.store, a.smonth from
(select store, extract(year from saledate) as syear, extract(month from saledate) as smonth, sum(amt)/count(distinct saledate) as drev from trnsact
where stype = 'P' and saledate < '2005-08-01'
group by store, syear, smonth) a
join (select store, min(b.drev) as midrev from (select store, extract(year from saledate) as syear, extract(month from saledate) as smonth, sum(amt)/count(distinct saledate) as drev from trnsact
where stype = 'P' and saledate < '2005-08-01'
group by store, syear, smonth) b
group by store) c
on a.store = c.store 
where a.drev = c.midrev) d
group by d.smonth
order by 2 desc;

--q15 Write a query that determines the month in which each store had its maximum number of sku units returned. During which
-- month did the greatest number of stores have their maximum number of sku units returned?;

select count(d.store), d.smonth from (select c.store, c.smonth from (select store, extract(year from saledate) as syear, extract(month from saledate) as smonth, sum(quantity)as rqt from trnsact
where stype = 'R' and saledate < '2005-08-01'
group by store, syear, smonth) c
join (select store, max(a.rqt) as maxrqt from
(select store, extract(year from saledate) as syear, extract(month from saledate) as smonth, sum(quantity)as rqt from trnsact
where stype = 'R' and saledate < '2005-08-01'
group by store, syear, smonth) a
group by store) b
on c.store = b.store
where c.rqt = b.maxrqt) d
group by d.smonth
order by 1 desc;



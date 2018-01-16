--week 3 quiz exercise;

select top 1 * from  trnsact;

-- q3;

Select saledate, sum(amt) from trnsact
group by saledate
order by 2 desc;

--q4;

select count(sku), deptdesc from deptinfo a
join skuinfo s
on a.dept = s.dept
group by deptdesc
order by 1 desc;

--q5;
select count(distinct sku) from trnsact;
select count(distinct sku) from skuinfo;
select count(distinct sku) from skstinfo;
select count(distinct sku) from deptinfo;

--q6;
select count(distinct a.sku) from skstinfo a left join skuinfo b 
on a.sku = b.sku
where b.sku is null;

--q7;

select count(*) from skstinfo;
select count(*) from skstinfo_fix;


select avg(profit) from (select sum(b.amt-b.quantity*a.cost) as profit from skstinfo a join trnsact b
on a.sku = b.sku and a.store = b.store
group by b.saledate
where stype = 'P') c;

--q8;

select COUNT(distinct MSA), MIN(MSA_POP), MAX(MSA_INCOME) from store_msa
where state = 'NC';

-- q9;

select a.dept,deptdesc,brand, style, color, sum(amt) as totalsale
from deptinfo a
join skuinfo b
on a.dept = b.dept
join trnsact c
on b.sku = c.sku
group by a.dept, deptdesc, brand, style, color
order by totalsale desc;

--q10;

select store, count(distinct sku) as countsku from skstinfo
group by store
having countsku > 180000;

--q11;

select distinct sku, style, size, vendor, packsize from skuinfo a
join deptinfo b
on a.dept = b.dept
where deptdesc = 'cop' and brand = 'federal' and color = 'rinse wash';

--q12;

select distinct a.sku, b.sku from skuinfo a left join skstinfo b
on a.sku = b.sku
where b.sku is NULL;

--q13;

select a.store, state, city, sum(amt) from store_msa a join trnsact b
on a.store = b.store
group by state, city, a.store
order by 4 desc;

--q15;

select distinct state, count(distinct store) as countstore from strinfo
group by state
having countstore > 10;


--q16;

select distinct c.retail from deptinfo a join skuinfo b
on a.dept = b.dept
join skstinfo c
on b.sku = c.sku
where deptdesc = 'reebok' and brand = 'skechers'
and color = 'wht/saphire';
 

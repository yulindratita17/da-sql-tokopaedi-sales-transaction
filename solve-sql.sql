
--ENG: define CTE for join all table to easy answer the problem or study case
--IDN: membuat CTE untuk menggabungkan semua tabel agar memudahkan menjawab masalah atau study case
with 
orders as
( 
	select 
		distinct od.*,
		sd.category,
		sd.sku_name,
		pd.payment_method 
	from order_detail od
	left join customer_detail cd on od.customer_id = cd.id
	left join sku_detail sd on od.sku_id = sd.id
	left join payment_detail pd on od.payment_id = pd.id
),

/*Nomor 1
ENG: During the transactions that took place during 2021, in which month was the total 
		transaction value the greatest? Use is_valid = 1 to filter transaction data.
		Source table: order_detail
		
IND: 	Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi
		(after_discount) paling besar? Gunakan is_valid = 1 untuk memfilter data transaksi.
		Source table: order_detail
*/

q1 as
(
	select 
		extract(month from order_date)  months,
		sum(after_discount) sum_afterdiscount
	from orders
	where 
		extract (year from order_date) = 2021
		and
		is_valid = 1
	group by extract(month from order_date)
	order by sum(after_discount) desc
	Limit 1
),

/*
Nomor 2
ENG:	During transactions in 2022, which category produced the greatest transaction value? 
		Use is_valid = 1 to filter transaction data.
		Source table: order_detail, sku_detail
		 
IND:	Selama transaksi pada tahun 2022, kategori apa yang menghasilkan nilai transaksi paling
		besar? Gunakan is_valid = 1 untuk memfilter data transaksi.
		Source table: order_detail, sku_detail
*/

q2 as
(
	select 
		category,
		round(sum(after_discount)) sum_afterdiscount
	from orders
	where 
		extract (year from order_date) = 2022
		and
		is_valid = 1
	group by category
	order by sum(after_discount) desc 
	Limit 1
),

/*
Nomor 3
ENG:	Compare the transaction value of each category in 2021 with 2022. Specify which categories 
		have an increase and which category have a decrease in the value of transactions from 2021 to 2022.
		Source table: order_detail, sku_detail

IND:	Bandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022.
		Sebutkan kategori apa saja yang mengalami peningkatan dan kategori apa yang mengalami
		penurunan nilai transaksi dari tahun 2021 ke 2022. Gunakan is_valid = 1 untuk memfilter data
		transaksi.
		Source table: order_detail, sku_detail		
*/

q3 as
(
	with 
	t_2021 as
	(
		select 
			category,
			round(sum(after_discount)) transaksi_2021
		from orders
		where 
			extract (year from order_date) = 2021
			and
			is_valid = 1
		group by category
	),
	t_2022 as
	(
		select 
			category,
			round(sum(after_discount)) transaksi_2022
		from orders
		where 
			extract (year from order_date) = 2022
			and
			is_valid = 1
		group by category
	)
	select 
		t_2021.category,
		transaksi_2021,
		transaksi_2022,
		(transaksi_2022 - transaksi_2021) selisih,
		case 
			when (transaksi_2022 - transaksi_2021) > 0 then 'Peningkatan'
			when (transaksi_2022 - transaksi_2021) < 0 then 'Penurunan'
			else 'Stagnan'
		end as keterangan
	from t_2021
	inner join t_2022 on t_2021.category = t_2022.category
	group by keterangan,t_2021.category, transaksi_2021, transaksi_2022
	order by 4 desc
),

/*
Nomor 4
ENG:	Show the top 5 most popular payment methods used during 2022
		(based on total unique order). Use is_valid = 1 to filter transaction data.
		Source table: order_detail, payment_method
		
IND:	Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022
		(berdasarkan total unique order). Gunakan is_valid = 1 untuk memfilter data transaksi.
		Source table: order_detail, payment_method
 */

q4 as
(
	select
		payment_method,
		count(distinct id) count_payment
	from orders
	where 
		payment_id in (select payment_id from orders)
		and
		is_valid = 1
		and 
		extract (year from order_date) = 2022
	group by payment_method
	order by count(id) desc 
	limit 5
),

/*Nomor 5
ENG:	Sort the 5 of these products according to the transaction value.
		1. Samsung
		2. Apple
		3. Sony
		4. Huawei
		5. Lenovo
		Use is_valid = 1 to filter transaction data.
		Source table: order_detail, sku_detail
		
IND:	Urutkan dari ke-5 produk ini berdasarkan nilai transaksinya.
		1. Samsung
		2. Apple
		3. Sony
		4. Huawei
		5. Lenovo
		Gunakan is_valid = 1 untuk memfilter data transaksi.
		Source table: order_detail, sku_detail
 */

q5 as
(
	select
        case 
            when LOWER(sku_name) like '%samsung%' then 'Samsung'
            when LOWER(sku_name) like '%apple%' or
            	 LOWER(sku_name) like '%iphone%' or
            	 LOWER(sku_name) like '%macbook%' or
            	 LOWER(sku_name) like '%ipad%' then 'Apple'
            when LOWER(sku_name) like '%sony%' then 'Sony'
            when LOWER(sku_name) like '%huawei%' then 'Huawei'
            when LOWER(sku_name) like '%lenovo%' then 'Lenovo'
        end as product_name,
        ROUND(SUM(after_discount)) AS total_sales
    from
        orders
    where
        is_valid = 1
    group by
        product_name
)

/*
ENG: 
DIRECTION: 	To find out the answers from each study case, 
			use the query select, then choose the number of the study case that you want to know the answer.
			example: select * from q1,
					 select * from q3
IND: 
PETUNJUK: 	untuk mengetahui jawaban dari setiap study case, 
			gunakan query select kemudian pilih nomer dari study case yang ingin diketahui jawabannya.
			contoh: select * from q1,
					select * from q3
*/

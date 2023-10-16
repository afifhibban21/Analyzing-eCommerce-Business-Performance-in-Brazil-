create table  geolocation_data

(geolocation_zip_code_prefix integer,
 geolocation_lat integer,
 geolocation_ing integer,
 geolocation_city character varying,
 geolocation_state character varying
);

create table if not exists order_items
(order_id character varying,
 order_item_id integer,
 product_id character varying,
 seller_id character varying,
 shipping_limit_date date,
 price integer,
 freight_value numeric
);

-- change data type 
alter table order_items
alter column price type numeric,
alter column shipping_limit_date type timestamp ;

create table order_payments

(order_id character varying,
 payment_sequential integer,
 payment_type character varying,
 payment_installments integer,
 payment_value numeric
);

create table order_reviews

(review_id character varying,
 order_id character varying,
 review_score integer,
 review_comment_title character varying,
 review_comment_message character varying,
 review_creation_date timestamp,
 review_answer_timestamp timestamp
);

create table orders_data

(order_id character varying,
 customer_id character varying,
 order_status character varying,
 order_purchase_timestamp timestamp,
 order_approved_at timestamp,
 order_delivered_carrier_date timestamp,
 order_delivered_customer_date timestamp,
 order_estimated_delivery_date timestamp
);

create table product_dataset

(product_id character varying,
 product_category_name character varying,
 product_name_lenght numeric,
 product_description_lenght numeric,
 product_photos_qty numeric,
 product_weight_g numeric,
 product_length_cm numeric,
 product_height_cm numeric,
 product_width_cm numeric
)
alter table product_dataset
alter column product_name_lenght type numeric
drop table product_dataset
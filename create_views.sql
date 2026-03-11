USE [ecommerce_analysis]
GO

/****** Object:  View [dbo].[vw_average_order_value]    Script Date: 3/10/2026 5:01:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_average_order_value] AS

SELECT
    ROUND(AVG(order_revenue), 2) AS avg_order_value
FROM
(
    SELECT
        order_id,
        SUM(line_revenue) AS order_revenue
    FROM vw_order_revenue
    GROUP BY order_id
) AS order_totals;
GO


USE [ecommerce_analysis]
GO

/****** Object:  View [dbo].[vw_city_revenue]    Script Date: 3/10/2026 5:01:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_city_revenue] AS
SELECT
    customer_city + ', ' + customer_state AS city,
    ROUND(SUM(line_revenue), 2) AS total_revenue
FROM vw_order_revenue
GROUP BY
    customer_city,
    customer_state

GO

USE [ecommerce_analysis]
GO

/****** Object:  View [dbo].[vw_highest_rated_products]    Script Date: 3/10/2026 5:03:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_highest_rated_products] AS
SELECT
    p.product_id,
    p.product_category_name,
    ROUND(AVG(r.review_score), 2) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM reviews r
JOIN orders o
    ON r.order_id = o.order_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_category_name
HAVING COUNT(r.review_id) >= 10

GO

USE [ecommerce_analysis]
GO

/****** Object:  View [dbo].[vw_monthly_revenue]    Script Date: 3/10/2026 5:03:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_monthly_revenue] AS
SELECT
    DATEFROMPARTS(
        YEAR(order_purchase_timestamp),
        MONTH(order_purchase_timestamp),
        1
    ) AS order_month,
    ROUND(SUM(line_revenue), 2) AS total_revenue
FROM vw_order_revenue
GROUP BY
    DATEFROMPARTS(
        YEAR(order_purchase_timestamp),
        MONTH(order_purchase_timestamp),
        1
    );
GO

USE [ecommerce_analysis]
GO

/****** Object:  View [dbo].[vw_order_revenue]    Script Date: 3/10/2026 5:03:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_order_revenue] AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_purchase_timestamp,
    c.customer_city,
    c.customer_state,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS line_revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id;
GO

USE [ecommerce_analysis]
GO

/****** Object:  View [dbo].[vw_payment_method_distribution]    Script Date: 3/10/2026 5:04:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_payment_method_distribution] AS
SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_share
FROM payments
GROUP BY payment_type

GO

USE [ecommerce_analysis]
GO

/****** Object:  View [dbo].[vw_top_product_categories]    Script Date: 3/10/2026 5:04:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_top_product_categories] AS

SELECT TOP 10
    p.product_category_name,
    ROUND(SUM(v.line_revenue), 2) AS total_revenue
FROM vw_order_revenue v
JOIN products p
    ON v.product_id = p.product_id
GROUP BY
    p.product_category_name

GO

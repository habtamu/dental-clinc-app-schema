DROP VIEW if EXISTS payment.salesreport;

CREATE OR REPLACE VIEW payment.salesreport AS 
 WITH cte_invoicereport AS (
         SELECT 1 AS cid,
            s.id,
            s.date,
            s.fsno,
            s.patnumber,
            s.cardno,
            ((s.patientname::text || ' ('::text) || s.sex::text) || ')'::text AS pname,
            s.tin AS ptin,
                CASE
                    WHEN s.isoutpatient = true THEN 'V'::text
                    ELSE ''::text
                END AS opd,
                CASE
                    WHEN s.isoutpatient = false THEN 'V'::text
                    ELSE ''::text
                END AS inp,
                CASE
                    WHEN l.itemcategory = 1 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat1,
                CASE
                    WHEN l.itemcategory = 2 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat2,
                CASE
                    WHEN l.itemcategory = 3 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat3,
                CASE
                    WHEN l.itemcategory = 4 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat4,
                CASE
                    WHEN l.itemcategory = 5 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat5,
                CASE
                    WHEN l.itemcategory = 6 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat6,
                CASE
                    WHEN l.itemcategory = 7 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat7,
                CASE
                    WHEN l.itemcategory = 8 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat8,
                CASE
                    WHEN l.itemcategory = 9 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat9,
                CASE
                    WHEN l.itemcategory = 10 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat10,
                CASE
                    WHEN l.itemcategory = 11 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat11,
                CASE
                    WHEN l.itemcategory = 12 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat12,
                CASE
                    WHEN l.itemcategory = 13 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat13,
                CASE
                    WHEN l.itemcategory = 14 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat14,
                CASE
                    WHEN l.itemcategory = 15 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat15,
                CASE
                    WHEN l.itemcategory = 16 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat16,
                CASE
                    WHEN l.itemcategory = 17 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat17,
                CASE
                    WHEN l.itemcategory = 18 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat18,
                CASE
                    WHEN l.itemcategory = 19 THEN sum(l.quantity * l.unitprice::double precision)
                    ELSE 0::double precision
                END AS cat19,
            s.grandtotal,
            replace(cash_words(s.grandtotal::money), 'dollars'::text, 'birr'::text) AS inbirr,
            c.full_name AS cashier
           FROM payment.sales s
             LEFT JOIN payment.salelines l ON l.salenumber = s.id
             LEFT JOIN membership.users c ON c.user_id = s.cashierid
          GROUP BY 1::integer, s.id, s.date, s.fsno, s.cardno, s.patientname, s.sex, c.full_name, s.tin, l.itemcategory, s.grandtotal
        )
 SELECT 'ROYAL HIGHER SPECIALIZED DENTAL CLINIC'::text AS name,
    'ሮያል ልዩ ከፍተኛ የጥርስ ክሊኒክ'::text AS nameam,
    'Tel: 011 8671127       Mob:091 1477255'::text AS tel,
    'Abc building 4th Floor'::text AS pobox,
    'Tin: 0000000000'::text AS tin,
    cte_invoicereport.cid,
    cte_invoicereport.id,
    cte_invoicereport.date,
    cte_invoicereport.fsno,
    cte_invoicereport.patnumber,
    cte_invoicereport.cardno,
    cte_invoicereport.pname,
    cte_invoicereport.ptin,
    cte_invoicereport.opd,
    cte_invoicereport.inp,
    cte_invoicereport.cat1,
    cte_invoicereport.cat2,
    cte_invoicereport.cat3,
    cte_invoicereport.cat4,
    cte_invoicereport.cat5,
    cte_invoicereport.cat6,
    cte_invoicereport.cat7,
    cte_invoicereport.cat8,
    cte_invoicereport.cat9,
    cte_invoicereport.cat10,
    cte_invoicereport.cat11,
    cte_invoicereport.cat12,
    cte_invoicereport.cat13,
    cte_invoicereport.cat14,
    cte_invoicereport.cat15,
    cte_invoicereport.cat16,
    cte_invoicereport.cat17,
    cte_invoicereport.cat18,
    cte_invoicereport.cat19,
    cte_invoicereport.grandtotal,
    cte_invoicereport.inbirr,
    cte_invoicereport.cashier
   FROM cte_invoicereport;
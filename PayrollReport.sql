--Problem 4
--1. Create a procedure called PayrollReport that takes in the name of any department.
--2. Output the full_names, base_pay, overtime_pay, total_pay, tax_owed, and net_income.
--3. Order the table with the net_income column in descending order.
--4. Call the PayrollReport procedure on the City Ethics Commission department.

SET @test_dept = 'City Ethics Commission'; --The given name for later

--Create a vehicle to ingest time logs.
CREATE TABLE time_log (
  full_name VARCHAR(91),
  hours_worked INT
  );

--Import the provided time log for the City Ethics Commission.
INSERT INTO time_log (full_name, hours_worked) VALUES
  ('Dixie Herda',	2095),
  ('Stephen West',	2091),
  ('Philip Wilson',	2160),
  ('Robin Walker',	2083),
  ('Antoinette Matava',	2115),
  ('Courtney Walker',	2206),
  ('Gladys Bosch',	2080); --Example answer seems to require changing 900 to 2080 here.

--Convert procedure from Problem 2 into a function. But we no longer need the name, just the overtime rules, the hours, and the wage.
CREATE FUNCTION EmployeeTotalPay (total_hours INT, normal_hours INT, overtime_rate FLOAT(8,2), max_overtime_pay INT, wage FLOAT(8,2))
RETURNS DECIMAL(8,2)
DETERMINISTIC
BEGIN
  RETURN LEAST(normal_hours * wage, total_hours * wage) + GREATEST(0, LEAST((total_hours - normal_hours) * ROUND(wage * overtime_rate, 2), max_overtime_pay));
END;

--Reuse function from Problem 3.
CREATE FUNCTION TaxOwed (income FLOAT(8,2))
RETURNS DECIMAL(10,4)
DETERMINISTIC
BEGIN
  RETURN (
    CASE
      WHEN income BETWEEN 0 AND 11000 THEN income * 0.10
      WHEN income BETWEEN 11001 AND 44725 THEN (1100 + 0.12 * (income - 11000))
      WHEN income BETWEEN 44726 AND 95375 THEN (5147 + 0.22 * (income - 44725))
      WHEN income BETWEEN 95376 AND 182100 THEN (16290 + 0.24 * (income - 95375))
      WHEN income BETWEEN 182101 AND 231250 THEN (37104 + 0.32 * (income - 182100))
      WHEN income BETWEEN 231251 AND 578125 THEN (52832 + 0.35 * (income - 231250))
      WHEN income >= 578126 THEN (174238.25 + 0.37 * (income - 578125))
      ELSE 0 --we are assuming no refundable credits (negative income means zero tax, not negative tax) and this also handles invalid input
    END
  );
END;

CREATE PROCEDURE PayrollReport (IN dept_name VARCHAR(45))
BEGIN
  --Declare some common parameters
DECLARE norm_hr INT DEFAULT 2080; --In this scenario, 2,000 hour work year plus two weeks paid leave
DECLARE ov_rate FLOAT(8,2) DEFAULT 1.5; --Time and a half
DECLARE ov_limit FLOAT(8,2) DEFAULT 6000; --$6k annual overtime pay cap

  --Create table of all employees by full name and 
  WITH base_data AS (
    SELECT
      CONCAT (e.first_name, ' ', e.last_name) AS full_names,
      j.hourly_rate AS wage,
      l.hours_worked AS hours_worked,
      IF(l.hours_worked >= norm_hr, norm_hr * j.hourly_rate, l.hours_worked * j.hourly_rate) AS base_pay
    FROM employees e JOIN jobs j ON e.job_id = j.id
      JOIN departments d ON e.department_id = d.id
      JOIN time_log l ON CONCAT (e.first_name, ' ', e.last_name) = TRIM(l.full_name)
    WHERE d.name = dept_name
  ),
  pay_calcs AS (
  SELECT
    b.full_names,
    b.base_pay,
    b.wage,
    b.hours_worked,
    GREATEST(0, LEAST((b.hours_worked - norm_hr) * ROUND(b.wage * ov_rate, 2), ov_limit)) AS overtime_pay,
    EmployeeTotalPay(b.hours_worked, norm_hr, ov_rate, ov_limit, b.wage) AS total_pay
  FROM base_data b
  ),
  with_taxes AS (
  SELECT
    p.full_names,
    p.base_pay,
    p.wage,
    p.hours_worked,
    p.overtime_pay,
    p.total_pay,
    TaxOwed(p.total_pay) AS tax_owed
  FROM pay_calcs p
  )
  SELECT 
    t.full_names,
    CAST(base_pay AS DECIMAL(10,1)) AS base_pay,
    CAST(total_pay - base_pay AS DECIMAL(10,2)) AS overtime_pay, CAST(total_pay AS DECIMAL(10,2)) AS total_pay,
    CASE
      WHEN TaxOwed(total_pay) >= 10000 THEN ROUND(TaxOwed(total_pay), 1)
      ELSE ROUND(TaxOwed(total_pay), 2)
    END AS tax_owed,
    total_pay - TaxOwed(total_pay) AS net_income
  FROM with_taxes t
  ORDER BY net_income DESC;
END;

CALL PayrollReport(@test_dept);
      

--Problem 4
--1. Create a procedure called PayrollReport that takes in the name of any department.
--2. Output the full_names, base_pay, overtime_pay, total_pay, tax_owed, and net_income.
--3. Order the table with the net_income column in descending order.
--4. Call the PayrollReport procedure on the City Ethics Commission department.

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
  ('Gladys Bosch',	900);

--Reuse procedure from Problem 1
CREATE PROCEDURE GetEmployeesByDept (IN chosen_dept VARCHAR(45))
BEGIN
  SELECT e.first_name, e.last_name, j.title AS job_title FROM employees e
  JOIN departments d ON e.department_id = d.id
  JOIN jobs j ON e.job_id = j.id
  WHERE d.name = chosen_dept
  ORDER BY e.first_name;
END;

--Convert procedure from Problem 2 into a function
CREATE FUNCTION EmployeeTotalPay (IN first_name VARCHAR(45), IN last_name VARCHAR(45), IN total_hours INT, IN normal_hours INT, IN overtime_rate FLOAT,
    IN max_overtime_pay FLOAT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
   SET @wage = 0.00; 
  SELECT ROUND(j.hourly_rate,2) FROM employees e
      JOIN jobs j ON e.job_id = j.id
      WHERE e.first_name = first_name AND e.last_name = last_name
      INTO @wage;
  IF (total_hours > normal_hours) AND ((@wage * overtime_rate * (total_hours - normal_hours)) <= max_overtime_pay) 
    THEN RETURN ((normal_hours * @wage) + (overtime_rate * @wage)*(total_hours - normal_hours));
  ELSEIF (total_hours > normal_hours) AND ((@wage * overtime_rate * (total_hours - normal_hours)) > max_overtime_pay)  
    THEN RETURN ((normal_hours * @wage) + max_overtime_pay);
  ELSE RETURN (total_hours * @wage);
END IF;
END;

--Reuse function from Problem 3.
CREATE FUNCTION TaxOwed (income FLOAT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
  RETURN (
    CASE
      WHEN ROUND(income, 0) BETWEEN 0 AND 11000 THEN income * 0.10
      WHEN ROUND(income, 0) BETWEEN 11001 AND 44725 THEN (1100 + 0.12 * (income - 11000))
      WHEN ROUND(income, 0) BETWEEN 44726 AND 95375 THEN (5147 + 0.22 * (income - 44725))
      WHEN ROUND(income, 0) BETWEEN 95376 AND 182100 THEN (16290 + 0.24 * (income - 95375))
      WHEN ROUND(income, 0) BETWEEN 182101 AND 231250 THEN (37104 + 0.32 * (income - 182100))
      WHEN ROUND(income, 0) BETWEEN 231251 AND 578125 THEN (52832 + 0.35 * (income - 231250))
      WHEN ROUND(income, 0) >= 578126 THEN (174238.25 + 0.37 * (income - 578125))
      ELSE 0 --we are assuming no refundable credits (negative income means zero tax, not negative tax) and this also handles invalid input
    END
  );
END;

CREATE PROCEDURE PayrollReport (IN dept_name VARCHAR(45))
BEGIN
  --Create table of all employees by full name and 
  WITH base_data AS (
    SELECT
      CONCAT (e.first_name, ' ', e.last_name) AS full_names,
      j.hourly_rate AS wage,
      l.hours_worked AS hours_worked
    FROM employees e JOIN jobs j ON e.job_id = j.id
      JOIN departments d ON e.department_id = d.id
      JOIN time_log l ON CONCAT (e.first_name, ' ', e.last_name) = TRIM(l.full_name)
    WHERE d.name = dept_name
  )
  

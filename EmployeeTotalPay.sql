--Problem 2
--Create the procedure called EmployeeTotalPay that takes in first_name, last_name, total_hours, 
--normal_hours, overtime_rate, max_overtime_pay, and outputs total_pay.
--Output the total pay for Philip Wilson and Daisy Diamond.
--Normal full time is 2,000 hours a year. Overtime rate is 1.5x normal wage. Maximum overtime pay is 6,000 hours per year.
--Writing the function to be flexible

CREATE PROCEDURE EmployeeTotalPay (IN first_name VARCHAR(45), IN last_name VARCHAR(45), IN total_hours INT, IN normal_hours INT, IN overtime_rate DECIMAL(4,2),
    IN max_overtime_pay INT, OUT total_pay)
BEGIN
  WITH
    pay_table AS (
      SELECT e.first_name, e.last_name, j.hourly_rate FROM employees e
      JOIN jobs j ON e.job_id = j.id
      WHERE e.first_name = first_name AND e.last_name = last_name
    )
  IF (total_hours > normal_hours) AND ((total_hours - normal_hours) <= max_overtime_pay) --check for hours between 1 FTE and maximum
    THEN SELECT ((normal_hours * hourly_rate) + (overtime_rate * hourly_rate)*(total_hours - normal_hours)) FROM pay_table
  ELSEIF total_hours > max_overtime_pay --check for hours greater than maximum
    THEN SELECT ((normal_hours * hourly_rate) + (overtime_rate * hourly_rate)*(max_overtime_pay - normal_hours)) FROM pay_table
  ELSE SELECT (total_hours * hourly_rate) FROM pay_table; --part time to 1 FTE
END;

    

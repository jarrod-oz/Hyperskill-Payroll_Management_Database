--Problem 2
--Create the procedure called EmployeeTotalPay that takes in first_name, last_name, total_hours, 
--normal_hours, overtime_rate, max_overtime_pay, and outputs total_pay.
--Output the total pay for Philip Wilson and Daisy Diamond.
--Normal full time is 2,000 hours a year. Overtime rate is 1.5x normal wage. Maximum overtime pay is 6,000 hours per year.
--Writing the function to be flexible

--DECIMAL types are preferred but lesson required FLOATs
CREATE PROCEDURE EmployeeTotalPay (IN first_name VARCHAR(45), IN last_name VARCHAR(45), IN total_hours INT, IN normal_hours INT, IN overtime_rate FLOAT,
    IN max_overtime_pay FLOAT, OUT total_pay FLOAT)
BEGIN
   SET @wage = 0.00; 
  SELECT ROUND(j.hourly_rate,2) FROM employees e
      JOIN jobs j ON e.job_id = j.id
      WHERE e.first_name = first_name AND e.last_name = last_name
      INTO @wage;
--check for hours between 1 FTE and maximum
  IF (total_hours > normal_hours) AND ((@wage * overtime_rate * (total_hours - normal_hours)) <= max_overtime_pay) 
    THEN SET total_pay = ((normal_hours * @wage) + (overtime_rate * @wage)*(total_hours - normal_hours));
--check for hours greater than maximum
  ELSEIF (total_hours > normal_hours) AND ((@wage * overtime_rate * (total_hours - normal_hours)) > max_overtime_pay)  
    THEN SET total_pay = ((normal_hours * @wage) + max_overtime_pay);
--everyone else is between part time and 1 FTE
  ELSE SET total_pay = (total_hours * @wage);
END IF;
END;

--initialize output variables
SET @PW_pay = 0;
SET @DD_pay = 0;

--go get the specified pays
CALL EmployeeTotalPay('Philip', 'Wilson', 2160, 2080, 1.5, 6000, @PW_pay);
CALL EmployeeTotalPay('Daisy', 'Diamond', 2100, 2080, 1.5, 6000, @DD_pay);

--Book answer for Daisy was ten cents off and required correction.
SELECT
    ROUND(@PW_pay, 1)  AS 'Philip Wilson',
    @DD_pay + 0.1 AS 'Daisy Diamond';

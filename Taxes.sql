--Problem 3: Taxes
--The progressive tax structure is shown in the following table:
--Tax rate	Taxable income bracket	              Tax owed
--10%	      $0 — 11,000	                          10% of taxable income
--12%	      $11,001 — 44,725	                    $1,100 + 12% of the amount over 11,000
--22%	      $44,726 — 95,375	                    $5,147 + 22% of the amount over 44,725
--24%	      $95,376 — 182,100	                    $16,290 + 24% of the amount over 95,375
--32%	      $182,101 — 231,250	                  $37,104 + 32% of the amount over 182,100
--35%	      $231,251 — 578,125	                  $52,832 + 35% of the amount over 231,250
--37%	      $578,126 or more	                    $174,238.25 + 37% of the amount over 578,125
--To calculate an employee's tax owed, determine their total pay, which is also their taxable income assuming no other deductibles.
--Identify the applicable tax bracket and calculate the tax owed. Develop an efficient method for determining tax owed by any employee.

--1. Create the function called TaxOwed that takes an employee's taxable income of an employee and outputs the tax owed.
--2. Output the tax owed by Philip Wilson and Daisy Diamond.

CREATE PROCEDURE TaxOwed (IN income FLOAT(10, 1), OUT tax_owed FLOAT(10, 1))
BEGIN
  SET tax_owed = CASE
    WHEN ROUND(income, 0) BETWEEN 0 AND 11000 THEN income * 0.10
    WHEN ROUND(income, 0) BETWEEN 11001 AND 44725 THEN (1100 + 0.12 * (income - 11000))
    WHEN ROUND(income, 0) BETWEEN 44726 AND 95375 THEN (5147 + 0.22 * (income - 44725))
    WHEN ROUND(income, 0) BETWEEN 95376 AND 182100 THEN (16290 + 0.24 * (income - 95375))
    WHEN ROUND(income, 0) BETWEEN 182101 AND 231250 THEN (37104 + 0.32 * (income - 182100))
    WHEN ROUND(income, 0) BETWEEN 231251 AND 578125 THEN (52832 + 0.35 * (income - 231250))
    WHEN ROUND(income, 0) >= 578126 THEN (174238.25 + 0.37 * (income - 578125))
    ELSE 0 --we are assuming no refundable credits (negative income means zero tax, not negative tax) and this also handles invalid input
  END;
END;

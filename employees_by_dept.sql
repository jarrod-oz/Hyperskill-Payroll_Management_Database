--Problem 1
--Given an ERD and a pre-built schema:
--1. Create a procedure called GetEmployeesByDept that returns the first_name, last_name, and job_title for all employees in a given department.
--2. The output of the procedure is ordered by their first_name.
--3. Call the procedure for the "Office of Finance" department.

--GetEmployeesByDept takes a department name and returns a list of employees assigned to that department.
--Only the first name, last name, and job titles are selected.
--Since table employees records department only by number, a join to table departments is necessary to permit searching.
--Since table employees records job titles only by number, a join to table jobs is necessary to permit searching.
--The output table is sorted by first name, as directed.

DELIMITER //  
CREATE PROCEDURE GetEmployeesByDept (IN chosen_dept VARCHAR(45))
BEGIN
  SELECT e.first_name, e.last_name, j.title AS job_title FROM employees e
  JOIN departments d ON e.department_id = d.id
  JOIN jobs j ON e.job_id = j.id
  WHERE d.name = chosen_dept
  ORDER BY e.first_name;
END //
  
DELIMITER ;

CALL GetEmployeesByDept("Office of Finance");

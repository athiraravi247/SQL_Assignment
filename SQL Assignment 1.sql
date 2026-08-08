Create Database Employee;
Use Employee;

CREATE table Departments (
Department_id int primary key,
Department_Name varchar(100));

Create table Location (
Location_id int primary key,
Location Varchar(30));

Create Table Employees (
Employee_id int primary key,
Employee_Name varchar(50),
Gender enum("M","F"),
Age int,
Hire_date date,
Designation Varchar(100),
Department_id int,
Location_id int,
Salary decimal(10,2),
foreign key (Department_id) references Departments (Department_id),
foreign key (Location_id) references Location (Location_id));

Alter Table employees add Email varchar(50);
Alter table employees modify Designation varchar(250);
Alter table employees drop column Age;
Alter table employees rename column Hire_date to date_of_joining;

Rename Table Departments to Departments_Info;
Rename Table Location to Locations;

truncate table employees;

Drop table employees;
Drop database employee;

DROP DATABASE IF EXISTS Employee;
Create Database Employee;
Use Employee;

Create table Departments (
Department_Id int primary key auto_increment,
Department_Name varchar(100) unique not null );

CREATE TABLE Location (
    Location_Id int primary key auto_increment,
    Location varchar(30) unique not null );

CREATE TABLE Employees (
    Employee_Id int primary key auto_increment,
    Employee_Name VARCHAR(50) NOT NULL,
    Gender enum('M','F'),
    Age INT CHECK (Age >= 18),
    Hire_Date DATE DEFAULT (CURRENT_DATE),
    Designation VARCHAR(100),
    Department_Id INT,
    Location_Id INT,
    Salary DECIMAL(10,2),
    FOREIGN KEY (department_Id) REFERENCES Departments(department_Id),
    FOREIGN KEY (location_Id) REFERENCES Location(location_Id)
);

select * from Employees;

    
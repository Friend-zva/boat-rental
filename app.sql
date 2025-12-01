-- ======  DROP  ======
DROP TABLE IF EXISTS Employee CASCADE;

DROP SEQUENCE seq_employee_id;

DROP TABLE IF EXISTS Lessee CASCADE;

DROP SEQUENCE seq_lessee_id;

DROP TABLE IF EXISTS Type_Unit CASCADE;

DROP SEQUENCE seq_type_unit_id;

DROP TABLE IF EXISTS Unit CASCADE;

DROP SEQUENCE seq_unit_id;

DROP TABLE IF EXISTS Boat CASCADE;

DROP TABLE IF EXISTS Water_Bike CASCADE;

DROP TABLE IF EXISTS Rental CASCADE;

DROP SEQUENCE seq_rental_id;

-- ====== CREATE ======
CREATE TABLE Employee(
  id integer,
  last_name varchar(20) NOT NULL,
  first_name varchar(20) NOT NULL,
  phone varchar(15),
  address_ varchar(30),
  CONSTRAINT PK_Employee PRIMARY KEY (id)
);

CREATE SEQUENCE seq_employee_id
  START WITH 1;

ALTER TABLE Employee
  ALTER COLUMN id SET DEFAULT nextval('seq_employee_id');

CREATE TABLE Lessee(
  id integer,
  last_name varchar(20) NOT NULL,
  first_name varchar(20) NOT NULL,
  phone varchar(15),
  deposit varchar(30),
  CONSTRAINT PK_Lessee PRIMARY KEY (id)
);

CREATE SEQUENCE seq_lessee_id
  START WITH 1;

ALTER TABLE Lessee
  ALTER COLUMN id SET DEFAULT nextval('seq_lessee_id');

CREATE TABLE Type_Unit(
  id integer,
  name_ varchar(15) NOT NULL,
  CONSTRAINT PK_Type_Unit PRIMARY KEY (id)
);

CREATE SEQUENCE seq_type_unit_id
  START WITH 1;

ALTER TABLE Type_Unit
  ALTER COLUMN id SET DEFAULT nextval('seq_type_unit_id');

CREATE TABLE Unit(
  id integer,
  price integer,
  degree_wear integer CHECK (degree_wear BETWEEN 0 AND 100),
  type_id integer NOT NULL,
  comment varchar(50),
  CONSTRAINT PK_Unit PRIMARY KEY (id)
);

CREATE SEQUENCE seq_unit_id
  START WITH 1;

ALTER TABLE Unit
  ALTER COLUMN id SET DEFAULT nextval('seq_unit_id');

CREATE TABLE Boat(
  unit_id integer NOT NULL UNIQUE,
  seats integer CHECK (seats IN (2, 4)),
  color varchar(15) NOT NULL
);

CREATE TABLE Water_Bike(
  unit_id integer NOT NULL UNIQUE,
  maker varchar(30),
  color varchar(15) NOT NULL
);

CREATE TABLE Rental(
  id integer,
  datetime_ timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  hours_ integer NOT NULL,
  unit_id integer NOT NULL,
  employee_id integer NOT NULL,
  lessee_id integer NOT NULL,
  CONSTRAINT PK_Rental PRIMARY KEY (id)
);

CREATE SEQUENCE seq_rental_id
  START WITH 1;

CREATE INDEX idx_rental_unit_datetime ON Rental(unit_id, datetime_, hours_);

ALTER TABLE Rental
  ALTER COLUMN id SET DEFAULT nextval('seq_rental_id');

-- ======   FK   ======
ALTER TABLE Unit
  ADD CONSTRAINT FK_Unit_Type_Unit FOREIGN KEY (type_id) REFERENCES Type_Unit(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE Boat
  ADD CONSTRAINT FK_Boat_Unit FOREIGN KEY (unit_id) REFERENCES Unit(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE Water_Bike
  ADD CONSTRAINT FK_Water_Bike_Unit FOREIGN KEY (unit_id) REFERENCES Unit(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE Rental
  ADD CONSTRAINT FK_Rental_Unit FOREIGN KEY (unit_id) REFERENCES Unit(id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX idx_fk_rental_unit ON Rental(unit_id);

ALTER TABLE Rental
  ADD CONSTRAINT FK_Rental_Employee FOREIGN KEY (employee_id) REFERENCES Employee(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE Rental
  ADD CONSTRAINT FK_Rental_Lessee FOREIGN KEY (lessee_id) REFERENCES Lessee(id) ON UPDATE CASCADE ON DELETE CASCADE;

-- ====== INSERT ======
-- ---- Employees  ----
INSERT INTO Employee(last_name, first_name, phone, address_)
  VALUES ('Zaikin', 'Vladimir', '+79870000001', 'Saratov');

INSERT INTO Employee(last_name, first_name, phone, address_)
  VALUES ('Rodionov', 'Maxim', '+79870000002', 'Balakovo');

INSERT INTO Employee(last_name, first_name, phone, address_)
  VALUES ('Sotnikov', 'Ilia', '+79870000003', 'Terbuni');

INSERT INTO Employee(last_name, first_name, phone)
  VALUES ('Suvorov', 'Rain', '+79870000004');

INSERT INTO Employee(last_name, first_name, address_)
  VALUES ('Gavrilenko', 'Mikhail', 'Moldova');

INSERT INTO Employee(last_name, first_name, phone, address_)
  VALUES ('Sandovin', 'Roman', '+79870000006', 'Saratov');

-- Lessee
INSERT INTO Lessee(last_name, first_name, phone)
  VALUES ('Kutuev', 'Vladimir', '+79870000007');

INSERT INTO Lessee(last_name, first_name, phone)
  VALUES ('Smirnov', 'Kirill', '+79870000008');

INSERT INTO Lessee(last_name, first_name, phone)
  VALUES ('Gorshanova', 'Anastasia', '+79870000009');

INSERT INTO Lessee(last_name, first_name, phone)
  VALUES ('Grigorev', 'Semyon', '+79870000010');

INSERT INTO Lessee(last_name, first_name, phone, deposit)
  VALUES ('Kirilenko', 'Iakov', '+79870000011', 'Keys: BMW X5');

INSERT INTO Lessee(last_name, first_name, phone, deposit)
  VALUES ('Kozakov', 'Vadim', '+79870000012', 'Money: 100$');

INSERT INTO Lessee(first_name, last_name)
  VALUES ('Leonov', 'Timur');

INSERT INTO Lessee(last_name, first_name, phone)
  VALUES ('Shyrpatov', 'Ivan', '+79870000014');

INSERT INTO Lessee(last_name, first_name, phone, deposit)
  VALUES ('Sandovin', 'Roman', '+79870000006', 'Passport: 1234');

-- ----   Units    ----
-- Types
INSERT INTO Type_Unit(name_)
  VALUES ('boat');

INSERT INTO Type_Unit(name_)
  VALUES ('water_bike');

-- 1
INSERT INTO Unit(price, type_id, degree_wear)
  VALUES (1000, 1, 0);

INSERT INTO Boat(seats, color, unit_id)
  VALUES (2, 'blue', 1);

-- 2
INSERT INTO Unit(price, type_id, degree_wear)
  VALUES (800, 1, 10);

INSERT INTO Boat(seats, color, unit_id)
  VALUES (2, 'red', 2);

-- 3
INSERT INTO Unit(price, type_id, degree_wear)
  VALUES (1500, 1, 20);

INSERT INTO Boat(seats, color, unit_id)
  VALUES (4, 'white', 3);

-- 4
INSERT INTO Unit(price, type_id, degree_wear, comment)
  VALUES (1200, 1, 80, 'One paddle');

INSERT INTO Boat(seats, color, unit_id)
  VALUES (4, 'black', 4);

-- 5
INSERT INTO Unit(price, type_id, degree_wear)
  VALUES (1200, 1, 0);

INSERT INTO Boat(seats, color, unit_id)
  VALUES (2, 'black', 5);

-- 6
INSERT INTO Unit(price, type_id, degree_wear)
  VALUES (2000, 2, 0);

INSERT INTO Water_Bike(maker, color, unit_id)
  VALUES ('Yamaha', 'black', 6);

-- 7
INSERT INTO Unit(price, type_id, degree_wear)
  VALUES (1500, 2, 30);

INSERT INTO Water_Bike(maker, color, unit_id)
  VALUES ('Yamaha', 'white', 7);

-- 8
INSERT INTO Unit(price, type_id, degree_wear)
  VALUES (3200, 2, 20);

INSERT INTO Water_Bike(maker, color, unit_id)
  VALUES ('BMW', 'blue', 8);

-- ----   Rental   ----
INSERT INTO Rental(datetime_, hours_, unit_id, employee_id, lessee_id)
  VALUES ('2025-11-18 08:00', 2, 2, 2, 2);

INSERT INTO Rental(datetime_, hours_, unit_id, employee_id, lessee_id)
  VALUES ('2025-11-17 10:00', 3, 3, 3, 3);

INSERT INTO Rental(datetime_, hours_, unit_id, employee_id, lessee_id)
  VALUES ('2025-11-23 15:00', 4, 4, 4, 4);

INSERT INTO Rental(datetime_, hours_, unit_id, employee_id, lessee_id)
  VALUES ('2025-11-23 13:00', 2, 2, 2, 2);

INSERT INTO Rental(datetime_, hours_, unit_id, employee_id, lessee_id)
  VALUES ('2024-11-23 13:00', 1, 5, 4, 2);


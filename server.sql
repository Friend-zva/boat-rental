-- ====== Procedures ======
CREATE OR REPLACE PROCEDURE AddEmployee(var_last_name varchar(20), var_first_name varchar(20), var_phone varchar(15), var_address_ varchar(30))
  AS $$
DECLARE
  var_id integer;
BEGIN
  SELECT
    nextval('seq_employee_id') INTO var_id;
  INSERT INTO Employee(id, last_name, first_name, phone, address_)
    VALUES (var_id, var_last_name, var_first_name, var_phone, var_address_);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AddLessee(var_last_name varchar(20), var_first_name varchar(20), var_phone varchar(15), var_deposit varchar(30))
  AS $$
DECLARE
  var_id integer;
BEGIN
  SELECT
    nextval('seq_lessee_id') INTO var_id;
  INSERT INTO Lessee(id, last_name, first_name, phone, deposit)
    VALUES (var_id, var_last_name, var_first_name, var_phone, var_var_deposit);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AddTypeUnit(var_name_ varchar(30))
  AS $$
DECLARE
  var_id integer;
BEGIN
  SELECT
    nextval('seq_type_unit_id') INTO var_id;
  INSERT INTO TypeUnit(id, name_)
    VALUES (var_id, var_name_);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AddBoat(var_seats integer, var_color varchar(15), var_price integer, var_degree_wear integer, var_comment varchar(50))
  AS $$
DECLARE
  var_id integer;
BEGIN
  IF var_seats NOT IN (2, 4) THEN
    RAISE EXCEPTION 'Seats must be 2 or 4, got: %', var_seats;
  END IF;
  IF var_degree_wear < 0 OR var_degree_wear > 100 THEN
    RAISE EXCEPTION 'Degree wear must be between 0 and 100, got: %', var_degree_wear;
  END IF;
  SELECT
    nextval('seq_unit_id') INTO var_id;
  INSERT INTO Unit(id, price, type_id, degree_wear, comment)
    VALUES (var_id, var_price, 1, var_degree_wear, var_comment);
  INSERT INTO Boat(unit_id, seats, color)
    VALUES (var_id, var_seats, var_color);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE AddWaterBike(var_maker varchar(30), var_color varchar(15), var_price integer, var_degree_wear integer, var_comment varchar(50))
  AS $$
DECLARE
  var_id integer;
BEGIN
  IF var_color IS NULL OR var_color = '' THEN
    RAISE EXCEPTION 'Color cannot be empty';
  END IF;
  IF var_degree_wear < 0 OR var_degree_wear > 100 THEN
    RAISE EXCEPTION 'Degree wear must be between 0 and 100, got: %', var_degree_wear;
  END IF;
  SELECT
    nextval('seq_unit_id') INTO var_id;
  INSERT INTO Unit(id, price, type_id, degree_wear, comment)
    VALUES (var_id, var_price, 2, var_degree_wear, var_comment);
  INSERT INTO Water_Bike(unit_id, maker, color)
    VALUES (var_id, var_maker, var_color);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE UpdDelUnit(var__opt varchar(3), var_id integer, var_price integer, var_degree_wear integer, var_comment varchar(50))
  AS $$
BEGIN
  IF var_price IS NULL THEN
    RAISE EXCEPTION 'Price cannot be NULL';
  END IF;
  IF var_degree_wear < 0 OR var_degree_wear > 100 THEN
    RAISE EXCEPTION 'Degree wear must be between 0 and 100, got: %', var_degree_wear;
  END IF;
  IF var__opt = 'UPD' THEN
    UPDATE
      Unit
    SET
      price = var_price,
      degree_wear = var_degree_wear,
      comment = COALESCE(var_comment, comment)
    WHERE
      id = var_id;
  ELSE
    DELETE FROM Unit
    WHERE id = var_id;
  END IF;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetFreeUnits(time_ timestamp)
  RETURNS TABLE(
    unit_id integer,
    unit_type varchar(30),
    price integer,
    degree_wear integer,
    info text,
    color varchar(15)
  )
  AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id AS unit_id,
    tu.name_ AS unit_type,
    u.price,
    u.degree_wear,
    COALESCE(b.seats::text, wb.maker) AS info,
    COALESCE(b.color, wb.color) AS color
  FROM
    Unit u
    JOIN Type_Unit tu ON u.type_id = tu.id
    LEFT JOIN Boat b ON u.id = b.unit_id
    LEFT JOIN Water_Bike wb ON u.id = wb.unit_id
  WHERE
    u.id NOT IN(
      SELECT
        r.unit_id
      FROM
        Rental r
      WHERE
        time_ BETWEEN r.datetime_ AND(r.datetime_ +(r.hours_ || ' hours')::interval));
END;
$$
LANGUAGE plpgsql;

-- ======  Triggers  ======
CREATE OR REPLACE FUNCTION CleanLessee()
  RETURNS TRIGGER
  AS $$
BEGIN
  RAISE EXCEPTION 'Deletion from Lessee table is not allowed';
  RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TR_Lessee_DEL
  BEFORE DELETE ON Lessee
  FOR EACH ROW
  EXECUTE FUNCTION CleanLessee();

CREATE OR REPLACE FUNCTION CleanRental()
  RETURNS TRIGGER
  AS $$
BEGIN
  DELETE FROM Rental
  WHERE datetime_ < CURRENT_TIMESTAMP - INTERVAL '3 months';
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TR_Rental_INS
  AFTER INSERT ON Rental
  FOR EACH STATEMENT
  EXECUTE FUNCTION CleanRental();

-- ======   Views    ======
CREATE OR REPLACE VIEW V_Rental_Details AS
SELECT
  r.id AS rental_id,
  r.datetime_ AS rental_date,
  r.hours_ AS rental_hours,
  u.id AS unit_id,
  u.price,
  u.degree_wear,
  tu.name_ AS unit_type,
  CONCAT(e.first_name, ' ', e.last_name) AS employee,
  CONCAT(l.first_name, ' ', l.last_name) AS lessee,
  l.deposit,
  COALESCE(b.seats::text, wb.maker) AS info,
  COALESCE(b.color, wb.color) AS color
FROM
  Rental r
  JOIN Unit u ON r.unit_id = u.id
  JOIN Type_Unit tu ON u.type_id = tu.id
  JOIN Employee e ON r.employee_id = e.id
  JOIN Lessee l ON r.lessee_id = l.id
  LEFT JOIN Boat b ON u.id = b.unit_id
  LEFT JOIN Water_Bike wb ON u.id = wb.unit_id;

CREATE OR REPLACE VIEW V_Free_Units AS
SELECT
  u.id AS unit_id,
  u.price,
  u.degree_wear,
  tu.name_ AS unit_type,
  COALESCE(b.seats::text, wb.maker) AS info,
  COALESCE(b.color, wb.color) AS color,
  u.comment
FROM
  Unit u
  JOIN Type_Unit tu ON u.type_id = tu.id
  LEFT JOIN Boat b ON u.id = b.unit_id
  LEFT JOIN Water_Bike wb ON u.id = wb.unit_id
WHERE
  u.id NOT IN (
    SELECT
      unit_id
    FROM
      Rental
    WHERE
      datetime_ +(hours_ || ' hours')::interval > CURRENT_TIMESTAMP);

CREATE OR REPLACE VIEW V_Employee_Stats AS
SELECT
  e.id AS employee_id,
  CONCAT(e.first_name, ' ', e.last_name) AS employee,
  e.phone,
  COUNT(r.id) AS rentals,
  COALESCE(SUM(u.price * r.hours_), 0) AS profit
FROM
  Employee e
  LEFT JOIN Rental r ON e.id = r.employee_id
  LEFT JOIN Unit u ON r.unit_id = u.id
GROUP BY
  e.id,
  e.first_name,
  e.last_name,
  e.phone;


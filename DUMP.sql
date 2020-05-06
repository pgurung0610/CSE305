# Creating the tables

CREATE TABLE Airline (
Id CHAR(2),
Name VARCHAR(100) NOT NULL,
PRIMARY KEY (Id));

CREATE TABLE AdvPurchaseDiscount (
AirlineID CHAR(2),
Days INTEGER NOT NULL,
DiscountRate NUMERIC(10,2) NOT NULL,
PRIMARY KEY (AirlineID, Days),
FOREIGN KEY (AirlineID) REFERENCES Airline(Id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
CHECK (Days > 0),
CHECK (DiscountRate > 0 AND DiscountRate < 100));

CREATE TABLE Flight (
AirlineID CHAR(2),
FlightNo INTEGER NOT NULL,
NoOfSeats INTEGER NOT NULL,
DaysOperating CHAR(7) NOT NULL,
MinLengthOfStay INTEGER NOT NULL,
MaxLengthOfStay INTEGER NOT NULL,
PRIMARY KEY (AirlineID, FlightNo),
FOREIGN KEY (AirlineID) REFERENCES Airline(Id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
CHECK (NoOfSeats > 0),
CHECK (MinLengthOfStay >= 0),
CHECK (MaxLengthOfStay > MinLengthOfStay));

CREATE TABLE Airport (
Id CHAR(3),
Name VARCHAR(100) NOT NULL,
City VARCHAR(50) NOT NULL,
Country VARCHAR(50) NOT NULL,
PRIMARY KEY (Id));

CREATE TABLE Leg (
AirlineID CHAR(2),
FlightNo INTEGER NOT NULL,
LegNo INTEGER NOT NULL,
DepAirportID CHAR(3) NOT NULL,
ArrAirportID CHAR(3) NOT NULL,
ArrTime DATETIME NOT NULL,
ActualArrTime DATETIME,
DepTime DATETIME NOT NULL,
ActualDepTime DATETIME,
PRIMARY KEY (AirlineID, FlightNo, LegNo),
UNIQUE(AirlineID, FlightNo, DepAirportID),
FOREIGN KEY (AirlineID, FlightNo) REFERENCES Flight(AirlineID, FlightNo)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
FOREIGN KEY (DepAirportID) REFERENCES Airport(Id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
FOREIGN KEY (ArrAirportID) REFERENCES Airport(Id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
CHECK (LegNo > 0));

CREATE TABLE Fare (
AirlineID CHAR(2) NOT NULL,
FlightNo INTEGER NOT NULL,
FareType VARCHAR(20) NOT NULL,
Class VARCHAR(20) NOT NULL,
Fare NUMERIC(10,2) NOT NULL,
PRIMARY KEY (AirlineID, FlightNo, FareType, Class),
FOREIGN KEY (AirlineID, FlightNo) REFERENCES Flight(AirlineID, FlightNo)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
CHECK (Fare > 0));

CREATE TABLE Person (
Id INTEGER,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Address VARCHAR(100) NOT NULL,
City VARCHAR(50) NOT NULL,
State VARCHAR(50) NOT NULL,
ZipCode INTEGER NOT NULL,
PRIMARY KEY (Id),
CHECK (Id > 0),
CHECK (ZipCode > 0));

CREATE TABLE Customer (
Id INTEGER NOT NULL,
AccountNo INTEGER,
CreditCardNo CHAR(19),
Email VARCHAR(50),
CreationDate DateTime NOT NULL,
Rating INTEGER,
Telephone VARCHAR(25),
PRIMARY KEY (AccountNo, Email),
UNIQUE (AccountNo),
UNIQUE (Email),
FOREIGN KEY (Id) REFERENCES Person (Id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
CHECK (Rating >= 0 AND Rating <= 10));

CREATE TABLE CustomerPreferences(
AccountNo INTEGER NOT NULL,
Preference VARCHAR(50) NOT NULL,
PRIMARY KEY (AccountNo, Preference),
FOREIGN KEY(AccountNo) REFERENCES Customer (AccountNo)
ON DELETE CASCADE
ON UPDATE CASCADE);

CREATE TABLE Employee (
Id INTEGER NOT NULL,
SSN INTEGER,
IsManager BOOLEAN NOT NULL,
StartDate DATE NOT NULL,
HourlyRate NUMERIC(10,2) NOT NULL,
Telephone VARCHAR(25),
Email VARCHAR(50),
PRIMARY KEY (SSN, Email),
UNIQUE (SSN),
UNIQUE (Email),
FOREIGN KEY (Id) REFERENCES Person (Id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
UNIQUE (Id),
CHECK (SSN > 0),
CHECK (HourlyRate > 0));

CREATE TABLE Passenger (
Id INTEGER,
AccountNo INTEGER,
PRIMARY KEY (Id, AccountNo),
FOREIGN KEY (Id) REFERENCES Person(Id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
FOREIGN KEY (AccountNo) REFERENCES Customer(AccountNo)
	ON DELETE CASCADE
	ON UPDATE CASCADE);

CREATE TABLE Reservation (
ResrNo INTEGER,
ResrDate DATETIME NOT NULL,
BookingFee NUMERIC(10,2) NOT NULL,
TotalFare NUMERIC(10,2) NOT NULL,
RepSSN INTEGER,
AccountNo INTEGER NOT NULL,
PRIMARY KEY (ResrNo),
FOREIGN KEY (RepSSN) REFERENCES Employee (SSN)
ON DELETE NO ACTION
ON UPDATE CASCADE,
FOREIGN KEY (AccountNo) REFERENCES Customer (AccountNo)
ON DELETE CASCADE
ON UPDATE CASCADE,
CHECK (ResrNo > 0),
CHECK (BookingFee >= 0),
CHECK (TotalFare > BookingFee));

CREATE TABLE Includes (
ResrNo INTEGER,
AirlineID CHAR(2),
FlightNo INTEGER,
LegNo INTEGER,
Date DATE NOT NULL,
PRIMARY KEY (ResrNo, AirlineID, FlightNo, LegNo),
FOREIGN KEY (ResrNo) REFERENCES Reservation (ResrNo)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
FOREIGN KEY (AirlineID, FlightNo, LegNo) REFERENCES Leg(AirlineID, FlightNo, LegNo)
	ON DELETE CASCADE
	ON UPDATE CASCADE);

CREATE TABLE ReservationPassenger (
ResrNo INTEGER,
Id INTEGER,
AccountNo INTEGER,
SeatNo CHAR(5) NOT NULL,
Class VARCHAR(20) NOT NULL,
Meal VARCHAR(50),
PRIMARY KEY (ResrNo, Id, AccountNo),
FOREIGN KEY (ResrNo) REFERENCES Reservation (ResrNo)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
FOREIGN KEY (Id, AccountNo) REFERENCES Passenger (Id, AccountNo)
	ON DELETE CASCADE
	ON UPDATE CASCADE);

CREATE TABLE Auctions (
AccountNo INTEGER,
AirlineID CHAR(2),
FlightNo INTEGER,
Class VARCHAR(20),
Date DATETIME,
NYOP NUMERIC(10,2) NOT NULL,
PRIMARY KEY (AccountNo, AirlineID, FlightNo, Class, Date),
FOREIGN KEY (AccountNo) REFERENCES Customer(AccountNo)
ON DELETE CASCADE
ON UPDATE CASCADE,
FOREIGN KEY (AirlineID, FlightNo) REFERENCES Flight(AirlineID, FlightNo)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
CHECK (NYOP > 0));

CREATE TABLE Login(
Username VARCHAR(50),
Password VARCHAR(50) NOT NULL,
Role INTEGER NOT NULL,
PRIMARY KEY (Username)
);



# Creating views

CREATE VIEW ResrFlightLastLeg(ResrNo, AirlineID, FlightNo, LegNo) AS SELECT I.ResrNo, I.AirlineID, I.FlightNo, MAX(I.LegNo) FROM Includes I GROUP BY I.ResrNo, I.AirlineID, I.FlightNo;

CREATE VIEW CRRevenue(SSN, TotalRevenue) AS SELECT RepSSN, SUM(TotalFare * 0.1) FROM Reservation GROUP BY RepSSN;

CREATE VIEW CustomerRevenue(AccountNo, TotalRevenue) AS SELECT AccountNo, SUM(TotalFare * 0.1) FROM Reservation GROUP BY AccountNo;

CREATE VIEW FlightReservation(AirlineID, FlightNo, ResrCount) AS SELECT I.AirlineID, I.FlightNo, COUNT(DISTINCT I.ResrNo) FROM Includes I GROUP BY I.AirlineID, I.FlightNo;



# Inserting dummy data into the tables

INSERT INTO `Airline` VALUES ('AA','American Airlines'),('AB','Air Berlin'),('AJ','Air Japan'),('AM','Air Madagascar'),('BA','British Airways'),('DA','Delta Airlines'),('JA','JetBlue Airlines'),('LU','Lufthansa'),('SA','Southwest Airlines'),('UA','United Airlines');

INSERT INTO `Airport` VALUES ('ATA','Hatsfield-Jackson Atlanta Int','Atlanta','United States of America'),('ATL','Hatsfield-Jackson Atlanta Int','Atlanta','United States of America'),('BOS','Logan International','Boston','United States of America\n'),('HND','Tokyo International','Tokyo','Japan'),('JFK','John F. Kennedy International	','New York	','United States of America'),('LAX','Los Angeles International','Los Angeles','United States of America'),('LGA','LaGuardia','New York	','United States of America'),('LHR','London Heathrow','London','United Kingdom'),('ORD','Chicago O\'Hare International','Chicago','United States of America'),('SFO','San Francisco International','San Francisco','United States of America\n'),('TNR','Ivato International','Antananarivo','Madagascar'),('TXL','Berlin Tegel','Berlin','Germany');

INSERT INTO `Person` VALUES (1,'Mary','Jane','123-01 Random St','Random Town','NY',11111),(2,'John','Mark','321-02 Lost St','Lost Town','NY',12222),(1234,'John','Doe','123 N Fake Street','New York','New York',10001),(2653,'Rick','Astley','1337 Internet Lane','Los Angeles','California',90001),(5555,'Jane','Smith','100 Nicolls Rd','Stony Brook','New York',17790);

INSERT INTO `Customer` VALUES (1234,123,'4111111111111111','jdoe@woot.com','2010-01-05 17:00:00',8,'123-123-1234'),(2653,314,'4012888888881881','rickroller@rolld.com','2010-01-13 23:00:00',10,'314-159-2653'),(5555,555,'5105105105105100','awesomejane@ftw.com','2010-02-06 09:00:00',7,'555-555-5555');

INSERT INTO `Employee` VALUES (1,111111111,0,'2010-01-01',40.00,'012-345-6789','emp1@email.com'),(2,222222222,1,'2009-01-01',80.00,'111-222-3333','emp2@email.com');

INSERT INTO `Flight` VALUES ('AA',111,100,'1010100',2,4),('AM',1337,33,'0000011',1,2),('JA',111,150,'1111111',7,10);

INSERT INTO `Auctions` VALUES (123,'AA',111,'Economy','2011-01-01 11:00:00',400.00);

INSERT INTO `Leg` VALUES ('AA',111,1,'HND','LGA','2011-01-05 09:00:00',NULL,'2011-01-05 11:00:00',NULL),('AA',111,2,'LGA','LAX','2011-01-05 17:00:00',NULL,'2011-01-05 19:00:00',NULL),('AA',111,3,'LAX','HND','2011-01-06 07:30:00',NULL,'2011-01-06 10:00:00',NULL),('AM',1337,1,'TNR','JFK','2011-01-13 05:00:00',NULL,'2011-01-13 07:00:00',NULL),('AM',1337,2,'JFK','TNR','2011-01-13 23:00:00',NULL,'2011-01-14 03:00:00',NULL),('JA',111,1,'LHR','SFO','2011-01-10 12:00:00',NULL,'2011-01-10 14:00:00',NULL),('JA',111,2,'SFO','BOS','2011-01-10 19:30:00',NULL,'2011-01-10 22:30:00',NULL),('JA',111,3,'BOS','LHR','2011-01-11 05:00:00',NULL,'2011-01-11 08:00:00',NULL);

INSERT INTO `Reservation` VALUES (111,'2011-01-04 11:00:00',120.00,1200.00,111111111,555),(222,'2011-01-13 22:30:00',50.00,500.00,111111111,123),(333,'2011-01-12 07:00:00',333.33,3333.33,111111111,314);

INSERT INTO `Includes` VALUES (111,'AA',111,1,'2011-01-05'),(111,'AA',111,2,'2011-01-05'),(222,'JA',111,2,'2011-01-14'),(333,'AM',1337,1,'2011-01-13');

INSERT INTO `Passenger` VALUES (1234,123),(2653,314),(5555,555);

INSERT INTO `Login` VALUES ('jdoe@woot.com','pass',0),('rickroller@rolld.com','pass',0),('awesomejane@ftw.com','pass',0),('emp1@email.com','pass',1),('emp2@email.com','pass',2);

INSERT INTO Fare (AirlineID, FlightNo, FareType, Class, Fare)
VALUES ("AA", 111, "One-Way", "Economy", 1200), ("JA", 111, "One-Way", "First", 500), ("AM", 1337, "One-Way", "First", 3333.33);

INSERT INTO ReservationPassenger(ResrNo, Id, AccountNo, SeatNo, Class, Meal)
VALUES ("111", 1234, 123, "33F", "Economy", "Chips"), ("222", 5555, 555, "13A", "First", "Fish and Chips"), ("333", 2653, 314, "1A", "First", "Sushi");

-- CREATE DATABASE Sec2_Grp17_HomeCare;
USE Sec2_Grp17_HomeCare;

CREATE TABLE Nurse ( 
 NurseID INT NOT NULL,
 HealthMinistryRegistrationNumber VARCHAR(10) NOT NULL,
 NurseName VARCHAR(100) NOT NULL,
 PhoneNumber BIGINT NOT NULL,
 DateOfBirth DATE NOT NULL,
 CONSTRAINT Pk_Nurse PRIMARY KEY (NurseID),
 CONSTRAINT Chk_PhnNum CHECK (PhoneNumber > 1000000000 AND PhoneNumber < 9999999999)
 );

CREATE TABLE Client ( 
 ClientID INT NOT NULL,
 ClientName VARCHAR(100) NOT NULL,
 ClientAddress VARCHAR(255) NOT NULL,
 ClientPhoneNumber CHAR(10) NOT NULL,
 PRIMARY KEY (ClientID)
 );

CREATE TABLE Contract ( 
 ContractID INT NOT NULL,
 StartDate DATE NOT NULL,
 EndDate DATE NOT NULL,
 IllnessDescription VARCHAR(1000),
 NurseID INT NOT NULL,
 ClientID INT NOT NULL,
 PRIMARY KEY (ContractID),
 FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID),
 FOREIGN KEY (ClientID) REFERENCES Client(ClientID)
 );
 
CREATE TABLE Nurse_Availability_Schedule ( 
 AvailabilityID INT NOT NULL,
 StartDate DATE NOT NULL,
 EndDate DATE NOT NULL,
 StartTime TIME NOT NULL,
 EndTime TIME NOT NULL,
 NurseID INT NOT NULL,
 PRIMARY KEY (AvailabilityID),
 FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID),
 UNIQUE(NurseID, StartDate, StartTime)
 );
 
CREATE TABLE Visit_Appointment ( 
 ContractID INT NOT NULL,
 AppointmentID INT NOT NULL,
 AppointmentDate DATE NOT NULL,
 AppointmentStartTime TIME NOT NULL,
 AppointmentEndTime TIME NOT NULL,
 VisitDate DATE,
 VisitStartTime TIME,
 VisitEndTime TIME,
 VisitHealthCondition VARCHAR(1000),
 VisitServicesProvided  VARCHAR(1000),
 PRIMARY KEY (ContractID, AppointmentID),
 FOREIGN KEY (ContractID) REFERENCES Contract(ContractID) ON DELETE CASCADE
 );
 
CREATE TABLE Nurse_Substitute_On_Contract ( 
 ContractID INT NOT NULL,
 NurseID INT NOT NULL,
 StartDate DATE NOT NULL,
 EndDate DATE NOT NULL,
 PRIMARY KEY (ContractID, NurseID),
 FOREIGN KEY (ContractID) REFERENCES Contract(ContractID) ON DELETE CASCADE,
 FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID)
 );
 
CREATE TABLE Contract_Schedule ( 
 ContractID INT NOT NULL,
 Weekday SMALLINT NOT NULL,
 StartTime TIME NOT NULL,
 EndTime TIME NOT NULL,
 PRIMARY KEY (ContractID, Weekday, StartTime),
 FOREIGN KEY (ContractID) REFERENCES Contract(ContractID) ON DELETE CASCADE
 );
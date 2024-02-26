-- Section 002
-- Group 17
-- Members: Samantha Liu, MySQL Expert
--          Devansh Takkar, MS SQL Expert
-- --------------------------------------
-- View creation queries are commented out at query 9 and 13

USE S2G17_HomeCare;

-- Q1. Display the nurse's name, phone number, and contract start date for all contracts.
SELECT NurseName, PhoneNumber, StartDate, EndDate
FROM Nurse
    INNER JOIN Contract ON Nurse.NurseID = Contract.NurseID;


-- Q2. To update the nurse's phone number to '9027890123' for a specific nurse (RN = R234566 Oliver Li) based on their health ministry registration number
UPDATE Nurse
SET PhoneNumber = 9027890123 WHERE HealthMinistryRegistrationNumber = 'R234566';

SELECT NurseName, PhoneNumber, HealthMinistryRegistrationNumber
FROM Nurse
WHERE HealthMinistryRegistrationNumber = 'R234566';
-- Verify the update


-- Q3. Display the nurse's name and phone number who is available and not assigned to any appointments within June 2023
SELECT Nurse.NurseName, Nurse.PhoneNumber
FROM Nurse
    LEFT JOIN Nurse_Availability_Schedule ON Nurse.NurseID = Nurse_Availability_Schedule.NurseID
WHERE Nurse.NurseID NOT IN (
    SELECT DISTINCT Contract.NurseID
    FROM Contract
        INNER JOIN Visit_Appointment ON Contract.ContractID = Visit_Appointment.ContractID
    WHERE MONTH(Visit_Appointment.VisitDate) = 6 AND YEAR(Visit_Appointment.VisitDate) = 2023
)
    AND (
    Nurse_Availability_Schedule.StartDate IS NULL
    OR Nurse_Availability_Schedule.StartDate > '2023-06-30'
    OR Nurse_Availability_Schedule.EndDate IS NULL
    OR Nurse_Availability_Schedule.EndDate < '2023-06-01'
);


-- Q4. Create a view that shows the nurse's name and their visit appointments in June. 
CREATE VIEW Nurse_Appointments AS
SELECT Nurse.NurseName, Visit_Appointment.AppointmentDate, Visit_Appointment.AppointmentStartTime, Visit_Appointment.AppointmentEndTime
FROM Nurse
INNER JOIN Contract ON Nurse.NurseID = Contract.NurseID
INNER JOIN Visit_Appointment ON Contract.ContractID = Visit_Appointment.ContractID
WHERE Visit_Appointment.AppointmentDate >= '2023-06-01' AND Visit_Appointment.AppointmentDate <= '2023-06-30'
ORDER BY NurseName, Visit_Appointment.AppointmentDate;

SELECT *
FROM Nurse_Appointments;


-- Q5. Show the name of nurse and how many days they are available for in descending order 
-- DATEDIFF function behaves differently on MS SQL and MySQL
-- MS SQL Version
SELECT Nurse.NurseID, NurseName, SUM(DATEDIFF(DAY, EndDate, StartDate)) AS 'Total_Days_Available'
FROM Nurse_Availability_Schedule INNER JOIN Nurse ON Nurse.NurseID = Nurse_Availability_Schedule.NurseID
GROUP BY Nurse.NurseID, NurseName
ORDER BY Total_Days_Available DESC;

-- MySQL Version
SELECT Nurse.NurseID, NurseName, SUM(DATEDIFF(EndDate, StartDate)) AS 'Total_Days_Available'
FROM Nurse_Availability_Schedule INNER JOIN Nurse ON Nurse.NurseID = Nurse_Availability_Schedule.NurseID
GROUP BY Nurse.NurseID, NurseName
ORDER BY Total_Days_Available DESC;


-- Q6. Calculate the total number of visit appointments for a nurse.
SELECT Nurse.NurseName, COUNT(*) AS TotalAppointments
FROM Nurse
    INNER JOIN Contract ON Nurse.NurseID = Contract.NurseID
    INNER JOIN Visit_Appointment ON Contract.ContractID = Visit_Appointment.ContractID
GROUP BY Nurse.NurseName;


-- Q7.  Calculate the average duration of visits for a specific nurse
-- DATEDIFF function behaves differently on MS SQL and MySQL
-- MS SQL Version
SELECT Nurse.NurseName, AVG(DATEDIFF(MINUTE, VisitStartTime, VisitEndTime)) AS AverageDuration
FROM Nurse
    INNER JOIN Contract ON Nurse.NurseID = Contract.NurseID
    INNER JOIN Visit_Appointment ON Contract.ContractID = Visit_Appointment.ContractID
GROUP BY Nurse.NurseName;

-- MySQL Version
SELECT Nurse.NurseName, AVG(TIMESTAMPDIFF(MINUTE, VisitStartTime, VisitEndTime)) AS AverageDuration
FROM Nurse
    INNER JOIN Contract ON Nurse.NurseID = Contract.NurseID
    INNER JOIN Visit_Appointment ON Contract.ContractID = Visit_Appointment.ContractID
GROUP BY Nurse.NurseName;


-- Q8. To count the number of distinct clients in the database who do not have a contract
SELECT COUNT(DISTINCT ClientID) AS ClientWithoutContractCount
FROM Client
WHERE ClientID NOT IN (SELECT DISTINCT ClientID
FROM Contract);


-- Q9. show all the clients that do not have any ongoing contarct with the company
-- Different method of getting current date in MS SQL / MySQL

-- MS SQL Version
SELECT ClientName, Max(EndDate) AS LastContractEndDate
FROM (
	SELECT Client.ClientID, ClientName, EndDate
    FROM Client LEFT JOIN Contract ON Contract.ClientID = Client.ClientID
    WHERE ContractID IS NULL OR EndDate < GETDATE()
) q
GROUP BY ClientName;

-- MySQL Version
SELECT ClientName, Max(EndDate) AS LastContractEndDate
FROM (
	SELECT Client.ClientID, ClientName, EndDate
    FROM Client LEFT JOIN Contract ON Contract.ClientID = Client.ClientID
    WHERE ContractID IS NULL OR EndDate < NOW()
) q
GROUP BY ClientName;



-- Q10. To calculate each contract duration, and display with the contract ID and client name
-- DATEDIFF function behaves differently on MS SQL and MySQL
-- MS SQL Version
SELECT Contract.ContractID, Client.ClientName, SUM(DATEDIFF(DAY, Contract.EndDate, Contract.StartDate)) AS Duration
FROM Contract
    JOIN Client ON Contract.ClientID = Client.ClientID
GROUP BY Contract.ContractID, Client.ClientName;

-- MySQL Version
SELECT Contract.ContractID, Client.ClientName, SUM(DATEDIFF(Contract.EndDate, Contract.StartDate)) AS Duration
FROM Contract
    JOIN Client ON Contract.ClientID = Client.ClientID
GROUP BY Contract.ContractID, Client.ClientName;


-- Q11. To display the contract ID, weekday, start time, and end time for all contract schedules.
SELECT Contract.ContractID, Contract_Schedule.Weekday, Contract_Schedule.StartTime, Contract_Schedule.EndTime
FROM Contract
    INNER JOIN Contract_Schedule ON Contract.ContractID = Contract_Schedule.ContractID;



-- Q12. Display the contractID, client name, client phone, contract start date, assigned nurse's name, and substitution nurse's name for all contracts with a substitution nurse
SELECT Contract.ContractID, Client.ClientName, Client.ClientPhoneNumber, Contract.StartDate, Nurse.NurseName AS AssignedNurse, SubstituteNurse.NurseName AS SubstitutionNurse
FROM Client
    INNER JOIN Contract ON Client.ClientID = Contract.ClientID
    INNER JOIN Nurse ON Contract.NurseID = Nurse.NurseID
    INNER JOIN Nurse_Substitute_On_Contract ON Contract.ContractID = Nurse_Substitute_On_Contract.ContractID
    INNER JOIN Nurse AS SubstituteNurse ON Nurse_Substitute_On_Contract.NurseID = SubstituteNurse.NurseID
ORDER BY ContractID;


-- Q13. All Substituted appointments
CREATE VIEW Simplified_Substitutions
AS
    SELECT N.ContractID, Contract.NurseID, Contract.StartDate AS 'OriginalStartDate', Contract.EndDate AS 'OriginalEndDate', N.SubstitutedBy, N.StartDate 'NewStartDate', N.EndDate AS 'NewEndDate'
    FROM (SELECT Nurse.NurseID, Nurse.NurseName, Nurse_Substitute_On_Contract.NurseID AS 'SubstitutedBy', Nurse_Substitute_On_Contract.StartDate, Nurse_Substitute_On_Contract.EndDate, Nurse_Substitute_On_Contract.ContractID
        FROM Nurse INNER JOIN Nurse_Substitute_On_Contract ON Nurse.NurseID = Nurse_Substitute_On_Contract.NurseID) AS N INNER JOIN Contract ON N.ContractID = Contract.ContractID;

CREATE VIEW Simplified_Appointment_Details
AS
    SELECT CONCAT(Visit_Appointment.ContractID,'-', Visit_Appointment.AppointmentID) AS 'AppointmentID', Contract.ContractID, Nurse.NurseID, Nurse.NurseName, Client.ClientID, Client.ClientName, Client.ClientAddress, Visit_Appointment.AppointmentDate, AppointmentStartTime
    FROM Visit_Appointment, Contract, Nurse, Client
    WHERE Visit_Appointment.ContractID = Contract.ContractID AND Contract.NurseID = Nurse.NurseID AND Contract.ClientID = Client.ClientID;


SELECT Simplified_Appointment_Details.AppointmentID, Simplified_Substitutions.NurseID, Simplified_Appointment_Details.ClientName, Simplified_Appointment_Details.AppointmentDate, Simplified_Appointment_Details.ClientAddress
FROM Simplified_Appointment_Details, Simplified_Substitutions
WHERE Simplified_Appointment_Details.NurseID = Simplified_Substitutions.NurseID AND Simplified_Appointment_Details.AppointmentDate BETWEEN Simplified_Substitutions.NewStartDate AND Simplified_Substitutions.NewEndDate;


-- Q14. List all the appointments details like the ClientId, ClientName, Nurse name, start time for a particular contract including the substituted ones for ContractID = 10.
SELECT Simplified_Appointment_Details.AppointmentID, Simplified_Appointment_Details.ClientID, Simplified_Appointment_Details.NurseID AS 'Original_Nurse', Simplified_Substitutions.SubstitutedBy 'Substitution', Simplified_Appointment_Details.AppointmentStartTime, Simplified_Appointment_Details.ClientAddress
FROM Simplified_Appointment_Details LEFT JOIN Simplified_Substitutions ON Simplified_Appointment_Details.ContractID = Simplified_Substitutions.ContractID AND Simplified_Appointment_Details.AppointmentDate BETWEEN Simplified_Substitutions.NewStartDate AND Simplified_Substitutions.NewEndDate
WHERE Simplified_Appointment_Details.ContractID = 10;



-- Q15. Display the Client name, Services Provide, health condition along with illness description for by a specific nurse (NurseID = 2)
SELECT ClientName, VisitServicesProvided, VisitHealthCondition, IllnessDescription, AppointmentDate
FROM Visit_Appointment
    INNER JOIN Contract ON Visit_Appointment.ContractID = Contract.ContractID
    INNER JOIN Nurse ON Nurse.NurseID = Contract.NurseID
    INNER JOIN Client ON Client.ClientID = Contract.ClientID
WHERE Contract.NurseID  = 2;

-- Q16. list of visits that did not met the schedule
SELECT CONCAT(ContractID, '-',AppointmentID) AS 'AppID', AppointmentDate, AppointmentStartTime, VisitStartTime
FROM Visit_Appointment
WHERE VisitStartTime > AppointmentStartTime;


-- Q17. Delete all contracts whose contract period fall between a specific time frame that is from may 15 to may 30.
DELETE FROM Contract WHERE StartDate >= '2023-05-15' AND EndDate < '2023-05-30';

-- Q18. Cancel / delete the appointments of the clients that live in richmond

DELETE FROM Visit_Appointment WHERE CONCAT(ContractID, '-',AppointmentID) IN (SELECT AppointmentID
FROM Simplified_Appointment_Details
WHERE ClientAddress LIKE '%Richmond%');




-- Q19. Cancel all the visit appointments for client ID 4 on weekends

-- Different handling for retrieving day of week in MS SQL and MySQL
-- MS SQL
DELETE FROM Visit_Appointment WHERE DATEPART(WEEKDAY, VisitDate) IN (1,7) AND CONCAT(ContractID, '-',AppointmentID) IN (SELECT CONCAT(ContractID, '-',AppointmentID)
    FROM Simplified_Appointment_Details
    WHERE ClientID = 4);

-- MySQL 
DELETE FROM Visit_Appointment WHERE DAYOFWEEK(VisitDate) IN (1,7) AND CONCAT(ContractID,'-', AppointmentID) IN (SELECT CONCAT(ContractID, '-',AppointmentID)
    FROM Simplified_Appointment_Details
    WHERE ClientID = 4);





-- Q20. To Delete a specific contract (ContractID = 8) and its associated records.
DELETE FROM Contract
WHERE ContractID = 8;

SELECT *
FROM Visit_Appointment
WHERE ContractID = 8;
-- verify ON DELETE CASCADE

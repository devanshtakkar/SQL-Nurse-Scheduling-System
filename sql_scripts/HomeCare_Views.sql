-- 1> Substitution details view
-- CREATE VIEW Simplified_Substitutions
-- AS
--     SELECT N.ContractID, Contract.NurseID, Contract.StartDate AS 'OriginalStartDate', Contract.EndDate AS 'OriginalEndDate', N.SubstitutedBy, N.StartDate 'NewStartDate', N.EndDate AS 'NewEndDate'
--     FROM (SELECT Nurse.NurseID, Nurse.NurseName, Nurse_Substitute_On_Contract.NurseID AS 'SubstitutedBy', Nurse_Substitute_On_Contract.StartDate, Nurse_Substitute_On_Contract.EndDate, Nurse_Substitute_On_Contract.ContractID
--         FROM Nurse INNER JOIN Nurse_Substitute_On_Contract ON Nurse.NurseID = Nurse_Substitute_On_Contract.NurseID) AS N INNER JOIN Contract ON N.ContractID = Contract.ContractID;

-- 6> create a simplified non substituted Appointment view


CREATE VIEW Simplified_Appointment_Details
AS
    SELECT CONCAT(Visit_Appointment.ContractID,'-', Visit_Appointment.AppointmentID) AS 'AppointmentID', Contract.ContractID, Nurse.NurseID, Nurse.NurseName, Client.ClientID, Client.ClientName, Client.ClientAddress, Visit_Appointment.AppointmentDate, AppointmentStartTime
    FROM Visit_Appointment, Contract, Nurse, Client
    WHERE Visit_Appointment.ContractID = Contract.ContractID AND Contract.NurseID = Nurse.NurseID AND Contract.ClientID = Client.ClientID;

-- CREATE VIEW Nurse_Appointments AS
-- SELECT Nurse.NurseName, Visit_Appointment.AppointmentDate, Visit_Appointment.AppointmentStartTime, Visit_Appointment.AppointmentEndTime
-- FROM Nurse
-- INNER JOIN Contract ON Nurse.NurseID = Contract.NurseID
-- INNER JOIN Visit_Appointment ON Contract.ContractID = Visit_Appointment.ContractID
-- WHERE Visit_Appointment.AppointmentDate >= '2023-06-01' AND Visit_Appointment.AppointmentDate <= '2023-06-30';

-- DROP VIEW Simplified_Substitutions;
-- DROP VIEW Simplified_Appointment_Details;
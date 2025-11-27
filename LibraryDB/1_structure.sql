-- PostgreSQL database creation script
CREATE DATABASE Library

-- Create schema for the library
CREATE SCHEMA IF NOT EXISTS Library;

-- TABLE DEFINITIONS

-- Table: User
CREATE TABLE Library.User (
    UserId integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    Email varchar(40),
    FirstName varchar(20),
    LastName varchar(20),
    CONSTRAINT PK_User_UserId PRIMARY KEY (UserId),
    CONSTRAINT UQ_User_Email UNIQUE (Email)
);

-- Table: Book
CREATE TABLE Library.Book (
    ISBN varchar(9) NOT NULL,
    Title varchar(40),
    Author varchar(40),
    Editorial varchar(40),
    Year integer,
    ThemeId integer,
    CONSTRAINT PK_Book_ISBN PRIMARY KEY (ISBN)
);

-- Table: Theme
CREATE TABLE Library.Theme (
    ThemeId integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    ThemeName varchar(20),
    CONSTRAINT PK_Theme_ThemeId PRIMARY KEY (ThemeId),
    CONSTRAINT UQ_Theme_ThemeName UNIQUE (ThemeName)
);

-- Table: LoansLog
CREATE TABLE Library.LoansLog (
    LogId integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    UserId integer,
    ISBN varchar(9),
    OperationType varchar(6),
    OperationDate timestamp,
    CONSTRAINT PK_LoansLog_LogId PRIMARY KEY (LogId)
);

-- Table: Loan
CREATE TABLE Library.Loan (
    LoanId integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    UserId integer,
    ISBN varchar(9),
    LoanDate date,
    ExpectedReturnDate date,
    ActualReturnDate date,
    CONSTRAINT PK_Loan_LoanId PRIMARY KEY (LoanId)
);

-- Foreign key constraints
-- Schema: Library
ALTER TABLE Library.Book ADD CONSTRAINT FK_Book_ThemeId_Theme_ThemeId FOREIGN KEY(ThemeId) REFERENCES Library.Theme(ThemeId);
ALTER TABLE Library.Loan ADD CONSTRAINT FK_Loan_ISBN_Book_ISBN FOREIGN KEY(ISBN) REFERENCES Library.Book(ISBN);
ALTER TABLE Library.Loan ADD CONSTRAINT FK_Loan_UserId_User_UserId FOREIGN KEY(UserId) REFERENCES Library.User(UserId);
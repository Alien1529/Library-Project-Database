-- STORE PROCEDURE TO INSERT A BOOK
CREATE OR REPLACE PROCEDURE sp_insert_book(
    p_isbn VARCHAR,
    p_title VARCHAR,
    p_author VARCHAR,
    p_editorial VARCHAR,
    p_year INT,
    p_themeid INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate that ISBN is unique
    IF EXISTS (SELECT 1 FROM Library.Book WHERE ISBN = p_isbn) THEN 
        RAISE EXCEPTION 'There is already a book with the number %', p_isbn;
    END IF; 

    -- Validate ISBN length (max 9 characters in this model)
    IF length(p_isbn) > 9 THEN
        RAISE EXCEPTION 'The book number % is invalid (too long)', p_isbn;
    END IF;

    -- Validate title is not empty and within length limit
    IF p_title IS NULL OR length(p_title) = 0 THEN
        RAISE EXCEPTION 'The title cannot be empty';
    END IF;
    IF length(p_title) > 40 THEN 
        RAISE EXCEPTION 'The title size is greater than 40 characters';
    END IF;

    -- Validate author is not empty and within length limit
    IF p_author IS NULL OR length(p_author) = 0 THEN
        RAISE EXCEPTION 'The author cannot be empty';
    END IF;
    IF length(p_author) > 40 THEN
        RAISE EXCEPTION 'The author name is too long';
    END IF;

    -- Validate editorial is not empty and within length limit
    IF p_editorial IS NULL OR length(p_editorial) = 0 THEN
        RAISE EXCEPTION 'The editorial cannot be empty';
    END IF;
    IF length(p_editorial) > 40 THEN
        RAISE EXCEPTION 'The editorial name is too long';
    END IF;

    -- Validate year is within a logical range
    IF p_year IS NULL OR p_year < 700 OR p_year > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'The year % is invalid', p_year;
    END IF;

    -- Validate that the theme exists
    IF NOT EXISTS (SELECT 1 FROM Library.Theme WHERE ThemeId = p_themeid) THEN
        RAISE EXCEPTION 'The theme id % does not exist', p_themeid;
    END IF;

    -- Insert the book into the table
    INSERT INTO Library.Book (ISBN, Title, Author, Editorial, Year, ThemeId)
    VALUES (p_isbn, p_title, p_author, p_editorial, p_year, p_themeid);
END;
$$;

------------------------------------------------------------------------------------------------------------------

-- STORE PROCEDURE TO INSERT A USER
CREATE OR REPLACE PROCEDURE sp_insert_user(
    p_email VARCHAR,
    p_firstname VARCHAR,
    p_lastname VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate that email is not empty
    IF p_email IS NULL OR length(trim(p_email)) = 0 THEN
        RAISE EXCEPTION 'Email cannot be empty';
    END IF;

    -- Validate email length
    IF length(p_email) > 40 THEN
        RAISE EXCEPTION 'Email length exceeds 40 characters';
    END IF;

    -- Validate email format (basic check for @ symbol)
    IF position('@' IN p_email) = 0 THEN
        RAISE EXCEPTION 'Email % is invalid format', p_email;
    END IF;

    -- Validate uniqueness of email
    IF EXISTS (SELECT 1 FROM Library.User WHERE Email = p_email) THEN
        RAISE EXCEPTION 'Email % already exists', p_email;
    END IF;

    -- Validate first name
    IF p_firstname IS NULL OR length(trim(p_firstname)) = 0 THEN
        RAISE EXCEPTION 'First name cannot be empty';
    END IF;
    IF length(p_firstname) > 20 THEN
        RAISE EXCEPTION 'First name length exceeds 20 characters';
    END IF;

    -- Validate last name
    IF p_lastname IS NULL OR length(trim(p_lastname)) = 0 THEN
        RAISE EXCEPTION 'Last name cannot be empty';
    END IF;
    IF length(p_lastname) > 20 THEN
        RAISE EXCEPTION 'Last name length exceeds 20 characters';
    END IF;

    -- Insert user into the table
    INSERT INTO Library.User (Email, FirstName, LastName)
    VALUES (p_email, p_firstname, p_lastname);
END;
$$;

------------------------------------------------------------------------------------------------------------------

-- STORE PROCEDURE TO REGISTER A BOOK LOAN
CREATE OR REPLACE PROCEDURE sp_register_loan(
    p_userid INT,
    p_isbn VARCHAR,
    p_loandate DATE,
    p_expectedreturndate DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate that the user exists
    IF NOT EXISTS (SELECT 1 FROM Library.User WHERE UserId = p_userid) THEN
        RAISE EXCEPTION 'User with id % does not exist', p_userid;
    END IF;

    -- Validate that the book exists
    IF NOT EXISTS (SELECT 1 FROM Library.Book WHERE ISBN = p_isbn) THEN
        RAISE EXCEPTION 'Book with ISBN % does not exist', p_isbn;
    END IF;

    -- Validate that the book is not already loaned out
    IF EXISTS (SELECT 1 FROM Library.Loan WHERE ISBN = p_isbn AND ActualReturnDate IS NULL) THEN
        RAISE EXCEPTION 'Book with ISBN % is already loaned out', p_isbn;
    END IF;

    -- Validate that the user does not have more than 3 active loans
    IF (SELECT COUNT(*) FROM Library.Loan WHERE UserId = p_userid AND ActualReturnDate IS NULL) >= 3 THEN
        RAISE EXCEPTION 'User % already has 3 active loans', p_userid;
    END IF;

    -- Validate loan date
    IF p_loandate IS NULL THEN
        RAISE EXCEPTION 'Loan date cannot be null';
    END IF;

    -- Validate expected return date
    IF p_expectedreturndate IS NULL THEN
        RAISE EXCEPTION 'Expected return date cannot be null';
    END IF;
    IF p_expectedreturndate <= p_loandate THEN
        RAISE EXCEPTION 'Expected return date % must be after loan date %', p_expectedreturndate, p_loandate;
    END IF;

    -- Insert loan record
    INSERT INTO Library.Loan (UserId, ISBN, LoanDate, ExpectedReturnDate)
    VALUES (p_userid, p_isbn, p_loandate, p_expectedreturndate);
END;
$$;

------------------------------------------------------------------------------------------------------------------

-- STORE PROCEDURE TO REGISTER A BOOK RETURN BY ISBN
CREATE OR REPLACE PROCEDURE sp_register_return_by_isbn(
    p_isbn VARCHAR,
    p_actualreturndate DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_loanid INT;
    v_userid INT;
    v_loandate DATE;
BEGIN
    -- Validate that there is an active loan for this ISBN
    SELECT LoanId, UserId, LoanDate
    INTO v_loanid, v_userid, v_loandate
    FROM Library.Loan
    WHERE ISBN = p_isbn AND ActualReturnDate IS NULL
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No active loan found for book with ISBN %', p_isbn;
    END IF;

    -- Validate return date is not null
    IF p_actualreturndate IS NULL THEN
        RAISE EXCEPTION 'Return date cannot be null';
    END IF;

    -- Validate return date is after or equal to loan date
    IF p_actualreturndate < v_loandate THEN
        RAISE EXCEPTION 'Return date % cannot be before loan date %', p_actualreturndate, v_loandate;
    END IF;

    -- Optional: validate return date is not in the future
    IF p_actualreturndate > CURRENT_DATE THEN
        RAISE EXCEPTION 'Return date % cannot be in the future', p_actualreturndate;
    END IF;

    -- Update loan record with actual return date
    UPDATE Library.Loan
    SET ActualReturnDate = p_actualreturndate
    WHERE LoanId = v_loanid;
END;
$$;

------------------------------------------------------------------------------------------------------------------

-- VIEW TO DISPLAY THE HISTORY OF LOANS AND REPAYMENTS MADE BY A USER
CREATE OR REPLACE VIEW vw_user_history AS
SELECT 
    u.UserId, 
    u.Email, 
    b.Title, 
    l.OperationType, 
    l.OperationDate
FROM Library.LoansLog l
JOIN Library.User u ON l.UserId = u.UserId
JOIN Library.Book b ON l.ISBN = b.ISBN;

--------------------------------------------------------------


-- VIEW TO DISPLAY THE FIVE MOST BORROWED BOOKS
CREATE OR REPLACE VIEW vw_top5_books AS
SELECT 
    b.Title, 
    COUNT(*) AS LoanCount
FROM Library.Loan l
JOIN Library.Book b ON l.ISBN = b.ISBN
GROUP BY b.Title
ORDER BY LoanCount DESC
LIMIT 5;

--------------------------------------------------------------

-- VIEW TO DISPLAY THE USER WITH MORE THAN TWO ACTIVE LOANS, THAT IS, 
-- THOSE FOR WHOM REPAYMENT HAS NOT YET BEEN MADE
CREATE OR REPLACE VIEW vw_users_with_active_loans AS
SELECT 
    u.UserId, 
    u.Email, 
    COUNT(*) AS ActiveLoans
FROM Library.Loan l
JOIN Library.User u ON l.UserId = u.UserId
WHERE l.ActualReturnDate IS NULL
GROUP BY u.UserId, u.Email
HAVING COUNT(*) > 2;

--------------------------------------------------------------

-- VIEW TO DISPLAY BOOKS WITH THEIR THEMES
CREATE OR REPLACE VIEW vw_books_with_theme AS
SELECT 
    b.ISBN,
    b.Title,
    b.Author,
    b.Editorial,
    b.Year,
    t.ThemeName
FROM Library.Book b
JOIN Library.Theme t ON b.ThemeId = t.ThemeId;

------------------------------------------------------------------------------------------------------------------

-- TRIGGERS TO LOG LOANS AND RETURNS IN LoansLog TABLE
CREATE OR REPLACE FUNCTION fn_log_loan()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert into LoansLog when a new loan is created
    INSERT 
    INTO Library.LoansLog (
        UserId, 
        ISBN, 
        OperationType, 
        OperationDate)
    VALUES (
        NEW.UserId, 
        NEW.ISBN, 
        'Loan', 
        CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_log_loan
AFTER INSERT ON Library.Loan
FOR EACH ROW
EXECUTE FUNCTION fn_log_loan();

--------------------------------------------------------------


CREATE OR REPLACE FUNCTION fn_log_return()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Only log when ActualReturnDate is updated
    IF NEW.ActualReturnDate IS NOT NULL AND OLD.ActualReturnDate IS NULL THEN
        INSERT INTO Library.LoansLog (
            UserId, 
            ISBN, 
            OperationType, 
            OperationDate)
        VALUES (
            NEW.UserId, 
            NEW.ISBN, 
            'Return', 
            CURRENT_TIMESTAMP);
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_log_return
AFTER UPDATE OF ActualReturnDate ON Library.Loan
FOR EACH ROW
EXECUTE FUNCTION fn_log_return();



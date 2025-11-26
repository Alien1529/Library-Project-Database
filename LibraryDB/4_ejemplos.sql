-- EXAMPLES OF CALLING STORED PROCEDURES

-- STORE PROCEDURE TO INSERT A NEW BOOK

-- Insert a new valid book
CALL sp_insert_book('978-99999', 'Libro de prueba', 'Autor Demo', 'Editorial Demo', 2022, 1);

-- Try inserting a duplicate ISBN (should fail)
CALL sp_insert_book('978-12345', 'Otro título', 'Otro Autor', 'Otra Editorial', 2020, 1);

-- Invalid title length (too long, should fail)
CALL sp_insert_book('978-99998', repeat('A', 50), 'Autor Demo', 'Editorial Demo', 2020, 1);

---------------------------------------------------------

-- STORE PROCEDURE TO INSERT A NEW USER

-- Insert a new valid user
CALL sp_insert_user('test.user@example.com', 'Test', 'User');

-- Duplicate email (should fail)
CALL sp_insert_user('ana.gomez@example.com', 'Ana', 'Gómez');

-- Invalid email format (should fail)
CALL sp_insert_user('bademail.com', 'Bad', 'Email');

---------------------------------------------------------

-- STORE PROCEDURE TO REGISTER LOANS AND RETURNS

-- Ana Gómez (UserId = 1) borrows "Cien años de soledad"
CALL sp_register_loan(1, '978-12345', '2025-11-26', '2025-12-10');

-- Luis Martínez (UserId = 2) borrows "Don Quijote de la Mancha"
CALL sp_register_loan(2, '978-98765', '2025-11-26', '2025-12-15');

-- Try to borrow a book already loaned (should fail)
CALL sp_register_loan(3, '978-12345', '2025-11-27', '2025-12-12');

-- User with 3 active loans (should fail on the 4th)
CALL sp_register_loan(3, '978-11111', '2025-11-26', '2025-12-10');
CALL sp_register_loan(3, '978-22222', '2025-11-26', '2025-12-10');
CALL sp_register_loan(3, '978-33333', '2025-11-26', '2025-12-10');
CALL sp_register_loan(3, '978-44444', '2025-11-26', '2025-12-10'); -- should fail

---------------------------------------------------------

-- STORE PROCEDURE TO REGISTER A BOOK RETURN

-- Return Ana's loan (LoanId = 1)
CALL sp_register_return(1, '2025-12-05');

-- Try to return the same loan again (should fail)
CALL sp_register_return(1, '2025-12-06');

-- Invalid return date (before loan date, should fail)
CALL sp_register_return(2, '2025-11-20');

--------------------------------------------------------------------------------------------------

-- EXAMPLES OF QUERIES USING VIEWS

-- History of loans and returns for user with ID 1
SELECT * FROM vw_user_history WHERE UserId = 1;

-- Top 5 most borrowed books
SELECT * FROM vw_top5_books;

-- Users with active loans
SELECT * FROM vw_users_with_active_loans;
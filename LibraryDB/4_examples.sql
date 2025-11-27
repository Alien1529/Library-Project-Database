
-- INSERT EXAMPLE BOOKS USING THE STORED PROCEDURE

-- I use integer for ThemeId for ThemeName cause the ThemeNames are in other table to avoid incosistencies
CALL sp_insert_book(
    '978-99999',
    'La Odisea',
    'Homero',
    'Clásicos Griegos',
    800,
    1  -- ThemeId for Literatura
);

-- INSERT EXAMPLE USERS USING THE STORED PROCEDURE
CALL sp_insert_user(
    'sofia.ramirez@example.com',
    'Sofía',
    'Ramírez'
);

-- REGISTER A LOAN USING THE STORED PROCEDURE
CALL sp_register_loan(
    1,              -- UserId for Ana Gómez
    '978-12345',    -- ISBN for "Cien años de soledad"
    '2025-07-01',   -- Loan date
    '2025-07-15'    -- Expected return date
);

-- REGISTER A RETURN USING THE STORED PROCEDURE
CALL sp_register_return_by_isbn(
    '978-12345',    -- ISBN for "Cien años de soledad"
    '2025-07-10'    -- Actual return date
);

-- QUERY EXAMPLE VIEWS
SELECT *
FROM vw_user_history
WHERE Email = 'ana.gomez@example.com';

-- VIEW TO DISPLAY THE FIVE MOST BORROWED BOOKS
SELECT * FROM vw_top5_books;

-- VIEW TO DISPLAY USERS WITH MORE THAN TWO ACTIVE LOANS
SELECT * FROM vw_users_with_active_loans;

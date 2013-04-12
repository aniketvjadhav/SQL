-- Follow the given steps
-- 1. Execute all the scripts in the same order as given.
-- 2. The final execute statement will print the result from the table "FinalResult"
-- 3. Reading the result -> e.g. if the output for 8 queens 
--	  is  1 5 8 6 3 7 2 4 in the first row, it means 
--	  queen number 1 is placed in 1st column row 1
--    queen number 2 is placed in 5th column row 2
--    queen number 3 is placed in 8th column row 3
--    queen number 4 is placed in 6th column row 4
--    queen number 5 is placed in 3rd column row 5
--    queen number 6 is placed in 7th column row 6
--    queen number 7 is placed in 2nd column row 7
--    queen number 8 is placed in 4th column row 8


----------------Create following tables----------------

-- following table will act as an array which will store the position of non conflicting queen. Just one solution
CREATE TABLE dbo.QueenArray
(
    point		INT,
    position	INT
);

-- following table will contain all the solutions.

CREATE TABLE dbo.FinalResult
(
	Queens_Position		VARCHAR(1000)
);


----------------Execute following functions----------------

/*
	following function will get two parameters, @QueenNumber and @ColumnNumber
	e.g. if we get @QueenNumber = 3 and @ColumnNumber = 2, It will check whether 3rd queen, which is obviously in 3rd row,
	can be placed at 2nd column in non-attacking position to other previous queens.
*/

DROP FUNCTION dbo.placeQueen
CREATE FUNCTION dbo.placeQueen
(
	@QueenNumber		INT,
	@ColumnNumber		INT
)
RETURNS BIT
AS

BEGIN
	DECLARE @j INT
	SET	@j = 1
	DECLARE @position	INT
	
	WHILE	(@j <= (@QueenNumber-1))
		BEGIN
			SET @position = (SELECT	position FROM	QueenArray	WHERE	point = @j);
			
			IF	(@position = @ColumnNumber OR ABS(@position - @ColumnNumber) = (@QueenNumber - @j))
				RETURN 0
			
			SET @j = @j + 1
		END;

RETURN 1
END;


----------------Execute following procedures----------------

-----------------------------1---------------------------------

/*
	It is a recursive procedure which will call itself in order to find NQueen solutions.
*/

CREATE PROCEDURE dbo.NQueen
(
	@QueenNumber		INT,
	@TotalQueens		INT
)

AS
BEGIN

	DECLARE @i	INT
	SET	@i = 1;
	
	WHILE (@i <= @TotalQueens)
	BEGIN
		DECLARE @temp	INT
		SET @temp = (SELECT dbo.placeQueen(@QueenNumber, @i));
		IF (@temp = 1)
		BEGIN
			UPDATE dbo.QueenArray SET position = @i WHERE point = @QueenNumber;
			IF (@QueenNumber = @TotalQueens) -- checking the last queen and total queens are same. if yes, then print
			BEGIN
				DECLARE @Result		VARCHAR(2000)
				DECLARE @TempResult	VARCHAR(2000)
		
				DECLARE	@j			INT
				SET @j = 1
				SET @Result = '' -- result will have the non attacking queens in one row

				WHILE (@j <= @TotalQueens)
				BEGIN
					SET @TempResult = (SELECT CAST(position AS VARCHAR) FROM dbo.QueenArray WHERE point = @j);
		
					SET @Result = @Result + ' ' + @TempResult; --getting the result in one row
		
					SET @j = @j+1;
					
				END
					INSERT INTO dbo.FinalResult (Queens_Position) (SELECT @Result); --inserting the result into table
				
			END
			ELSE
			BEGIN
				DECLARE @NewQueenNumber	INT
				SET @NewQueenNumber = @QueenNumber+1; -- preparing the new number for the recursive call.
				EXECUTE dbo.NQueen @QueenNumber = @NewQueenNumber, @TotalQueens=@TotalQueens; -- the recursive call
			
			END
		END
		SET @i = @i+1;
	END
END


-------------------------------------------2--------------------------------------------------
--following procedure is created to run the program and delete any previous data.

CREATE PROCEDURE dbo.NQueenRun
(
	@TotalQueens		INT
)

AS
BEGIN
	TRUNCATE TABLE dbo.FinalResult --preparing final result for storing the final results
	TRUNCATE TABLE dbo.QueenArray -- preparing the array.
	
	DECLARE @i	INT
	SET @i = 1;
	
	WHILE	(@i <= @TotalQueens)
	BEGIN
		INSERT INTO dbo.QueenArray (point, position) VALUES (@i, 0); --initializing to the total number of queen elements and initialzing them to 0.
		SET @i=@i+1;	
	END
	
	
	EXECUTE dbo.NQueen @QueenNumber = 1, @TotalQueens=@TotalQueens;
	SELECT * FROM FinalResult
END


------------------------EXECUTE FOLLOWING STATEMENT TO GET THE ANSWER--------------------

EXECUTE dbo.NQueenRun @TotalQueens=8;
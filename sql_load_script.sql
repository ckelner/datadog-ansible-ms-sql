-- borrowed from http://use-the-index-luke.com/sql/example-schema/sql-server/performance-testing-scalability

--- It's required to run the test against a very large data set to make sure
--- caching does not affect the measurement. Depending on your environment,
--- you might need to create even larger tables to reproduce a linear result as
-- shown in the book.
CREATE TABLE scale_data (
   section NUMERIC NOT NULL,
   id1     NUMERIC NOT NULL,
   id2     NUMERIC NOT NULL,
   UNIQUE  (section, id1)
);
--- There is no primary key (to keep the data generation simple).
--- There is no index (yet). That's done after filling the table.
--- There is no “junk” column to keep the table small.

DECLARE @section INT
SET @section = 300

WHILE (@section >= 0) BEGIN

   WITH generate_series (n) AS (
      SELECT 1
      UNION ALL
      SELECT n + 1
        FROM generate_series
       WHERE N < 3000
   ), generate_series2 (n) AS (
      SELECT ROW_NUMBER() OVER(ORDER BY g1.n, g2.n)
        FROM generate_series g1
       CROSS JOIN generate_series g2
       WHERE g2.n <= @section
   )
   INSERT INTO scale_data
   SELECT @section, gen.*
        , CEILING(ABS(CAST(NEWID() AS BINARY(6)) %100))
     FROM generate_series2 gen
    WHERE gen.n <= @section * 3000
   OPTION(MAXRECURSION 32767);

   SET @section = @section -1
END;
GO

--- This code generates 300 sections (highlighted). You may need to adjust the number for your environment.
--- The table will need some gigabytes.
CREATE INDEX scale_slow ON scale_data(section, id1, id2);
GO

--- The index will also need some gigabytes.
--- That might take ages.
CREATE VIEW rand_helper AS SELECT rnd=RAND();
GO

CREATE FUNCTION [dbo].test_scalability (@n int)
   RETURNS @table TABLE
( section  NUMERIC NOT NULL PRIMARY KEY,
  duration NUMERIC NOT NULL,
  rows     NUMERIC NOT NULL)
AS BEGIN
   DECLARE @strt DATETIME2
   DECLARE @iter INT
   DECLARE @xsec INT
   DECLARE @xcnt INT
   DECLARE @xrnd INT

   SET @iter = 0
   WHILE (@iter < @n) BEGIN
      SET @xsec = 0
      WHILE (@xsec < 300) BEGIN
         SELECT @xrnd=CEILING(rnd * 100) FROM rand_helper;
         SET @strt = SYSDATETIME()

         SELECT @xcnt = COUNT(*)
           FROM (SELECT *
                   FROM scale_data
                  WHERE section=@xsec
                    AND id2=@xrnd) tlb;

         IF @iter = 0 BEGIN
           INSERT INTO @table
           VALUES ( @xsec
                  , datediff(microsecond, @strt, SYSDATETIME())
                  , @xcnt);
         END; ELSE BEGIN
           UPDATE @table
              SET duration = duration
                  + datediff(microsecond, @strt, SYSDATETIME())
                , rows = rows + @xcnt
            WHERE section = @xsec
         END;
         SET @xsec = @xsec + 1
      END;
      SET @iter = @iter + 1
   END;

   RETURN;
END;

GO

--- The SCALABILITY_SCALABILITY function returns a table.
--- It's hard-coded to run the test 300 sections (highlighted).
--- The number of iterations is configurable
--- The RAND_HELPER view is required to bypass the use of RAND() in a function.
SELECT * FROM [dbo].[test_scalability] (10);

-- The counter test, with a better index, can be done like that:
CREATE INDEX scale_fast ON scale_data(section, id2, id1);
GO

SELECT * FROM [dbo].[test_scalability] (10);
GO

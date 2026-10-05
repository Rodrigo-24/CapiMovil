USE CapiMovilDB_Reconstruida;
GO

CREATE OR ALTER FUNCTION dbo.fn_Codigo_Sanitizar(@Texto NVARCHAR(4000))
RETURNS NVARCHAR(4000)
AS
BEGIN
    DECLARE @s NVARCHAR(4000) = UPPER(LTRIM(RTRIM(ISNULL(@Texto, N''))));
    DECLARE @r NVARCHAR(4000) = N'';
    DECLARE @i INT = 1;
    DECLARE @c NCHAR(1);

    SET @s = REPLACE(@s, N'Á', N'A');
    SET @s = REPLACE(@s, N'É', N'E');
    SET @s = REPLACE(@s, N'Í', N'I');
    SET @s = REPLACE(@s, N'Ó', N'O');
    SET @s = REPLACE(@s, N'Ú', N'U');
    SET @s = REPLACE(@s, N'Ü', N'U');
    SET @s = REPLACE(@s, N'Ñ', N'N');

    WHILE @i <= LEN(@s)
    BEGIN
        SET @c = SUBSTRING(@s, @i, 1);
        IF @c LIKE N'[A-Z0-9]' SET @r += @c;
        SET @i += 1;
    END;

    RETURN @r;
END;
GO

CREATE OR ALTER FUNCTION dbo.fn_Bus_Codigo_Fragmento
(
    @Placa NVARCHAR(100),
    @Marca NVARCHAR(100)
)
RETURNS VARCHAR(6)
AS
BEGIN
    DECLARE @placaSan NVARCHAR(100) = dbo.fn_Codigo_Sanitizar(@Placa);
    DECLARE @marcaSan NVARCHAR(100) = dbo.fn_Codigo_Sanitizar(@Marca);
    DECLARE @placaFrag NVARCHAR(6) = LEFT(@placaSan, 3);
    DECLARE @marcaFrag NVARCHAR(6) = LEFT(@marcaSan, 3);

    IF LEN(@placaFrag) < 3 SET @placaFrag += LEFT(@marcaSan, 3 - LEN(@placaFrag));
    IF LEN(@marcaFrag) < 3 SET @marcaFrag += LEFT(@placaSan, 3 - LEN(@marcaFrag));
    IF LEN(@placaFrag) < 3 SET @placaFrag += REPLICATE('B', 3 - LEN(@placaFrag));
    IF LEN(@marcaFrag) < 3 SET @marcaFrag += REPLICATE('U', 3 - LEN(@marcaFrag));

    RETURN CONVERT(VARCHAR(6), LEFT(@placaFrag, 3) + LEFT(@marcaFrag, 3));
END;
GO

-- SQL Server DDL for the financial star schema
-- Run each statement individually; batching is handled by the application layer.

-- Schema creation (handled via EXEC to satisfy single-statement batch requirement)
-- IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'dbo')
--     EXEC('CREATE SCHEMA [dbo]')

-- stg_financial_raw

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N'stg_financial_raw'
)
CREATE TABLE [dbo].[stg_financial_raw] (
    segment             NVARCHAR(MAX),
    country             NVARCHAR(MAX),
    product             NVARCHAR(MAX),
    discount_band       NVARCHAR(MAX),
    units_sold          NVARCHAR(MAX),
    manufacturing_price NVARCHAR(MAX),
    sale_price          NVARCHAR(MAX),
    gross_sales         NVARCHAR(MAX),
    discounts           NVARCHAR(MAX),
    sales               NVARCHAR(MAX),
    cogs                NVARCHAR(MAX),
    profit              NVARCHAR(MAX),
    date                NVARCHAR(MAX),
    month_number        NVARCHAR(MAX),
    month_name          NVARCHAR(MAX),
    year                NVARCHAR(MAX)
);

-- dim_date

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N'dim_date'
)
CREATE TABLE [dbo].[dim_date] (
    date_key            INT PRIMARY KEY,
    full_date           DATE NOT NULL,
    year                INT NOT NULL,
    quarter             INT NOT NULL,
    month               INT NOT NULL,
    month_name          NVARCHAR(20) NOT NULL,
    day                 INT NOT NULL,
    day_of_week         INT NOT NULL,
    day_name            NVARCHAR(20) NOT NULL,
    is_weekend          BIT NOT NULL
);

-- dim_country

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N'dim_country'
)
CREATE TABLE [dbo].[dim_country] (
    country_key         INT IDENTITY(1,1) PRIMARY KEY,
    country             NVARCHAR(100) NOT NULL
);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ux_dim_country_country'
      AND object_id = OBJECT_ID(N'[dbo].[dim_country]')
)
    CREATE UNIQUE INDEX [ux_dim_country_country] ON [dbo].[dim_country] (country);

-- dim_segment

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N'dim_segment'
)
CREATE TABLE [dbo].[dim_segment] (
    segment_key         INT IDENTITY(1,1) PRIMARY KEY,
    segment             NVARCHAR(100) NOT NULL
);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ux_dim_segment_segment'
      AND object_id = OBJECT_ID(N'[dbo].[dim_segment]')
)
    CREATE UNIQUE INDEX [ux_dim_segment_segment] ON [dbo].[dim_segment] (segment);

-- dim_product

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N'dim_product'
)
CREATE TABLE [dbo].[dim_product] (
    product_key         INT IDENTITY(1,1) PRIMARY KEY,
    product             NVARCHAR(200) NOT NULL
);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ux_dim_product_product'
      AND object_id = OBJECT_ID(N'[dbo].[dim_product]')
)
    CREATE UNIQUE INDEX [ux_dim_product_product] ON [dbo].[dim_product] (product);

-- dim_discount_band

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N'dim_discount_band'
)
CREATE TABLE [dbo].[dim_discount_band] (
    discount_band_key   INT IDENTITY(1,1) PRIMARY KEY,
    discount_band       NVARCHAR(50) NOT NULL
);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ux_dim_discount_band_discount_band'
      AND object_id = OBJECT_ID(N'[dbo].[dim_discount_band]')
)
    CREATE UNIQUE INDEX [ux_dim_discount_band_discount_band]
        ON [dbo].[dim_discount_band] (discount_band);

-- fact_financials

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N'fact_financials'
)
CREATE TABLE [dbo].[fact_financials] (
    fact_id              INT IDENTITY(1,1) PRIMARY KEY,
    source_row_hash      NVARCHAR(64) NOT NULL,
    date_key             INT NOT NULL REFERENCES [dbo].[dim_date](date_key),
    country_key          INT NOT NULL REFERENCES [dbo].[dim_country](country_key),
    segment_key          INT NOT NULL REFERENCES [dbo].[dim_segment](segment_key),
    product_key          INT NOT NULL REFERENCES [dbo].[dim_product](product_key),
    discount_band_key    INT NOT NULL REFERENCES [dbo].[dim_discount_band](discount_band_key),
    units_sold           DECIMAL(14, 4),
    manufacturing_price  DECIMAL(14, 4),
    sale_price           DECIMAL(14, 4),
    gross_sales          DECIMAL(14, 4) NOT NULL,
    discounts            DECIMAL(14, 4),
    sales                DECIMAL(14, 4) NOT NULL,
    cogs                 DECIMAL(14, 4) NOT NULL,
    profit               DECIMAL(14, 4) NOT NULL
);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ux_fact_financials_source_row_hash'
      AND object_id = OBJECT_ID(N'[dbo].[fact_financials]')
)
    CREATE UNIQUE INDEX [ux_fact_financials_source_row_hash]
        ON [dbo].[fact_financials] (source_row_hash);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ix_fact_financials_date_key'
      AND object_id = OBJECT_ID(N'[dbo].[fact_financials]')
)
    CREATE INDEX [ix_fact_financials_date_key] ON [dbo].[fact_financials] (date_key);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ix_fact_financials_country_key'
      AND object_id = OBJECT_ID(N'[dbo].[fact_financials]')
)
    CREATE INDEX [ix_fact_financials_country_key] ON [dbo].[fact_financials] (country_key);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ix_fact_financials_segment_key'
      AND object_id = OBJECT_ID(N'[dbo].[fact_financials]')
)
    CREATE INDEX [ix_fact_financials_segment_key] ON [dbo].[fact_financials] (segment_key);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ix_fact_financials_product_key'
      AND object_id = OBJECT_ID(N'[dbo].[fact_financials]')
)
    CREATE INDEX [ix_fact_financials_product_key] ON [dbo].[fact_financials] (product_key);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ix_fact_financials_discount_band_key'
      AND object_id = OBJECT_ID(N'[dbo].[fact_financials]')
)
    CREATE INDEX [ix_fact_financials_discount_band_key]
        ON [dbo].[fact_financials] (discount_band_key);

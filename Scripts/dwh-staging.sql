-- Firsе Initialize Dimensions
CREATE TABLE IF NOT EXISTS dim_countries
(
    country_id      SERIAL PRIMARY KEY,
    name            VARCHAR(40)
);

CREATE TABLE IF NOT EXISTS dim_pollution
(
    pollution_id    SERIAL PRIMARY KEY,
    rank            INT CHECK (rank >= 0)
);

CREATE TABLE IF NOT EXISTS dim_vehicles
(
    vehicle_id      SERIAL PRIMARY KEY,
    count           INT CHECK (count >= 0),
    type            VARCHAR(40)
);

CREATE TABLE IF NOT EXISTS dim_ranking_dates
(
    id      SERIAL PRIMARY KEY,
    date    DATE NOT NULL UNIQUE,
    year    SMALLINT CHECK (year >= 0),
    quarter SMALLINT CHECK (quarter >= 1 AND quarter <= 4),
    month   SMALLINT CHECK (month >= 1 AND month <= 12),
    day     SMALLINT CHECK (day >= 1 AND day <= 31)
);

CREATE TABLE IF NOT EXISTS dim_happiness
(
    happiness_id      SERIAL PRIMARY KEY,
    rank              INT CHECK (rank >= 0)
    coefficient       REAL CHECK (coefficient >= 0)
);
-- AT THIS POINT, DIMENSIONS END
-- ===================================
-- TRIGGER EXCLUDING DATA PART BY PART
CREATE OR REPLACE FUNCTION date_parts() RETURNS TRIGGER AS
$$
BEGIN
    UPDATE d_dates
    SET year    = date_part('year', NEW.date),
        quarter = date_part('quarter', NEW.date),
        month   = date_part('month', NEW.date),
        day     = date_part('day', NEW.date)
    WHERE date = NEW.date;

    RETURN NEW;
END
$$ LANGUAGE plpgsql;

-- ACTUALLY TRIGGER COVERING DATE BY ELEMENTS
CREATE TRIGGER date_parts
    AFTER INSERT
    ON d_dates
    FOR EACH ROW
EXECUTE PROCEDURE date_parts();

CREATE TABLE IF NOT EXISTS facts_ecology
(
    id                      SERIAL PRIMARY KEY,
    country_id              INT REFERENCES dim_countries    (country_id),
    pollution_id            INT REFERENCES dim_pollution    (pollution_id),
    vehicles_id             INT REFERENCES dim_vehicles     (vehicle_id),
    ranking_date_id         INT REFERENCES dim_ranking_date (date_id),
    happiness_id            INT REFERENCES dim_happiness_id (happiness_id),

    country_pollution_coef  REAL,
    country_vehicles_count  INT,
    country_happiness_coef  REAL,
    country_vehicle_type    VARCHAR(40),
    common_ecology_rank     INT,
    common_ecology_score    REAL,
    change_date             TIMESTAMP DEFAULT current_timestamp
);

-- =====================
-- DATA FROM CSVs
-- ======================

-- Data from Vehicles CSV
CREATE TABLE IF NOT EXISTS vehicle_topology
(
    id              SERIAL PRIMARY KEY,
    country_name    VARCHAR(40),
    insertion_date  VARCHAR(16),
    frequency       VARCHAR(16),
    indicator       VARCHAR(40),
    value           REAL
);

-- Data from CO2 CSV
-- "Country Name","Country Code","Indicator Name","Indicator Code"
CREATE TABLE IF NOT EXISTS pollution_topology
(
    id              SERIAL PRIMARY KEY,
    country_name    VARCHAR(40),
    country_code    VARCHAR(8)
    indicator       VARCHAR(40),
    indicator_code  VARCHAR (40),
    year            REAL
);

-- THIS IS VERSION WITH ALL THE YEARS, I DON'T KNOW WHY...
CREATE TABLE IF NOT EXISTS pollution_annual_topology
(
    id              SERIAL PRIMARY KEY,
    country_name    VARCHAR(40),
    country_code    VARCHAR(8)
    indicator       VARCHAR(40),
    indicator_code  VARCHAR (40),
    year_1960       REAL,
    year_1961       REAL,
    year_1962       REAL,
    year_1963       REAL,
    year_1964       REAL,
    year_1965       REAL,
    year_1966       REAL,
    year_1967       REAL,
    year_1968       REAL,
    year_1969       REAL,
    year_1970       REAL,
    year_1971       REAL,
    year_1972       REAL,
    year_1973       REAL,
    year_1974       REAL,
    year_1975       REAL,
    year_1976       REAL,
    year_1977       REAL,
    year_1978       REAL,
    year_1979       REAL,
    year_1980       REAL,
    year_1981       REAL,
    year_1982       REAL,
    year_1983       REAL,
    year_1984       REAL,
    year_1985       REAL,
    year_1986       REAL,
    year_1987       REAL,
    year_1988       REAL,
    year_1989       REAL,
    year_1990       REAL,
    year_1991       REAL,
    year_1992       REAL,
    year_1993       REAL,
    year_1994       REAL,
    year_1995       REAL,
    year_1996       REAL,
    year_1997       REAL,
    year_1998       REAL,
    year_1999       REAL,
    year_2000       REAL,
    year_2001       REAL,
    year_2002       REAL,
    year_2003       REAL,
    year_2004       REAL,
    year_2005       REAL,
    year_2006       REAL,
    year_2007       REAL,
    year_2008       REAL,
    year_2009       REAL,
    year_2010       REAL,
    year_2011       REAL,
    year_2012       REAL,
    year_2013       REAL,
    year_2014       REAL,
    year_2015       REAL,
    year_2016       REAL,
    year_2017       REAL,
    year_2018       REAL,
    year_2019       REAL
);

-- Data from HDI CSV
-- Afghanistan,AFG,2008,3.723589897
CREATE TABLE IF NOT EXISTS happiness_topology
(
    id              SERIAL PRIMARY KEY,
    country_name    VARCHAR(40),
    country_code    VARCHAR(8)
    year            VARCHAR(4),
    value           REAL
);


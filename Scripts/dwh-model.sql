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

-- THE LEVELS OF SUMMARIZATION
-- ===========================
-- THIS MAY BE USELESS...
-- ===========================
CREATE TABLE summary_levels
(
    id          SERIAL PRIMARY KEY,
    data_type   TEXT       NOT NULL UNIQUE
);

INSERT INTO summarization (type)
VALUES ('Country'),
       ('Vehicle'),
       ('Pollution Level'),
       ('Country Code');

CREATE TABLE IF NOT EXISTS facts_ecology
(
    id                      SERIAL PRIMARY KEY,
    country_id              INT REFERENCES dim_countries (country_id),
    pollution_id            INT REFERENCES dim_pollution (pollution_id),
    vehicles_id             INT REFERENCES dim_vehicles (vehicle_id),
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

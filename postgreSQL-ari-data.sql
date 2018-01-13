CREATE DATABASE ari;

CREATE TABLE aircraft (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE crew (
    id 		    SERIAL PRIMARY KEY,
    name 	    VARCHAR(50),
    birth_date 	    TIMESTAMP NOT NULL,
    employment_date TIMESTAMP NOT NULL
);

CREATE TABLE aircraft_crew (
    id 		 SERIAL PRIMARY KEY,
    aircraft_id  INTEGER REFERENCES aircraft,
    crew_id 	 INTEGER REFERENCES crew,
    assign_date  TIMESTAMP NOT NULL,
    release_date TIMESTAMP DEFAULT NULL
);

/* ================== */
/* Aircraft test data */

INSERT INTO aircraft (name) VALUES ('Bat Plane');
INSERT INTO aircraft (name) VALUES ('Voyager');

/* ============== */
/* Crew test data */

INSERT INTO crew (name, birth_date, employment_date) VALUES ('Ivan', '1990-01-01 01:00:00', '2010-01-01 01:00:00');
INSERT INTO crew (name, birth_date, employment_date) VALUES ('Petar', '1992-01-01 01:00:00', '2008-01-01 01:00:00');
INSERT INTO crew (name, birth_date, employment_date) VALUES ('Stipe', '1980-01-01 01:00:00', '1999-01-01 01:00:00');
INSERT INTO crew (name, birth_date, employment_date) VALUES ('Josip', '1985-01-01 01:00:00', '2000-01-01 01:00:00');
INSERT INTO crew (name, birth_date, employment_date) VALUES ('Duje', '1993-01-01 01:00:00', '2007-01-01 01:00:00');

/* ======================= */
/* Aircraft crew test data */

INSERT INTO aircraft_crew (aircraft_id, crew_id, assign_date, release_date) VALUES (1, 1, '2010-01-01 01:00:00', '2011-01-01 01:00:00');
INSERT INTO aircraft_crew (aircraft_id, crew_id, assign_date, release_date) VALUES (1, 2, '2010-01-02 01:00:00', '2011-01-07 01:00:00');
INSERT INTO aircraft_crew (aircraft_id, crew_id, assign_date, release_date) VALUES (1, 3, '2010-01-07 01:00:00', '2011-01-11 01:00:00');
INSERT INTO aircraft_crew (aircraft_id, crew_id, assign_date, release_date) VALUES (2, 4, '2011-08-02 01:00:00', '2011-02-17 01:00:00');
INSERT INTO aircraft_crew (aircraft_id, crew_id, assign_date, release_date) VALUES (2, 5, '2011-07-02 01:00:00', '2011-02-17 01:00:00');
INSERT INTO aircraft_crew (aircraft_id, crew_id, assign_date, release_date) VALUES (1, 3, '2001-08-02 01:00:00', '2005-02-17 01:00:00');
INSERT INTO aircraft_crew (aircraft_id, crew_id, assign_date, release_date) VALUES (1, 4, '2001-07-02 01:00:00', '2006-02-17 01:00:00');
INSERT INTO aircraft_crew (aircraft_id, crew_id, assign_date) VALUES (1, 4, '2012-07-02 01:00:00');
INSERT INTO aircraft_crew (aircraft_id, crew_id, assign_date) VALUES (1, 1, '2016-01-01 01:00:00');

/* =================================== */
/* Find name of the oldest crew member */
/* I wasn't sure if that means oldest by birth date, employment date or who was assignet to the plane first ... so I made all queries. */

SELECT name FROM crew ORDER BY birth_date LIMIT 1;
SELECT name FROM crew ORDER BY employment_date LIMIT 1;

SELECT name FROM crew
WHERE id =
(
    SELECT crew_id FROM aircraft_crew
    WHERE aircraft_id = 1 AND release_date IS NULL           /* Id of the required aircraft and crew member must still be on the plane. */
    ORDER BY current_timestamp - assign_date DESC LIMIT 1    /* If the release_date is not set he is still on that plane. */
);
/* Another option is to rewrite this with JOIN. */
SELECT name from crew
LEFT JOIN aircraft_crew on crew.id = aircraft_crew.crew_id
WHERE aircraft_id = 1 AND release_date IS NULL
ORDER BY current_timestamp - assign_date DESC LIMIT 1

/* ========================================================================= */
/* Find name of the n-th crew member (second oldest, fifth oldest and so on) */
/* I found the second oldest with OFFSET 1. For n-th oldest just replace OFFSET n-1 with your number. */

SELECT name FROM crew ORDER BY birth_date LIMIT 1 OFFSET 1;
SELECT name FROM crew ORDER BY employment_date LIMIT 1 OFFSET 1;

SELECT name FROM crew
WHERE id =
(
    SELECT crew_id FROM aircraft_crew
    WHERE aircraft_id = 1 AND release_date IS NULL                    /* Id of the required aircraft and crew member must still be on the plane. */
    ORDER BY current_timestamp - assign_date DESC LIMIT 1 OFFSET 1    /* If the release_date is not set he is still on that plane. */
);

/* ================================================================================= */
/* Find name of the most experienced crew member - that one who knows most aircrafts */

/* Count how many planes a crew member was assigned to, order by that number descending and pick the first. */
SELECT name FROM crew
ORDER BY
(
    SELECT COUNT(id)
    FROM aircraft_crew
    WHERE crew_id = crew.id
)
DESC LIMIT 1;

/* ======================================================================================================== */
/* Find name of the least experienced crew member - that one who knows least aircrafts (counting from zero) */

/* Count how many planes a crew member was assigned to, order by that number ascending and pick the first. */
SELECT name FROM crew
ORDER BY
(
    SELECT COUNT(id)
    FROM aircraft_crew
    WHERE crew_id = crew.id
)
LIMIT 1;

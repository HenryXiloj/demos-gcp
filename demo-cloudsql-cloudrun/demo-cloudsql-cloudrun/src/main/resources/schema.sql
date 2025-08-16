CREATE TABLE IF NOT EXISTS votes (
    vote_id SERIAL NOT NULL,
    time_cast timestamp NOT NULL,
    candidate VARCHAR(6) NOT NULL,
    PRIMARY KEY (vote_id)
);

CREATE TABLE IF NOT EXISTS totals (
    total_id SERIAL NOT NULL,
    candidate VARCHAR(6) NOT NULL,
    num_votes INT DEFAULT 0,
    PRIMARY KEY (total_id)
);
-- Add Role 
ALTER ROLE henry WITH REPLICATION;

-- Enable publication for your table
CREATE PUBLICATION my_pub FOR TABLE customers;

-- Insert and update
ALTER TABLE customers REPLICA IDENTITY FULL;

-- create SLOT
SELECT pg_create_logical_replication_slot('my_slot', 'wal2json');

-- Utils commands
/*
SELECT pid, state, usename, application_name, client_addr, backend_start
FROM pg_stat_activity
WHERE pid = 18255;
SELECT * FROM pg_replication_slots WHERE slot_name = 'my_slot';
SELECT pg_terminate_backend(18255);
SELECT pg_drop_replication_slot('my_slot');
SELECT pg_create_logical_replication_slot('my_slot', 'wal2json')
-- Drop the old publication (if safe)
DROP PUBLICATION IF EXISTS my_pub;
*/
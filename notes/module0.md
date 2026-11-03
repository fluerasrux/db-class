# Module 0 Notes

## Q4: When would I pick NoSQL over relational?

I'd use a NoSQL database for user sessions. A session is always looked up by one key, the session token stored in the user's browser cookie, 
and that lookup happens on every page load, so it has to be instant. Sessions are also temporary and should expire automatically after logout or inactivity. 
That combination of single-key lookups, speed, and auto-expiry is the key-value pattern, so I'd use Redis, which keeps data in memory and can expire keys on its own.

## Q6: What does it mean that Snowflake doesn't enforce primary keys?

In Snowflake, data quality is part of the pipeline, because standard tables don't enforce PRIMARY KEY, UNIQUE, or FOREIGN KEY constraints. 
Before loading data into clean tables, I'd run checks for duplicate keys, orphan foreign keys, and NULLs in required columns like IDs. 
An orphan foreign key is a value that points to a row that doesn't exist; a NULL foreign key can be fine, but a wrong one isn't. If a batch fails these checks, 
I'd fail or quarantine it instead of trusting the constraints.

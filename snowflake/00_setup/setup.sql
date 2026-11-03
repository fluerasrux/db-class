-- Snowflake trial setup: cheap warehouse + account-wide spending cap
-- Run once as ACCOUNTADMIN. Safe to rerun (idempotent).

CREATE WAREHOUSE IF NOT EXISTS LEARN_WH
  WAREHOUSE_SIZE = 'XSMALL'        -- size = how much compute power; each size up doubles the credits per hour, and XS is plenty for learning
  AUTO_SUSPEND = 60                -- turns off after 60 seconds with no queries, so I'm not billed for idle time
  AUTO_RESUME = TRUE               -- if it's off and I run a query, it turns back on by itself
  INITIALLY_SUSPENDED = TRUE;      -- starts off instead of running (and billing) the moment it's created

ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;                       -- default warehouse stayed on 600 s (10 min) after every query; cut it to 60 s
ALTER WAREHOUSE IF EXISTS SNOWFLAKE_LEARNING_WH SET AUTO_SUSPEND = 60;  -- same fix for the learning warehouse (was 300 s); IF EXISTS avoids an error if it's missing

CREATE RESOURCE MONITOR IF NOT EXISTS TRIAL_GUARD WITH
  CREDIT_QUOTA = 50                -- a credit is Snowflake's billing unit for compute; an XS warehouse uses 1 credit per hour, so 50 credits ≈ 50 hours of running
  FREQUENCY = NEVER                -- the budget never resets; MONTHLY would reset used credits to 0 every month, which I don't want for a 30-day trial
  START_TIMESTAMP = IMMEDIATELY    -- starts counting credits immediately
  TRIGGERS ON 75 PERCENT DO NOTIFY              -- at 75% it only sends a warning, nothing stops
           ON 100 PERCENT DO SUSPEND            -- at 100% warehouses stop, but queries already running finish
           ON 110 PERCENT DO SUSPEND_IMMEDIATE; -- at 110% everything stops and running queries are cancelled

ALTER ACCOUNT SET RESOURCE_MONITOR = TRIAL_GUARD;  -- the monitor does nothing until it's assigned; account level means it covers every warehouse in the account

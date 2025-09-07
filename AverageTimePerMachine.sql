Table: Activity
+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| machine_id     | int     |
| process_id     | int     |
| activity_type  | enum    |
| timestamp      | float   |
+----------------+---------+
The table shows the user activities for a factory website.
(machine_id, process_id, activity_type) is the primary key (combination of columns with unique values) of this table.
machine_id is the ID of a machine.
process_id is the ID of a process running on the machine with ID machine_id.
activity_type is an ENUM (category) of type ('start', 'end').
timestamp is a float representing the current time in seconds.
'start' means the machine starts the process at the given timestamp and 'end' means the machine ends the process at the given timestamp.
The 'start' timestamp will always be before the 'end' timestamp for every (machine_id, process_id) pair.
It is guaranteed that each (machine_id, process_id) pair has a 'start' and 'end' timestamp.

There is a factory website that has several machines each running the same number of processes. Write a solution to find the average time each machine takes to complete a process.

The time to complete a process is the 'end' timestamp minus the 'start' timestamp. The average time is calculated by the total time to complete every process on the machine divided by the number of processes that were run.

The resulting table should have the machine_id along with the average time as processing_time, which should be rounded to 3 decimal places.

Return the result table in any order.

The result format is in the following example.


Example 1:

Input: 
Activity table:
+------------+------------+---------------+-----------+
| machine_id | process_id | activity_type | timestamp |
+------------+------------+---------------+-----------+
| 0          | 0          | start         | 0.712     |
| 0          | 0          | end           | 1.520     |
| 0          | 1          | start         | 3.140     |
| 0          | 1          | end           | 4.120     |
| 1          | 0          | start         | 0.550     |
| 1          | 0          | end           | 1.550     |
| 1          | 1          | start         | 0.430     |
| 1          | 1          | end           | 1.420     |
| 2          | 0          | start         | 4.100     |
| 2          | 0          | end           | 4.512     |
| 2          | 1          | start         | 2.500     |
| 2          | 1          | end           | 5.000     |
+------------+------------+---------------+-----------+
Output: 
+------------+-----------------+
| machine_id | processing_time |
+------------+-----------------+
| 0          | 0.894           |
| 1          | 0.995           |
| 2          | 1.456           |
+------------+-----------------+

---***SOLUTION STARTS HERE***---
    
-- Approach: Conditional Aggregation (no self-join)
    
SELECT 
    a.machine_id,                                    -- Select machine_id to group results per machine
    ROUND(AVG(b.timestamp - a.timestamp), 3) AS processing_time  -- Calculate average (end - start) per machine, rounded to 3 decimals
FROM Activity a
JOIN Activity b
  ON a.machine_id = b.machine_id                     -- Match same machine
 AND a.process_id = b.process_id                     -- Match same process
WHERE a.activity_type = 'start'                      -- Keep only start rows in alias 'a'
  AND b.activity_type = 'end'                        -- Keep only end rows in alias 'b'
GROUP BY a.machine_id;                               -- Group by machine_id to compute the average per machine

-- Approach: Conditional Aggregation (no self-join)

SELECT 
    machine_id,                                      -- Select machine_id
    ROUND(AVG(process_time), 3) AS processing_time   -- Average process_time per machine, rounded to 3 decimals
FROM (
    SELECT 
        machine_id,                                  -- Group by machine_id
        process_id,                                  -- Group by process_id (since each process has one start and one end)
        MAX(CASE WHEN activity_type = 'end' THEN timestamp END) -   -- Extract the 'end' timestamp for this process
        MAX(CASE WHEN activity_type = 'start' THEN timestamp END)   -- Extract the 'start' timestamp for this process
        AS process_time                              -- Subtract to get duration for this process
    FROM Activity
    GROUP BY machine_id, process_id                  -- Ensure we get start and end per process
) t
GROUP BY machine_id;                                 -- Now average durations per machine

/* 
Twitter & BR-Elections project
Tool: MySQL
Authors: @mascalmeida & @jorgel-mendes
*/

USE br_elections;

-- CREATE VIEW WITH THE LAST UPDATE INFO
CREATE OR REPLACE VIEW vw_last_update
AS
SELECT profile_mentions.end, profile_mentions.end_date, profile_mentions.end_time 
FROM profile_mentions
ORDER BY profile_mentions.end DESC
LIMIT 1;
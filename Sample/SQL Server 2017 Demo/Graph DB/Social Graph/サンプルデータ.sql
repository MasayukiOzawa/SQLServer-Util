-- Create person node table
DROP TABLE IF EXISTS dbo.Person
DROP TABLE IF EXISTS dbo.friend

CREATE TABLE dbo.Person (ID integer PRIMARY KEY, name varchar(50)) AS NODE;
CREATE TABLE dbo.friend (start_date DATE) AS EDGE;

 -- Insert into node table
INSERT INTO dbo.Person VALUES (1, 'Alice');
INSERT INTO dbo.Person VALUES (2,'John');
INSERT INTO dbo.Person VALUES (3, 'Jacob');
INSERT INTO dbo.Person VALUES (4, 'Joseph');

-- Insert into edge table
INSERT INTO dbo.friend VALUES ((SELECT $node_id FROM dbo.Person WHERE name = 'Alice'),
(SELECT $node_id FROM dbo.Person WHERE name = 'John'), '9/15/2011');

INSERT INTO dbo.friend VALUES ((SELECT $node_id FROM dbo.Person WHERE name = 'Alice'),
(SELECT $node_id FROM dbo.Person WHERE name = 'Jacob'), '10/15/2011');

INSERT INTO dbo.friend VALUES ((SELECT $node_id FROM dbo.Person WHERE name = 'John'),
(SELECT $node_id FROM dbo.Person WHERE name = 'Jacob'), '10/15/2012');

INSERT INTO dbo.friend VALUES ((SELECT $node_id FROM dbo.Person WHERE name = 'John'),
(SELECT $node_id FROM dbo.Person WHERE name = 'Joseph'), '10/15/2012');


-- use MATCH in SELECT to find friends of Alice
SELECT Person2.name,start_date AS FriendName
FROM Person Person1, friend, Person Person2
WHERE MATCH(Person1-(friend)->Person2)
AND Person1.name = 'Alice';

SELECT 
Person2.name AS FiriendName, friend.start_date, Person3.name AS Friend_of_FriendName,
friend2.start_date
FROM Person Person1, friend, Person Person2, friend friend2, Person Person3
WHERE MATCH(Person1-(friend)->Person2-(friend2)->Person3)
AND Person1.name = 'Alice';

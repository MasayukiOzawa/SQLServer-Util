 INSERT INTO dbo.Station VALUES 
	('ìåó—ä‘'),
('íÜâõó—ä‘'),
	('ìÏó—ä‘'),('íﬂä‘'),
('ëÂòa'),
	('ç˜Éñãu'),('çÇç¿èaíJ'),('í∑å„'),
('è√ìÏë‰'),
	('òZâÔì˙ëÂëO'),('ëPçs'),('ì°ëÚñ{í¨'),
('ì°ëÚ'),
	('ñ{çîè¿'),('çîè¿äCä›'),
('ï–ê£ç]Émìá')
GO

INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ëäñÕëÂñÏ'),
    (SELECT $node_id FROM Station WHERE name = 'ìåó—ä‘'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ìåó—ä‘'),
    (SELECT $node_id FROM Station WHERE name = 'íÜâõó—ä‘'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ëäñÕëÂñÏ'),
    (SELECT $node_id FROM Station WHERE name = 'íÜâõó—ä‘'), 
	5, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'íÜâõó—ä‘'),
    (SELECT $node_id FROM Station WHERE name = 'ëÂòa'), 
	6, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'íÜâõó—ä‘'),
    (SELECT $node_id FROM Station WHERE name = 'ìÏó—ä‘'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ìÏó—ä‘'),
    (SELECT $node_id FROM Station WHERE name = 'íﬂä‘'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'íﬂä‘'),
    (SELECT $node_id FROM Station WHERE name = 'ëÂòa'), 
	3, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ëÂòa'),
    (SELECT $node_id FROM Station WHERE name = 'è√ìÏë‰'), 
	10, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ëÂòa'),
    (SELECT $node_id FROM Station WHERE name = 'ç˜Éñãu'), 
	3, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ç˜Éñãu'),
    (SELECT $node_id FROM Station WHERE name = 'çÇç¿èaíJ'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'çÇç¿èaíJ'),
    (SELECT $node_id FROM Station WHERE name = 'í∑å„'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'í∑å„'),
    (SELECT $node_id FROM Station WHERE name = 'è√ìÏë‰'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'è√ìÏë‰'),
    (SELECT $node_id FROM Station WHERE name = 'ì°ëÚ'), 
	10, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'è√ìÏë‰'),
    (SELECT $node_id FROM Station WHERE name = 'òZâÔì˙ëÂëO'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'òZâÔì˙ëÂëO'),
    (SELECT $node_id FROM Station WHERE name = 'ëPçs'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ëPçs'),
    (SELECT $node_id FROM Station WHERE name = 'ì°ëÚñ{í¨'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ì°ëÚñ{í¨'),
    (SELECT $node_id FROM Station WHERE name = 'ì°ëÚ'), 
	3, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ì°ëÚ'),
    (SELECT $node_id FROM Station WHERE name = 'ï–ê£ç]Émìá'), 
	7, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ì°ëÚ'),
    (SELECT $node_id FROM Station WHERE name = 'ñ{çîè¿'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'ñ{çîè¿'),
    (SELECT $node_id FROM Station WHERE name = 'çîè¿äCä›'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = 'çîè¿äCä›'),
    (SELECT $node_id FROM Station WHERE name = 'ï–ê£ç]Émìá'), 
	3, 0, 1, 1, 0)
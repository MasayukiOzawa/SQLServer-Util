 SET NOCOUNT ON
 GO

 DROP TABLE IF EXISTS Station
 DROP TABLE IF EXISTS Route
 GO
 
 CREATE TABLE dbo.Station (
	name varchar(50),
	INDEX IX_Station UNIQUE ($node_id),
	INDEX IX_Station_Name(name)
) AS NODE

 CREATE TABLE dbo.Route (
	Time int,
	IsExpress bit,
	IsLocal bit,
	IsUp bit,
	IsDown bit,
    INDEX IX_Route UNIQUE ($edge_id),
    INDEX IX_Route_From ($from_id),
    INDEX IX_Route_To ($to_id)
)AS EDGE
GO

 INSERT INTO dbo.Station VALUES 
('小田原'),
	('足柄'),('螢田'),('富水'),('栢山'),('開成'),
('新松田'),
('渋沢'),
('秦野'),
('東海大学前'),
('鶴巻温泉'),
('伊勢原'),
('愛甲石田'),
('本厚木'),
	('厚木'),
('海老名'),
	('座間'),('相武台前'),('小田急相模原'),
('相模大野'),
('町田'),
	('玉川学園前'),('鶴川'),('柿生'),
('新百合ヶ丘'),
	('百合ケ丘'),('読売ランド前'),('生田'),
('向ヶ丘遊園'),
('登戸'),
	('和泉多摩川'),('狛江'),('喜多見'),
('成城学園前'),
	('祖師ヶ谷大蔵'),('千歳船橋'),
('経堂'),
	('豪徳寺'),('梅ヶ丘'),('世田谷代田'),
('下北沢'),
	('東北沢'),
('代々木上原'),
	('代々木八幡'),('参宮橋'),('南新宿'),
('新宿')
GO

INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '小田原'),
    (SELECT $node_id FROM Station WHERE name = '足柄'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '小田原'),
    (SELECT $node_id FROM Station WHERE name = '新松田'), 
	8, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '足柄'),
    (SELECT $node_id FROM Station WHERE name = '螢田'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '螢田'),
    (SELECT $node_id FROM Station WHERE name = '富水'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '富水'),
    (SELECT $node_id FROM Station WHERE name = '栢山'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '栢山'),
    (SELECT $node_id FROM Station WHERE name = '開成'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '開成'),
    (SELECT $node_id FROM Station WHERE name = '新松田'), 
	3, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '新松田'),
    (SELECT $node_id FROM Station WHERE name = '渋沢'), 
	6, 1, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '渋沢'),
    (SELECT $node_id FROM Station WHERE name = '秦野'), 
	4, 1, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '秦野'),
    (SELECT $node_id FROM Station WHERE name = '東海大学前'), 
	5, 1, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '東海大学前'),
    (SELECT $node_id FROM Station WHERE name = '鶴巻温泉'), 
	1, 1, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '鶴巻温泉'),
    (SELECT $node_id FROM Station WHERE name = '伊勢原'), 
	4, 1, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '伊勢原'),
    (SELECT $node_id FROM Station WHERE name = '愛甲石田'), 
	4, 1, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '愛甲石田'),
    (SELECT $node_id FROM Station WHERE name = '本厚木'), 
	3, 1, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '本厚木'),
    (SELECT $node_id FROM Station WHERE name = '海老名'), 
	4, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '本厚木'),
    (SELECT $node_id FROM Station WHERE name = '厚木'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '厚木'),
    (SELECT $node_id FROM Station WHERE name = '海老名'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '海老名'),
    (SELECT $node_id FROM Station WHERE name = '相模大野'), 
	12,	1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '海老名'),
    (SELECT $node_id FROM Station WHERE name = '座間'), 
	4, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '座間'),
    (SELECT $node_id FROM Station WHERE name = '相武台前'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '相武台前'),
    (SELECT $node_id FROM Station WHERE name = '小田急相模原'), 
	3, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '小田急相模原'),
    (SELECT $node_id FROM Station WHERE name = '相模大野'), 
	3, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '相模大野'),
    (SELECT $node_id FROM Station WHERE name = '町田'), 
	2, 1, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '町田'),
    (SELECT $node_id FROM Station WHERE name = '新百合ヶ丘'), 
	11,	1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '町田'),
    (SELECT $node_id FROM Station WHERE name = '玉川学園前'), 
	3, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '玉川学園前'),
    (SELECT $node_id FROM Station WHERE name = '鶴川'), 
	3, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '鶴川'),
    (SELECT $node_id FROM Station WHERE name = '柿生'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '柿生'),
    (SELECT $node_id FROM Station WHERE name = '新百合ヶ丘'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '新百合ヶ丘'),
    (SELECT $node_id FROM Station WHERE name = '向ヶ丘遊園'), 
	5, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '新百合ヶ丘'),
    (SELECT $node_id FROM Station WHERE name = '百合ケ丘'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '百合ケ丘'),
    (SELECT $node_id FROM Station WHERE name = '読売ランド前'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '読売ランド前'),
    (SELECT $node_id FROM Station WHERE name = '生田'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '生田'),
    (SELECT $node_id FROM Station WHERE name = '向ヶ丘遊園'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '向ヶ丘遊園'),
    (SELECT $node_id FROM Station WHERE name = '登戸'), 
	1, 1, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '登戸'),
    (SELECT $node_id FROM Station WHERE name = '成城学園前'), 
	6, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '登戸'),
    (SELECT $node_id FROM Station WHERE name = '和泉多摩川'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '和泉多摩川'),
    (SELECT $node_id FROM Station WHERE name = '狛江'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '狛江'),
    (SELECT $node_id FROM Station WHERE name = '喜多見'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '喜多見'),
    (SELECT $node_id FROM Station WHERE name = '成城学園前'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '成城学園前'),
    (SELECT $node_id FROM Station WHERE name = '経堂'), 
	4, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '成城学園前'),
    (SELECT $node_id FROM Station WHERE name = '祖師ヶ谷大蔵'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '祖師ヶ谷大蔵'),
    (SELECT $node_id FROM Station WHERE name = '千歳船橋'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '千歳船橋'),
    (SELECT $node_id FROM Station WHERE name = '経堂'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '経堂'),
    (SELECT $node_id FROM Station WHERE name = '下北沢'), 
	3, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '経堂'),
    (SELECT $node_id FROM Station WHERE name = '豪徳寺'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '豪徳寺'),
    (SELECT $node_id FROM Station WHERE name = '梅ヶ丘'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '梅ヶ丘'),
    (SELECT $node_id FROM Station WHERE name = '世田谷代田'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '世田谷代田'),
    (SELECT $node_id FROM Station WHERE name = '下北沢'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '下北沢'),
    (SELECT $node_id FROM Station WHERE name = '代々木上原'), 
	2, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '下北沢'),
    (SELECT $node_id FROM Station WHERE name = '東北沢'), 
	2, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '東北沢'),
    (SELECT $node_id FROM Station WHERE name = '代々木上原'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '代々木上原'),
    (SELECT $node_id FROM Station WHERE name = '新宿'), 
	5, 1, 0, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '代々木上原'),
    (SELECT $node_id FROM Station WHERE name = '代々木八幡'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '代々木八幡'),
    (SELECT $node_id FROM Station WHERE name = '参宮橋'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '参宮橋'),
    (SELECT $node_id FROM Station WHERE name = '南新宿'), 
	1, 0, 1, 1, 0)
INSERT INTO Route VALUES (
	(SELECT $node_id FROM Station WHERE name = '南新宿'),
    (SELECT $node_id FROM Station WHERE name = '新宿'), 
	2, 0, 1, 1, 0)







SELECT
	From_Station.Name, To_Station.Name, Time, IsExpress, IsLocal
FROM
	Station From_Station, Route, Station AS To_Station
WHERE
	MATCH(From_Station-(Route)->To_Station)
/*
	AND
	Route.IsExpress = 1
	Route.IsLocal = 1
*/
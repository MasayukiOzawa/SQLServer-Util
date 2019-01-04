SELECT
	*
FROM
	sys.databases WITH(NOLOCK)
WHERE
	is_distributor = 1
	OR is_published = 1
	OR is_subscribed = 1
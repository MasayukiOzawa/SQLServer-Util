DECLARE @resource_0 bigint = 28;
DECLARE @resource_1 bigint = 2237202433;
DECLARE @resource_2 bigint = 1764504669;

-- resource_1 は int の上限を超えているため、bigint で扱います。
DECLARE @b0 binary(4) = CONVERT(binary(4), @resource_0);
DECLARE @b1 binary(4) = CONVERT(binary(4), @resource_1);
DECLARE @b2 binary(4) = CONVERT(binary(4), @resource_2);

-- KEY ハッシュ候補：
-- resource_1 の上位 2 バイトを反転し、
-- resource_2 の 4 バイトを反転して連結します。
DECLARE @hash_binary binary(6) =
      SUBSTRING(@b1, 2, 1)
    + SUBSTRING(@b1, 1, 1)
    + SUBSTRING(@b2, 4, 1)
    + SUBSTRING(@b2, 3, 1)
    + SUBSTRING(@b2, 2, 1)
    + SUBSTRING(@b2, 1, 1);

DECLARE @lock_hash varchar(14) =
    '(' + LOWER(CONVERT(varchar(12), @hash_binary, 2)) + ')';

-- 非公開の内部配置を仮定した HoBT ID 候補。
-- associated_object_id と照合するまでは確定値として扱わないでください。
DECLARE @hobt_binary binary(8) =
      SUBSTRING(@b1, 3, 2)
    + @b0
    + 0x0000;

DECLARE @hobt_id_candidate bigint =
    CONVERT(bigint, @hobt_binary);

SELECT
    DB_NAME(1)             AS database_name,
    @b0                    AS resource_0_hex,
    @b1                    AS resource_1_hex,
    @b2                    AS resource_2_hex,
    @hobt_binary           AS hobt_id_hex_candidate,
    @hobt_id_candidate     AS hobt_id_candidate,
    @lock_hash             AS lock_hash_candidate;
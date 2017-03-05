# SQL Server 関連のパフォーマンスモニター
<br>

### OS 系のカウンター

|オブジェクト|インスタンス|備考|
|:---|:---|:---|
|Memory|-||
|NUMA Node Memory|NUMA ノード単位|≧Windows Server 2012|
|Paging File|ページングファイル単位||
|Network Adapter|ネットワークアダプター単位||
|Network Interface|ネットワークインタフェース単位||
|Network Segment|%Net Utilization||
|Physical Disk<br>Logical Disk|物理ディスク単位<br>論理ディスク (ドライブレター) 単位||
|Process|プロセス単位||
|Processor|プロセッサーコア単位||
|System|||
|.NET Data Provider for SqlServer|||

### SQL Server 系のカウンター
|オブジェクト|インスタンス|備考|
|:---|:---|:---|
|SQLServer:Access Methods|インスタンス単位の情報||
|SQLServer:Batch Resp Statistics||≧SQL Server 2012|
|SQLServer:Buffer Manager|||
|SQLServer:Buffer Node|NUMA ノード単位|≧SQL Server 2012|
|SQLServer:Catalog Metadata|データベース単位||
|SQLServer:Databases|データベース単位||
|SQLServer:Deprecated Features|非サポート機能単位||
|SQLServer:Exec Statistics|実行方法単位||
|SQLServer:General Statistics|||
|SQLServer:HTTP Storage|||
|SQLServer:Latches||ラッチの発生状況を時系列データとして取得|
|SQLServer:Locks||ロックの発生状況を時系列データとして取得<br>ロック競合が解消したタイミングでデータが取得できるため、ロック競合が発生しているかは、Process blocked から取得する|
|SQLServer:Memory Manager|||
|SQLServer:Memory Node||≧SQL Server 2012|
|SQLServer:Plan Cache|||
|SQLServer:Query Execution||SQL Server 2012|
|SQLServer:Resource Pool Stats|||
|SQLServer:SQL Errors|||
|SQLServer:SQL Statistics|||
|SQLServer:Transactions||tempdb の使用状況の確認|
|SQLServer:Wait Statistics||待ち事象を時系列データとして取得|
|SQLServer:Workload Group Stats|||

### AlwaysOn 系のカウンター
|オブジェクト|インスタンス|備考|
|:---|:---|:---|
|SQLServer:Availability Replica||送受信のレートがネットワーク帯域の上限となっていないことを確認<br>プライマリとセカンダリで送信/受信のトレンドが異なる<br>プライマリで取得した場合 : 更新データの送信状況が取得可能<br>セカンダリで取得した場合 : 更新データの受信状況が取得可能<br>|
|SQLServer:Availability Replica||この項目はプライマリ側ではカウンターは上昇しないのでセカンダリー側で取得する必要がある<br>Redone Bytes/sec : 受信したログの適用 (Redo) 状況|
|SQLServer:Broker/DBM Transport||キューの情報が取れるというわけではないので参考情報<br>エンドポイント間のデータ通信状況|



## OS 系のカウンター

### Memory

|カウンター|閾値|備考|
|:---|:---|:---|
|Available Bytes<br>Available Kbytes<br>Available Mbytes|100 MB 以上|サーバーの空きメモリの状況|
|Page Faults/sec||ハードフォルト / ソフトフォルトを含んだ値となっている|
|Page Reads/sec|||
|Page Writes/sec|||
|Pages Input/sec|10 未満|ハードページフォルトを解決するためにディスクから読み取られたページ|
|Pages Output/sec||物理メモリを解放するためにディスクに書き込まれたページ|
|Pages/sec|||
|Free System Page|||
|Table Entries|||
|Free System Page Table Entries|||
|Pool Nonpaged Bytes|||
|Pool Paged Bytes|||
|System Cache Resident Bytes|||

### Paging File

|カウンター|閾値|備考|
|:---|:---|:---|
|% Usage|70% 未満|ページングファイルの使用状況|
|% Usage Peak|70% 未満|ページングファイルの使用状況のピーク|

### Network Interface

|カウンター|閾値|備考|
|:---|:---|:---|
|Bytes Received/sec|||
|Bytes Sent/sec|||
|Bytes Total/sec|ネットワーク帯域の上限に達していない||
|Output Queue Length|2 未満||


### Network Segment

|カウンター|閾値|備考|
|:---|:---|:---|
|%Net Utilization|||

### Physical Disk<br>Logical Disk

|カウンター|閾値|備考|
|:---|:---|:---|
|% Idle Time|20%|閾値を超えると I/O 競合が発生しだしている可能性がある|
|Current Disk Queue Length|物理ディスクあたり 2 未満||
|Disk Bytes/sec|||
|Disk Read Bytes/sec|ディスク速度の読み込み上限に達していない||
|Disk Reads/sec|||
|Disk Transfers/sec|||
|Disk Write Bytes/sec|ディスク速度の書き込み上限に達していない||
|Disk Writes/sec|||
|Avg. Disk Queue Length|||
|Avg. Disk Read Queue Length|||
|Avg. Disk sec/Read|||
|Avg. Disk sec/Write|||
|Avg. Disk sec/Transfer|||
|Avg. Disk Write Queue Length|||
|Avg. Disk Bytes/Read|||
|Avg. Disk Bytes/Transfer| 50 ～ 80 MB/sec<br>150 ～ 300 MB/sec|単一の物理ディスクの場合 : 一般的には 50 ～ 80 MB/sec で高負荷<br>SAN を使用している場合 : 150 ～ 300 MB/sec で高負荷<br>各ディスクの接続方式に応じて帯域の上限が変わってくるため、ディスク接続方式も意識する必要がある|
|Avg. Disk Bytes/Write|||

### Process

|カウンター|閾値|備考|
|:---|:---|:---|
|% Privileged Time||Processor time spent in Kernel/Windows mode by this specifc Application|
|% Processor Time|80% 未満|Processor time spent in Kernel/Windows mode by this specifc Application<br>% Processor Time (sqlservr):SQL Server<br>% Process (msmdsrv):SSAS|
|% User Time||Processor time spent in User Application mode by this specific application|
|% Handle Time|||
|% IO Data Operations/sec|||
|% IO Other Operations/sec|||
|Page Faults/sec|||
|Thread Count|||
|Working Set|||
|Private Bytes||「メモリ内のページロック」を使用している場合は Working Set ではなく Private Bytes を確認する|
|Virtual Bytes|||

### Processor

|カウンター|閾値|備考|
|:---|:---|:---|
|Processor Frequency||プロセッサの周波数。電源プランによっては周波数が一定していないことがある。一定していない場合は、電源プランが高パフォーマンスになっているかを確認する|

### System

|カウンター|閾値|備考|
|:---|:---|:---|
|Processor Queue Length|プロセッサあたり 2 未満||
|Context Switches/sec|15,000 未満|プロセッサあたり 300 〜 2000|


<br>
## SQL Server 系のカウンター

### SQLServer:Access Methods

|カウンター|閾値|備考|
|:---|:---|:---|
|Forwarded Records/sec|100 Batch Requests/sec あたり 10 未満|転送されたレコードポインターを使用してフェッチされたレコード|
|Full Scans/sec||ベース テーブルまたはインデックスのフルスキャン|
|Index Searches/sec|1 Full Scans/sec あたり 1000|インデックス検索の実施数|
|Page Splits/sec|100 Batch Requests/sec あたり 20 未満||
|Range Scans/sec|||
|Table Lock Escalations/sec|||
|Workfiles Created/sec|20 未満|ハッシュ結合やハッシュ集計のために tempdb に作成されたワークファイル|
|Worktables Created/sec|20 未満 |中間結果 / 一時テーブル / カーソル等のために tempdb に作成されたワークテーブル|
|FreeSpace Scans/sec|||
|Pages Allocated/sec|||
|Page Splits/sec||ページ分割の発生状況|
|Range Scans/sec |||
|Scan Point Revalidations/sec|||

### SQLServer:Buffer Manager

|カウンター|閾値|備考|
|:---|:---|:---|
|AWE lookup maps/sec|||
|AWE stolen maps/sec|||
|AWE unmap calls/sec|||
|AWE unmap pages/sec|||
|AWE write maps/sec|||
|Buffer cache hit ratio|100 未満||
|Checkpoint pages/sec||通常のチェックポイントプロセスによるデータへの書き込み|
|Database pages||データページ|
|Free List Stalls/sec|||
|Free pages||空きページ|
|Lazy Writes/sec|20未満|ダーティーページをメモリからフラッシュする|
|Page life expectancy|300 以上||
|Page lookups/sec||メモリ上のページ参照回数<br>ページの操作回数については 8KB を乗算することでサイズに置き換えることができる|
|Page reads/sec||ディスク上のページ参照回数<br>(Readahead reads + Page reads = 読み取りによるディスク参照回数)<br>|
|Page writes/sec|||
|Readahead pages/sec||先行読み取りにより参照されたディスク上のページ参照回数|
|Stolen pages||プランキャッシュ等で使用されるために Stole されたページ<br>(バッファプールから奪われたページ)|
|Reserved pages|||
|Target pages||SQL Server が算出した理想的なページ数|
|Total pages||バッファプールに割り当てられているページ数|
|Background writer pages/sec||SQL Server 2012 以降<br>間接チェックポイントにすることで、通常のチェックポイントと比較して、バックグラウンドでログ適用が動作し続けるため、書き込みのスパイクがなくなるが瞬間的な書き込みではなく恒常的な書き込みとなるため、負荷の変化傾向を意識する必要がある|
|Readahead time/sec||SQL Server 2014 以降|

### SQLServer:Databases

|カウンター|閾値|備考|
|:---|:---|:---|
|Log Flush Wait Time||トランザクションログのディスクへのフラッシュの際の待ち時間|
|Log Flush Waits/sec||トランザクションログのディスクへのフラッシュの際の待ち発生回数|
|Log Flush Write Time (ms)|||
|Log Flushes/sec|||
|Percent Log Used|||
|Transactions/sec|||
|Write transactions/sec|||
|Log Bytes Flush/sec||トランザクションログのディスクのフラッシュバイト数|
|Log Cache Hit Ratio|||
|Log Cache Reads/sec|||

### SQLServer:General Statistics

|カウンター|閾値|備考|
|:---|:---|:---|
|Logins/sec|||
|Logouts/sec|||
|Transactions|||
|User Connections|||
|Processes blocked|||
|Temp Tables Creation Rate||一時テーブルの作成レート (秒間作成数)|
|Temp Tables for Destruction|||

### SQLServer:Latches

|カウンター|閾値|備考|
|:---|:---|:---|
|Latch Waits/sec|||
|Total Latch Wait Time (ms)|||

### SQLServer:Locks

|カウンター|閾値|備考|
|:---|:---|:---|
|Lock Waits/sec|||
|Lock Wait Time (ms)|||
|Number of Deadlocks/sec|||
|Lock Requests/sec|||
|Lock Timeouts (timeout > 0)/sec |||
|Lock Timeouts/sec |||

### SQLServer:Memory Manager

|カウンター|閾値|備考|
|:---|:---|:---|
|Database Cache Memory (KB)|||
|Free Memory (KB)|||
|Granted Workspace memory (KB)||ハッシュ / ソート / バルクコピー / インデックス作成で使用するために実行中のプロセスに許可されているメモリの総容量|
|Memory Grants Outstanding|||
|Memory Grants Pending||メモリ取得の許可待ち|
|Total Server Memory (KB)|||
|Connection Memory (KB)|||
|Lock Blocks|||
|Lock Blocks Allocated|||
|Lock Memory (KB)|||
|Log Pool Memory (KB)|||
|Maximum Workspace Memory (KB)||ワークスペース領域で使用された最大のメモリサイズ|
|Optimizer Memory (KB)|||
|Reserved Server Memory (KB)|||
|SQL Cache Memory (KB)|||
|Stolen Server Memory (KB)|||
|Target Server Memory (KB)|||
|Total Server Memory (KB)|||
|Extension allocated pages||以下の項目は SQL Server 2014 以降|
|Extension free pages|||
|Extension in use as percentage|||
|Extension outstanding IO counter|||
|Extension page evictions/sec|||
|Extension page reads/sec|||
|Extension page unreferenced time|||
|Extension pages writes/sec|||

### SQLServer:Plan Cache

|カウンター|閾値|備考|
|:---|:---|:---|
|Cache Hit Ratio||Sql Plans : パラメータ化クエリ /アドホッククエリ<br>Object Plans : ストアド プロシージャ/関数/トリガー|
|Cache Object Counts|||
|Cache Object in use|||
|Cache Pages|||

### SQLServer:SQL Errors

|カウンター|閾値|備考|
|:---|:---|:---|
|Info Errors||クエリタイムアウト等でクライアントにエラーを返した場合に発生|

### SQLServer:SQL Statistics

|カウンター|閾値|備考|
|:---|:---|:---|
|Auto-Param Attempts/sec|||
|Batch Request/sec|||
|SQL Attention Rate/sec|||
|SQL Compilations/sec|||
|SQL Re-Compilations/sec|||

### SQLServer:SQL Statistics

|カウンター|閾値|備考|
|:---|:---|:---|
|Auto-Param Attempts/sec|||
|Batch Request/sec|||
|SQL Attention Rate/sec|||
|SQL Compilations/sec|||
|SQL Re-Compilations/sec|||

### SQLServer:Transactions
|カウンター|閾値|備考|
|:---|:---|:---|
|Free Space in tempdb (KB)|||
|Version Store Size (KB)|||

## AlwaysOn 系のカウンター
### SQLServer:Availability Replica
|カウンター|閾値|備考|
|:---|:---|:---|
|Bytes Received from Replica/sec||
|Bytes Sent to Replica/sec||
|Receives from Replica / sec||
|Resent Messages/sec||
|Sends to Replica to Replica/sec||
|Sends to Transport/sec||

### SQLServer:Availability Replica
|カウンター|閾値|備考|
|:---|:---|:---|
|Log Bytes Received/sec||
|Log Send Queue||
|Recovery Queue||
|Redone Bytes/sec||
|Transaction Delay||

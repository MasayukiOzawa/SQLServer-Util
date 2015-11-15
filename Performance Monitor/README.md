# SQL Server 関連のパフォーマンスモニター
<br>

**OS 系のカウンター**

|オブジェクト|インスタンス|カウンター|備考|
|:-|:-|:-|:-|
|Memory|-|Available BytesAvailable Kbytes<br>Available Mbytes<br>Page Faults/sec<br>Page Reads/sec<br>Page Writes/sec<br>Pages Input/sec<br>Pages Output/sec<br>Pages/sec<br>Free System Page<br>Table Entries<br>Free System Page Table Entries<br>Pool Nonpaged Bytes<br>Pool Paged Bytes<br>System Cache Resident Bytes|Available Mbytes : 100 MB 以上<br>Pages Input/sec : 10 未満<br>Available Bytes Mbytes : サーバーの空きメモリの状況<br>Page Fault/sec : ハードフォルト / ソフトフォルトを含んだ値となっている<br>Pages Input/sec : ハードページフォルトを解決するためにディスクから読み取られたページ<br>Pages Output/sec : 物理メモリを解放するためにディスクに書き込まれたページ|
|NUMA Node Memory<br>※ ≧Windows Server 2012|NUMA ノード単位|||
|Paging File|ページングファイル単位|% Usage Peak<br>% Usage Peak |%Usage : 70% 未満<br>%Usage Peak : 70% 未満<br><br>％ Usage : ページングファイルの使用状況<br>% Usage Peak : ページングファイルの使用状況のピーク<br>
|Network Adapter|ネットワークアダプター単位|||
|Network Interface|ネットワークインタフェース単位|Bytes Received/sec<br>Bytes Sent/sec<br>Bytes Total/sec<br>Output Queue Length|Output Queue Length : 2 未満<br>Bytes Total/sec : ネットワーク帯域の上限に達していない|
|Network Segment||%Net Utilization||
|Physical Disk<br>Logical Disk|物理ディスク単位<br>論理ディスク (ドライブレター) 単位|% Idle Time<br>Current Disk Queue Length<br>Disk Bytes/sec<br>Disk Read Bytes/sec<br>Disk Reads/sec<br>Disk Transfers/sec<br>Disk Write Bytes/sec<br>Disk Writes/sec<br>Avg. Disk Queue Length<br>Avg. Disk Read Queue Length<br>Avg. Disk sec/Read<br>Avg. Disk sec/Write<br>Avg. Disk sec/Transfer<br>Avg. Disk Write Queue Length<br>Avg. Disk Bytes/Read<br>Avg. Disk Bytes/Transfer<br>Avg. Disk Bytes/Write<br>|Current Disk Queue Length : 物理ディスクあたり 2 未満<br>Avg. Disk sec/Transfer : > 15～ 20ms<br><br>Disk Read Bytes/sec : ディスク速度の読み込み上限に達していない<br>Disk Write Bytes/sec : ディスク速度の書き込み上限に達していない<br>% Idle Time : 20% を超えると I/O 競合が発生しだしている可能性がある<br><br>Avg. Disk Bytes/Transfer<br>	単一の物理ディスクの場合 : 一般的には 50 ～ 80 MB/sec で高負荷<br>	SAN を使用している場合 : 150 ～ 300 MB/sec で高負荷<br>各ディスクの接続方式に応じて帯域の上限が変わってくるため、ディスク接続方式も意識する必要がある|
|Process|プロセス単位|% Privileged Time<br>% Processor Time<br>% User Time<br>% Handle Time<br>% IO Data Operations/sec<br>% IO Other Operations/sec<br>Page Faults/sec<br>Thread Count<br>Working Set<br>Private Bytes<br>Virtual Bytes<br>|% Processor Time (sqlservr)  : 80% 未満<br>% Process (msmdsrv) : 80% 未満 (SSAS のプロセス)<br><br>% Processor Time : Privileged + User mode by this specific Application<br>% Privileged Time : Processor time spent in Kernel/Windows mode by this specifc Application<br>% User Time : Processor time spent in User Application mode by this specific application<br><br>「メモリ内のページロック」を使用している場合は Working Set ではなく Private Bytes を確認する|
|Processor|プロセッサーコア単位|Processor Frequency|Processor Frequency : プロセッサの周波数。電源プランによっては周波数が一定していないことがある。一定していない場合は、電源プランが高パフォーマンスになっているかを確認する|
|System|-|Processor Queue Length<br>Context Switches/sec|Processor Queue Length : プロセッサあたり 2 未満<br>Context Switches/sec : 15,000 未満 (プロセッサあたり 300 〜 2000)|
|Server Work Queue|プロセッサコア単位|||
|.NET Data Provider for SqlServer||||

<br>
**SQL Server 系のカウンター**

|オブジェクト|インスタンス|カウンター|備考|
|:-|:-|:-|:-|
|SQLServer:Access Methods|インスタンス単位の情報|Forwarded Records/sec<br>Full Scans/sec<br>Index Searches/sec<br>Page Splits/sec<br>Range Scans/sec<br>Table Lock Escalations/sec<br>Workfiles Created/sec<br>Worktables Created/sec<br>FreeSpace Scans/sec<br>Pages Allocated/sec <br>Page Splits/sec<br>Range Scans/sec <br>Scan Point Revalidations/sec|Forwarded Records/sec : 100 Batch Requests/sec あたり 10 未満<br>Index Searches/sec : 1 Full Scans/sec あたり 1000 <br>Page Splits/sec : 100 Batch Requests/sec あたり 20 未満<br>Workfiles Created/sec : 20 未満 (hash 操作による tempdb の利用)<br>Worktables Created/sec : 20 未満 (ソート,グルーピングの中間結果のスプール / 変数 / カーソル)<br><br>Forwarded Records/sec : 転送されたレコードポインターを使用してフェッチされたレコード<br>Full Scans/sec : ベース テーブルまたはインデックスのフルスキャン<br>Index Searches/sec : インデックス検索の実施数<br>Page Splits/sec : ページ分割の発生状況<br>Workfiles Created/sec : ハッシュ結合やハッシュ集計のために tempdb に作成されたワークファイル<br>Worktables Created/sec : 中間結果 / 一時テーブル / カーソル等のために tempdb に作成されたワークテーブル|
|SQLServer:Batch Resp Statistics<br>※ ≧SQL Server 2012||||
|SQLServer:Buffer Manager||AWE lookup maps/sec<br>AWE stolen maps/sec<br>AWE unmap calls/sec<br>AWE unmap pages/sec<br>AWE write maps/sec<br>Buffer cache hit ratio<br>Checkpoint pages/sec<br>Database pages<br>Free List Stalls/sec<br>Free pages<br>Lazy Writes/sec<br>Page life expectancy<br>Page lookups/sec<br>Page reads/sec<br>Page writes/sec<br>Readahead pages/sec<br>Stolen pages <br>Reserved pages<br>Target pages <br>Total pages <br><br>SQL Server 2012 以降<br>Background writer pages/sec<br><br>SQL Server 2014 以降<br>Readahead time/sec<br>|Buffer cache hit ratio : 100 に近い値<br>Page life expectancy : 300 以上<br>Lazy Writes/sec : 20未満<br><br>Database pages : データページ<br>Free pages : 空きページ<br>Stolen pages : プランキャッシュ等で使用されるために Stole されたページ(バッファプールから奪われたページ)<br>Page lookups/sec : メモリ上のページ参照回数<br>Readahead pages/sec : 先行読み取りにより参照されたディスク上のページ参照回数<br>Page reads/sec : ディスク上のページ参照回数<br>(Readahead reads + Page reads = 読み取りによるディスク参照回数)<br>Target pages : SQL Server が算出した理想的なページ数<br>Total pages : バッファプールに割り当てられているページ数<br>※ページの操作回数については 8KB を乗算することでサイズに置き換えることができる<br>Lazy Writes/sec : ダーティーページをメモリからフラッシュする<br><br>Background Writer pages/sec : 間接チェックポイントによるデータへの書き込み<br>	間接チェックポイントにすることで、通常のチェックポイントと比較して、バックグラウンドでログ適用が動作し続けるため、書き込みのスパイクがなくなるが瞬間的な書き込みではなく恒常的な書き込みとなるため、負荷の変化傾向を意識する必要がある<br>Checkpoint pages/sec :通常のチェックポイントプロセスによるデータへの書き込み<br>|
|SQLServer:Buffer Node<br>※ ≧SQL Server 2012||NUMA ノード単位||
|SQLServer:Catalog Metadata|データベース単位|||
|SQLServer:Databases|データベース単位|Log Flush Wait Time<br>Log Flush Waits/sec<br>Log Flush Write Time (ms)<br>Log Flushes/sec<br>Percent Log Used<br>Transactions/sec<br>Write transactions/sec<br>Log Cache Hit Ratio<br>Log Cache Reads/sec<br>||
|SQLServer:Deprecated Features|非サポート機能単位|Usage||
|SQLServer:Exec Statistics|実行方法単位|||
|SQLServer:General Statistics||Logins/sec<br>Logouts/sec<br>Transactions<br>User Connections<br>Processes blocked<br>Temp Tables Creation Rate<br>Temp Tables for Destruction <br>|Temp Table Creation Rate : 一時テーブルの作成レート (秒間作成数)|
|SQLServer:HTTP Storage||||
|SQLServer:Latches||Latch Waits/sec<br>Total Latch Wait Time (ms)|ラッチの発生状況を時系列データとして取得|
|SQLServer:Locks||Lock Waits/sec<br>Lock Wait Time (ms)<br>Number of Deadlocks/sec<br>Lock Requests/sec<br>Lock Timeouts (timeout > 0)/sec <br>Lock Timeouts/sec <br>|ロックの発生状況を時系列データとして取得<br>ロック競合が解消したタイミングでデータが取得できるため、ロック競合が発生しているかは、Process blocked から取得する|
|SQLServer:Memory Manager||Database Cache Memory (KB)<br>Free Memory (KB)<br>Granted Workspace memory (KB)<br>Memory Grants Outstanding<br>Memory Grants Pending<br>Total Server Memory (KB)<br>Connection Memory (KB) <br>Lock Blocks <br>Lock Blocks Allocated <br>Lock Memory (KB) <br>Log Pool Memory (KB)<br>Maximum Workspace Memory (KB) <br>Optimizer Memory (KB) <br>Reserved Server Memory (KB)<br>SQL Cache Memory (KB) <br>Stolen Server Memory (KB)<br>Target Server Memory (KB) <br>Total Server Memory (KB)<br><br>SQL Server 2014 以降<br>Extension allocated pages<br>Extension free pages <br>Extension in use as percentage <br>Extension outstanding IO counter <br>Extension page evictions/sec <br>Extension page reads/sec <br>Extension page unreferenced time <br>Extension pages writes/sec|Granted Workspace Memory (KB) : ハッシュ / ソート / バルクコピー / インデックス作成で使用するために実行中のプロセスに許可されているメモリの総容量<br>Maximum Workspace Memory (KB) : ワークスペース領域で使用された最大のメモリサイズ<br>Memory Grants Pending  : メモリ取得の許可待ち<br><br>バッファキャッシュのメモリ使用状況の確認<br>メモリの使用状況は負荷をかけるアプリケーションに依存するのでAlwaysOn の検証としては参考情報<br>HADR のワークロードでは Log Pool Memory の状態を確認|
|SQLServer:Memory Node<br>※ ≧SQL Server 2012||||
|SQLServer:Plan Cache||Cache Hit Ratio<br>Cache Object Counts<br>Cache Object in use<br>Cache Pages|Sql Plans : パラメータ化クエリ /アドホッククエリ<br>Object Plans : ストアド プロシージャ/関数/トリガー<br>|
|SQLServer:Query Execution<br>※SQL Server 2012||||
|SQLServer:Resource Pool Stats||||
|SQLServer:SQL Errors||Info Errors|クエリタイムアウト等でクライアントにエラーを返した場合に発生|
|SQLServer:SQL Statistics||Auto-Param Attempts/sec<br>Batch Request/sec<br>SQL Attention Rate/sec<br>SQL Compilations/sec<br>SQL Re-Compilations/sec<br>||
|SQLServer:Transactions||Free Space in tempdb (KB)<br>Version Store Size (KB)|tempdb の使用状況の確認|
|SQLServer:Wait Statistics||||
|SQLServer:Workload Group Stats||||

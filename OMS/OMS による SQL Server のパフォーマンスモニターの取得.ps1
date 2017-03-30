Add-AzureRmAccount

# サブスクリプションの選択
$Subscription = Get-AzureRmSubscription | Out-GridView -OutputMode Single
Select-AzureRmSubscription -SubscriptionId $Subscription.SubscriptionId 

# リソースグループの選択
$rgroup = Get-AzureRmResourceGroup | Out-GridView -OutputMode Single

# ワークスペースの選択
$workspace = Get-AzureRmOperationalInsightsWorkspace -ResourceGroupName $rgroup.ResourceGroupName | Out-GridView -OutputMode Single

$json =@"
[
    {
        "ObjectName" : "Memory",
        "Counter" : [
            {"counterName" : "Available MBytes"},
            {"counterName" : "Page Faults/sec"},
            {"counterName" : "Page Reads/sec"},
            {"counterName" : "Page Writes/sec"},
            {"counterName" : "Pages Input/sec"},
            {"counterName" : "Pages Output/sec"},
            {"counterName" : "Pages/sec"},
            {"counterName" : "Pool Nonpaged Bytes"},
            {"counterName" : "Pool Paged Bytes"},
            {"counterName" : "System Cache Resident Bytes"}
        ]
    },
    {
        "ObjectName" : "Paging File",
        "Counter" : [
            {"counterName" : "% Usage"},
            {"counterName" : "% Usage Peak"}
        ]
    },
    {
        "ObjectName" : "Network Adapter",
        "Counter" : [
            {"counterName" : "Bytes Received/sec"},
            {"counterName" : "Bytes Sent/sec"},
            {"counterName" : "Bytes Total/sec"},
            {"counterName" : "Current Bandwidth"},
            {"counterName" : "Output Queue Length"}
        ]
    },
    {
        "ObjectName" : "Network Interface",
        "Counter" : [
            {"counterName" : "Bytes Received/sec"},
            {"counterName" : "Bytes Sent/sec"},
            {"counterName" : "Bytes Total/sec"},
            {"counterName" : "Current Bandwidth"},
            {"counterName" : "Output Queue Length"}
        ]
    },
    {
        "ObjectName" : "PhysicalDisk",
        "Counter" : [
            {"counterName" : "Avg. Disk Bytes/Transfer"},
            {"counterName" : "Avg. Disk Bytes/Write"},
            {"counterName" : "Avg. Disk Queue Length"},
            {"counterName" : "Avg. Disk Read Queue Length"},
            {"counterName" : "Avg. Disk sec/Read"},
            {"counterName" : "Avg. Disk sec/Transfer"},
            {"counterName" : "Avg. Disk sec/Write"},
            {"counterName" : "Avg. Disk Write Queue Length"},
            {"counterName" : "Current Disk Queue Length"},
            {"counterName" : "Disk Bytes/sec"},
            {"counterName" : "Disk Read Bytes/sec"},
            {"counterName" : "Disk Reads/sec"},
            {"counterName" : "Disk Transfers/sec"},
            {"counterName" : "Disk Write Bytes/sec"},
            {"counterName" : "Disk Writes/sec"}
        ]
    },
    {
        "ObjectName" : "LogicalDisk",
        "Counter" : [
            {"counterName" : "Avg. Disk Bytes/Transfer"},
            {"counterName" : "Avg. Disk Bytes/Write"},
            {"counterName" : "Avg. Disk Queue Length"},
            {"counterName" : "Avg. Disk Read Queue Length"},
            {"counterName" : "Avg. Disk sec/Read"},
            {"counterName" : "Avg. Disk sec/Transfer"},
            {"counterName" : "Avg. Disk sec/Write"},
            {"counterName" : "Avg. Disk Write Queue Length"},
            {"counterName" : "Current Disk Queue Length"},
            {"counterName" : "Disk Bytes/sec"},
            {"counterName" : "Disk Read Bytes/sec"},
            {"counterName" : "Disk Reads/sec"},
            {"counterName" : "Disk Transfers/sec"},
            {"counterName" : "Disk Write Bytes/sec"},
            {"counterName" : "Disk Writes/sec"}
        ]
    },
    {
        "ObjectName" : "Process",
        "Counter" : [
            {"counterName" : "% Privileged Time", "instanceName" : "sqlservr"},
            {"counterName" : "% Processor Time", "instanceName" : "sqlservr"},
            {"counterName" : "% User Time", "instanceName" : "sqlservr"},
            {"counterName" : "Page Faults/sec", "instanceName" : "sqlservr"},
            {"counterName" : "Private Bytes", "instanceName" : "sqlservr"},
            {"counterName" : "Thread Count", "instanceName" : "sqlservr"},
            {"counterName" : "Virtual Bytes", "instanceName" : "sqlservr"},
            {"counterName" : "Working Set", "instanceName" : "sqlservr"},
            {"counterName" : "Working Set - Private", "instanceName" : "sqlservr"}
        ]
    },
    {
        "ObjectName" : "Processor",
        "Counter" : [
            {"counterName" : "% Privileged Time"},
            {"counterName" : "% Processor Time"},
            {"counterName" : "% User Time"},
            {"counterName" : "Interrupts/sec"}
        ]
    },
    {
        "ObjectName" : "ProcessorPerformance",
        "Counter" : [
            {"counterName" : "percentage"},
            {"counterName" : "frequency"},
            {"counterName" : "power"}
        ]
    },
    {
        "ObjectName" : "Processor Information",
        "Counter" : [
            {"counterName" : "% Processor Performance"},
            {"counterName" : "Processor Frequency"}
        ]
    },
    {
        "ObjectName" : "System",
        "Counter" : [
            {"counterName" : "Context Switches/sec"},
            {"counterName" : "Processor Queue Length"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Access Methods",
        "Counter" : [
            {"counterName" : "Full Scans/sec"},
            {"counterName" : "Index Searches/sec"},
            {"counterName" : "Page Splits/sec"},
            {"counterName" : "Range Scans/sec"},
            {"counterName" : "Workfiles Created/sec"},
            {"counterName" : "Worktables Created/sec"},
            {"counterName" : "Worktables From Cache Ratio"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Batch Resp Statistics",
        "Counter" : [
            {"counterName" : "Batches >=000000ms & <000001ms"},
            {"counterName" : "Batches >=000001ms & <000002ms"},
            {"counterName" : "Batches >=000002ms & <000005ms"},
            {"counterName" : "Batches >=000005ms & <000010ms"},
            {"counterName" : "Batches >=000010ms & <000020ms"},
            {"counterName" : "Batches >=000020ms & <000050ms"},
            {"counterName" : "Batches >=000050ms & <000100ms"},
            {"counterName" : "Batches >=000100ms & <000200ms"},
            {"counterName" : "Batches >=000200ms & <000500ms"},
            {"counterName" : "Batches >=000500ms & <001000ms"},
            {"counterName" : "Batches >=001000ms & <002000ms"},
            {"counterName" : "Batches >=002000ms & <005000ms"},
            {"counterName" : "Batches >=005000ms & <010000ms"},
            {"counterName" : "Batches >=010000ms & <020000ms"},
            {"counterName" : "Batches >=020000ms & <050000ms"},
            {"counterName" : "Batches >=050000ms & <100000ms"},
            {"counterName" : "Batches >=100000ms"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Buffer Manager",
        "Counter" : [
            {"counterName" : "Background writer pages/sec"},
            {"counterName" : "Buffer cache hit ratio"},
            {"counterName" : "Checkpoint pages/sec"},
            {"counterName" : "Database pages"},
            {"counterName" : "Lazy writes/sec"},
            {"counterName" : "Page life expectancy"},
            {"counterName" : "Page lookups/sec"},
            {"counterName" : "Page reads/sec"},
            {"counterName" : "Page writes/sec"},
            {"counterName" : "Readahead pages/sec"},
            {"counterName" : "Readahead time/sec"},
            {"counterName" : "Target pages"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Databases",
        "Counter" : [
            {"counterName" : "Active Transactions"},
            {"counterName" : "Data File(s) Size (KB)"},
            {"counterName" : "Log Bytes Flushed/sec"},
            {"counterName" : "Log Cache Hit Ratio"},
            {"counterName" : "Log Cache Reads/sec"},
            {"counterName" : "Log File(s) Size (KB)"},
            {"counterName" : "Log File(s) Used Size (KB)"},
            {"counterName" : "Log Flush Wait Time"},
            {"counterName" : "Log Flush Waits/sec"},
            {"counterName" : "Log Flush Write Time (ms)"},
            {"counterName" : "Log Flushes/sec"},
            {"counterName" : "Log Growths"},
            {"counterName" : "Percent Log Used"},
            {"counterName" : "Transactions/sec"},
            {"counterName" : "Write Transactions/sec"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Exec Statistics",
        "Counter" : [
            {"counterName" : "Distributed Query"},
            {"counterName" : "DTC calls"},
            {"counterName" : "Extended Procedures"},
            {"counterName" : "OLEDB calls"}
        ]
    },
    {
        "ObjectName" : "SQLServer:General Statistics",
        "Counter" : [
            {"counterName" : "Active Temp Tables"},
            {"counterName" : "Connection Reset/sec"},
            {"counterName" : "Logins/sec"},
            {"counterName" : "Logouts/sec"},
            {"counterName" : "Processes blocked"},
            {"counterName" : "Temp Tables Creation Rate"},
            {"counterName" : "Temp Tables For Destruction"},
            {"counterName" : "Tempdb recovery unit id"},
            {"counterName" : "Tempdb rowset id"},
            {"counterName" : "Transactions"},
            {"counterName" : "User Connections"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Latches",
        "Counter" : [
            {"counterName" : "Average Latch Wait Time (ms)"},
            {"counterName" : "Latch Waits/sec"},
            {"counterName" : "Number of SuperLatches"},
            {"counterName" : "SuperLatch Demotions/sec"},
            {"counterName" : "SuperLatch Promotions/sec"},
            {"counterName" : "Total Latch Wait Time (ms)"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Locks",
        "Counter" : [
            {"counterName" : "Average Wait Time (ms)"},
            {"counterName" : "Lock Requests/sec"},
            {"counterName" : "Lock Timeouts (timeout > 0)/sec"},
            {"counterName" : "Lock Timeouts/sec"},
            {"counterName" : "Lock Wait Time (ms)"},
            {"counterName" : "Lock Waits/sec"},
            {"counterName" : "Number of Deadlocks/sec"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Memory Manager",
        "Counter" : [
            {"counterName" : "Connection Memory (KB)"},
            {"counterName" : "Database Cache Memory (KB)"},
            {"counterName" : "External benefit of memory"},
            {"counterName" : "Free Memory (KB)"},
            {"counterName" : "Granted Workspace Memory (KB)"},
            {"counterName" : "Lock Blocks"},
            {"counterName" : "Lock Blocks Allocated"},
            {"counterName" : "Lock Memory (KB)"},
            {"counterName" : "Lock Owner Blocks"},
            {"counterName" : "Lock Owner Blocks Allocated"},
            {"counterName" : "Log Pool Memory (KB)"},
            {"counterName" : "Maximum Workspace Memory (KB)"},
            {"counterName" : "Memory Grants Outstanding"},
            {"counterName" : "Memory Grants Pending"},
            {"counterName" : "Optimizer Memory (KB)"},
            {"counterName" : "Reserved Server Memory (KB)"},
            {"counterName" : "SQL Cache Memory (KB)"},
            {"counterName" : "Stolen Server Memory (KB)"},
            {"counterName" : "Target Server Memory (KB)"},
            {"counterName" : "Total Server Memory (KB)"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Plan Cache",
        "Counter" : [
            {"counterName" : "Cache Hit Ratio"},
            {"counterName" : "Cache Object Counts"},
            {"counterName" : "Cache Objects in use"},
            {"counterName" : "Cache Pages"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Resource Pool Stats",
        "Counter" : [
            {"counterName" : "Active memory grant amount (KB)"},
            {"counterName" : "Active memory grants count"},
            {"counterName" : "Avg Disk Read IO (ms)"},
            {"counterName" : "Avg Disk Write IO (ms)"},
            {"counterName" : "Cache memory target (KB)"},
            {"counterName" : "Compile memory target (KB)"},
            {"counterName" : "CPU control effect %"},
            {"counterName" : "CPU delayed %"},
            {"counterName" : "CPU effective %"},
            {"counterName" : "CPU usage %"},
            {"counterName" : "CPU usage target %"},
            {"counterName" : "CPU violated %"},
            {"counterName" : "Disk Read Bytes/sec"},
            {"counterName" : "Disk Read IO Throttled/sec"},
            {"counterName" : "Disk Read IO/sec"},
            {"counterName" : "Disk Write Bytes/sec"},
            {"counterName" : "Disk Write IO Throttled/sec"},
            {"counterName" : "Disk Write IO/sec"},
            {"counterName" : "Max memory (KB)"},
            {"counterName" : "Memory grant timeouts/sec"},
            {"counterName" : "Memory grants/sec"},
            {"counterName" : "Pending memory grants count"},
            {"counterName" : "Query exec memory target (KB)"},
            {"counterName" : "Target memory (KB)"},
            {"counterName" : "Used memory (KB)"}
        ]
    },
    {
        "ObjectName" : "SQLServer:SQL Errors",
        "Counter" : [
            {"counterName" : "Errors/sec"}
        ]
    },
    {
        "ObjectName" : "SQLServer:SQL Statistics",
        "Counter" : [
            {"counterName" : "Auto-Param Attempts/sec"},
            {"counterName" : "Batch Requests/sec"},
            {"counterName" : "Failed Auto-Params/sec"},
            {"counterName" : "Forced Parameterizations/sec"},
            {"counterName" : "Guided plan executions/sec"},
            {"counterName" : "Misguided plan executions/sec"},
            {"counterName" : "Safe Auto-Params/sec"},
            {"counterName" : "SQL Attention rate"},
            {"counterName" : "SQL Compilations/sec"},
            {"counterName" : "SQL Re-Compilations/sec"},
            {"counterName" : "Unsafe Auto-Params/sec"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Transactions",
        "Counter" : [
            {"counterName" : "Free Space in tempdb (KB)"},
            {"counterName" : "Longest Transaction Running Time"},
            {"counterName" : "NonSnapshot Version Transactions"},
            {"counterName" : "Snapshot Transactions"},
            {"counterName" : "Transactions"},
            {"counterName" : "Version Cleanup rate (KB/s)"},
            {"counterName" : "Version Generation rate (KB/s)"},
            {"counterName" : "Version Store Size (KB)"},
            {"counterName" : "Version Store unit count"},
            {"counterName" : "Version Store unit creation"},
            {"counterName" : "Version Store unit truncation"},
            {"counterName" : "Update conflict ratio"},
            {"counterName" : "Update Snapshot Transactions"}
        ]
    },
    {
        "ObjectName" : "SQLServer:Wait Statistics",
        "Counter" : [
            {"counterName" : "Lock waits"},
            {"counterName" : "Log buffer waits"},
            {"counterName" : "Log write waits"},
            {"counterName" : "Memory grant queue waits"},
            {"counterName" : "Network IO waits"},
            {"counterName" : "Non-Page latch waits"},
            {"counterName" : "Page IO latch waits"},
            {"counterName" : "Page latch waits"},
            {"counterName" : "Thread-safe memory objects waits"},
            {"counterName" : "Transaction ownership waits"},
            {"counterName" : "Wait for the worker"},
            {"counterName" : "Workspace synchronization waits"}
        ]
    },
    {
        "ObjectName" : "Workload Group Stats",
        "Counter" : [
            {"counterName" : "Active parallel threads"},
            {"counterName" : "Active requests"},
            {"counterName" : "Blocked tasks"},
            {"counterName" : "CPU delayed %"},
            {"counterName" : "CPU effective %"},
            {"counterName" : "CPU usage %"},
            {"counterName" : "CPU violated %"},
            {"counterName" : "Max request cpu time (ms)"},
            {"counterName" : "Max request memory grant (KB)"},
            {"counterName" : "Query optimizations/sec"},
            {"counterName" : "Queued requests"},
            {"counterName" : "Reduced memory grants/sec"},
            {"counterName" : "Requests completed/sec"},
            {"counterName" : "Suboptimal plans/sec"}            
        ]
    }
]
"@ | ConvertFrom-Json

foreach ($info in $json){
    foreach($item in $info.Counter){
        $name = "DataSource_WindowsPerformanceCounter_" + [GUID]::NewGuid()

        $object = $info.ObjectName
        $counter = $item.counterName
        $instance = $item.instanceName

        if ($instance -eq $null)
        {
            $param = @{name=$name; ObjectName=$object; CounterName=$counter;}
        }else{
            $param = @{name=$name; ObjectName=$object; CounterName=$counter;InstanceName=$instance}
        }
        New-AzureRmOperationalInsightsWindowsPerformanceCounterDataSource -Workspace $workspace -IntervalSeconds 10 @param 
    }
}

Get-AzureRmOperationalInsightsDataSource -Workspace $workspace -Kind WindowsPerformanceCounter | select -ExpandProperty Properties | Group-Object ObjectName | Sort-Object Name | out-gridview


# Wiki Content Update

This PR provides content for updating the SQLServer-Util repository's Wiki. The content is based on the auto-generated index of the repository and has been structured into appropriate Wiki pages.

## Wiki Pages to Create/Update

### Home Page
Replace the existing Home page content with:

```markdown
# SQLServer-Util

## Overview

SQLServer-Util is a comprehensive toolkit for SQL Server monitoring, management, and troubleshooting. It serves SQL Server database administrators, developers, and DevOps engineers by providing scripts and utilities to identify performance bottlenecks, troubleshoot issues, and automate common administrative tasks. 

The repository contains PowerShell scripts for real-time monitoring, SQL queries for retrieving system information from Dynamic Management Views (DMVs), reference documentation for performance counters, and tools for managing SQL Server Managed Instances in Azure. It enables users to effectively monitor blocking chains, analyze active sessions, track memory utilization, measure index performance, and deploy databases through CI/CD pipelines.

The toolkit is designed to be modular, allowing administrators to use individual components as needed based on their specific requirements. Whether you're investigating a performance issue, setting up monitoring, or automating deployment, SQLServer-Util provides the necessary tools and references.

## Wiki Pages

* [Project Organization](Project-Organization) - Details about the repository structure and main components
* [Glossary](Glossary) - Glossary of codebase-specific terms
* [Tools](Tools) - External tools and resources
```

### Project Organization Page
Create a new page titled "Project Organization" with the following content:

```markdown
# Project Organization

The repository is organized by functional areas, with each directory focusing on a specific aspect of SQL Server management and monitoring:

## Core Systems and Services

1. **Blocking Chain Monitoring**
   - `Lock/BlockingChain.ps1`: A PowerShell script that identifies and reports on blocking chains within SQL Server instances
   - Uses recursive queries against system views to build a visual representation of blocking relationships
   - Outputs JSON-formatted data with blocking session details including SQL text and resource information

2. **SQL Database Managed Instance Tools**
   - `SQL Database Managed Instance/Set-MIPortForward.ps1`: Configures port forwarding to Azure SQL Managed Instances
   - Uses Windows `netsh` commands to create port forwarding rules
   - Queries system views in the MI to determine the correct endpoint information

3. **DMV Query Collection**
   - Various `.sql` files organized in directories such as `Query/`, `Lock/`, `Wait/`, `Index/`
   - Retrieves information from system views and DMVs for different aspects of SQL Server operation
   - Main entry point is through execution of individual SQL scripts

4. **Real-time Session Monitoring**
   - `Tools/EZMonitor/SessionMonitor.ps1`: Monitors active SQL Server sessions in real-time
   - Displays information about queries, resource usage, and wait statistics
   - Uses PowerShell's Out-GridView for an interactive display of session data

5. **Performance Counter Reference**
   - `Performance Monitor/README.md`: Comprehensive documentation of performance counters
   - Organized into OS, SQL Server, and AlwaysOn categories
   - Includes recommended thresholds and interpretation guidance

6. **DBCC and Trace Flag Reference**
   - `DBCC/Trace Flag.sql`: Documents trace flags for modifying SQL Server behavior
   - `DBCC/DBCC Command.sql`: Reference for DBCC commands used for administration and troubleshooting
   - Includes usage examples and compatibility information

7. **Database CI/CD Pipeline**
   - `CI_CD/Azure DevOps/Build_DBProject.yml`: Azure DevOps pipeline for database projects
   - Builds and deploys database projects using DACPACs
   - Integrates with Datadog monitoring via containerized agents

## Main Files and Directories

- `Lock/`: Contains scripts related to locks and blocking, including the high-priority `BlockingChain.ps1`
- `SQL Database Managed Instance/`: Tools for working with Azure SQL Managed Instances
- `Performance Monitor/`: Documentation of performance counters for monitoring
- `DBCC/`: References for DBCC commands and trace flags
- `Query/`: Scripts for retrieving information about running queries
- `Wait/`: Scripts for analyzing wait statistics
- `Index/`: Scripts for monitoring index usage and maintenance
- `Memory/`: Scripts for analyzing memory usage
- `Tools/EZMonitor/`: Real-time monitoring tools
- `CI_CD/`: CI/CD pipeline configurations
- `Datadog/`: Datadog monitoring integration
- `Database Project/`: Example database project with schema definitions
- `PowerShell/`: PowerShell scripts for various SQL Server operations
- `README.md`: Main documentation file providing an overview of the repository

## Main Functions and Classes

1. **BlockingChain.ps1**
   - Uses recursive CTEs to identify blocking chains
   - Main functionality: Detects and reports on sessions blocking other sessions
   - Outputs JSON with blocking hierarchy information

2. **Set-MIPortForward.ps1**
   - Main function: Configures port forwarding to Azure SQL Managed Instances
   - Uses `netsh interface portproxy` commands
   - Queries SQL MI system views to get endpoint information

3. **SessionMonitor.ps1**
   - Main function: Continuously monitors active SQL sessions
   - Uses DMVs to collect session information
   - Displays results in a PowerShell Grid View

4. **Install-SQLServer.ps1**
   - PowerShell DSC configuration for SQL Server installation
   - Uses the `xSQLServer` DSC module
   - Defines Configuration blocks for LCM and SQLServer

5. **SQL Query Scripts**
   - Various SQL scripts that query DMVs for system information
   - Most scripts follow a pattern of joining several system views to provide comprehensive information
   - Scripts are organized by functional area (locks, waits, queries, etc.)
```

### Glossary Page
Create a new page titled "Glossary" with the following content:

```markdown
# Glossary of codebase-specific terms

1. **BlockingChain**: Script that identifies SQL blocking relationships in a tree structure. [`Lock/BlockingChain.ps1`]

2. **blocked_path**: String showing the path of blocked processes (e.g., "1 <- 2 <- 3"). [`Lock/BlockingChain.ps1`]

3. **Set-MIPortForward**: PowerShell script for configuring port forwarding to SQL Managed Instances. [`SQL Database Managed Instance/Set-MIPortForward.ps1`]

4. **netsh portproxy**: Windows networking command used to create port forwarding rules. [`SQL Database Managed Instance/Set-MIPortForward.ps1`]

5. **SQLServerUtil**: The repository's collection of utilities for retrieving info from system views. [`README.md`]

6. **DMVs (Dynamic Management Views)**: SQL Server views that provide internal server state information. [Various .sql files]

7. **SessionMonitor**: PowerShell script that displays real-time information about active sessions. [`Tools/EZMonitor/SessionMonitor.ps1`]

8. **EZMonitor**: Collection of tools for simplified monitoring of SQL Server activities. [`Tools/EZMonitor/`]

9. **Trace Flag**: Configuration that modifies SQL Server behavior, set via DBCC TRACEON. [`DBCC/Trace Flag.sql`]

10. **DBCC Command**: Database Console Command for maintenance and diagnostic tasks. [`DBCC/DBCC Command.sql`]

11. **SQL Memory Model**: Memory management architecture used by SQL Server. [`Memory/System Memory.sql`]

12. **Page Life Expectancy (PLE)**: Time in seconds a page stays in buffer pool; lower values indicate memory pressure. [`Performance Monitor/README.md`]

13. **DACPAC**: Data-tier Application Package for deploying database schema. [`CI_CD/Azure DevOps/Build_DBProject.yml`]

14. **ProjectDB**: Sample database project with schema definitions and deployment settings. [`Database Project/ProjectDB/`]

15. **xSQLServer**: PowerShell DSC module containing resources for SQL Server management. [`PowerShell/DSC/Install-SQLServer.ps1`]

16. **Datadog Agent**: Monitoring agent deployed as Azure Container Instance to collect SQL metrics. [`Datadog/Azure Container Instance/`]

17. **Blocking Session ID**: SPID of a session that is blocking another session. [Various .sql files]

18. **sys.dm_exec_requests**: DMV that returns information about each request executing in SQL Server. [Various .sql files]

19. **sys.dm_os_waiting_tasks**: DMV that returns information about waiting tasks. [Various .sql files]

20. **sys.dm_exec_sql_text**: DMV that returns SQL text associated with a SQL handle. [Various .sql files]

21. **Buffer cache hit ratio**: Percentage of pages found in memory; important performance counter. [`Performance Monitor/README.md`]

22. **Wait Statistics**: Data about what SQL Server sessions are waiting for; key for performance troubleshooting. [`Wait/`]

23. **DBCC MEMORYSTATUS**: Command replaced by DMVs for memory information. [`Memory/DBCC MEMORYSTATUS 相当の DMV.sql`]

24. **Index Usage Statistics**: Data about how indexes are being used in the database. [`Index/`]

25. **AlwaysOn Counters**: Performance counters specific to Availability Groups. [`Performance Monitor/README.md`]
```

## How to Update the Wiki

1. Go to the [SQLServer-Util Wiki](https://github.com/MasayukiOzawa/SQLServer-Util/wiki)
2. Update the Home page and create the Project Organization and Glossary pages with the content provided above
3. Ensure the existing Tools page is preserved

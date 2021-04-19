SELECT COUNT(*) FROM frontdoor.accesslog WHERE time >= CAST('2020-03-01' AS datetime2(3)) AND time < CAST('2020-05-01' AS datetime2(3))
OPTION (MAXDOP 1,RECOMPILE
    , QUERYTRACEON 3604 -- Output Message

    , QUERYTRACEON 8605 -- Initial Tree
    , QUERYTRACEON 8606 -- Optimize Tree
    , QUERYTRACEON 8612 -- Tree Aditional Info
    , QUERYTRACEON 8675 -- Output Task / Time / Cost
    
    , QUERYTRACEON 8619 -- Transform Rule 
    , QUERYTRACEON 8620 -- Transform Rule Additional Info
    
    , QUERYTRACEON 8608 -- Initial Memo Structure
    , QUERYTRACEON 8615 -- Final Memo Structure

    , QUERYTRACEON 8757 -- Skip Trivial Plan
    , QUERYTRACEON 8780 -- Disable Optimize Timeout

    , QUERYTRACEON 2363 -- Statistics Object Debug
    , QUERYTRACEON 2373

    -- , QUERYRULEOFF JNtoNL
    -- , QUERYRULEOFF SelIdxToRng
    -- , QUERYRULEOFF JNtoIdxLookup
)



  PROGRAM
  MAP
    INCLUDE('MakeSGuid.inc'),ONCE
  END
  PRAGMA('define(asserts=>on)')  
  PRAGMA('link(C%V%MEM%X%%L%.LIB)')

MemFile             FILE,DRIVER('MEMORY'),CREATE,PRE(MEM),THREAD
GuidKey               KEY(+MEM:Guid)
RECORD                RECORD
Guid                    STRING(16)
Data                    STRING(100)
                      END
                    END

  MAP 
TestSpeed   PROCEDURE
TestConcurrency PROCEDURE
ThreadWorker    PROCEDURE(STRING pThreadId)
Debug   PROCEDURE(STRING pText)
    MODULE('')
OutputDebugStringA    PROCEDURE(*CSTRING cstr),PASCAL,RAW
    END
  END

threads             EQUATE(100)
threadRecords       EQUATE(10000)
timerRecords        EQUATE(100)
threadFinished      BOOL,DIM(threads)

  CODE  
  TestSpeed
  TestConcurrency  
  
TestSpeed           PROCEDURE
clk                   LONG
id                    STRING(16)
n                     EQUATE(100000)
  CODE 

  ASSERT(MakeSGuid(8,1,1) = '000556O1')
  ASSERT(MakeSGuid(8,DATE(10,20,2024),1+15*60*60*100+24*60*100+56*100+78) = '90GRF3HR')
  
  clk = CLOCK()
  LOOP n TIMES
    id = MakeSGuid()
  .
  clk = CLOCK() - clk
  Debug('Created '&n&' ids in '&clk/100&' seconds. ('&ROUND(n/clk*100,1)&'/s)||Last: '&id)
  MESSAGE('Created '&n&' ids in '&clk/100&' seconds. ('&ROUND(n/clk*100,1)&'/s)||Last: '&id)
  
TestConcurrency     PROCEDURE
Window                WINDOW,AT(,,75,17),FONT('Segoe UI',9),TIMER(5)
                        STRING('Waiting for threads..'),AT(3,4),USE(?STRING1)
                      END
currentThread         LONG
threadsFinished       BOOL
idx                   LONG
clk                   LONG
  CODE
  SHARE(MemFile)
  IF ERRORCODE() = 2
    CREATE(MemFile)
    SHARE(MemFile)
  END
  OPEN(Window)
  clk = CLOCK()  
  ACCEPT        
    CASE EVENT()
      OF EVENT:Timer
        IF currentThread < threads
          DO StartNextThread
        ELSE
          DO CheckThreadsFinished
        END
        IF threadsFinished THEN POST(EVENT:CloseWindow).
    END     
  END
  CLOSE(Window)
  clk = CLOCK() - clk
  Debug('Created '&RECORDS(MemFile)&' ids of '&threads*threadRecords&' in '&clk/100&' seconds. ('&ROUND(RECORDS(MemFile)/clk*100,1)&')/s')
  ASSERT(RECORDS(MemFile) = threads*threadRecords)  
  MESSAGE('Created '&RECORDS(MemFile)&' ids in '&clk/100&' seconds. ('&ROUND(RECORDS(MemFile)/clk*100,1)&')/s')
 
StartNextThread     ROUTINE
  
  currentThread += 1
  RESUME(START(ThreadWorker,,currentThread))

CheckThreadsFinished    ROUTINE
  LOOP idx = 1 TO threads
    IF NOT threadFinished[idx] THEN EXIT.
  .
  threadsFinished = TRUE
      
ThreadWorker        PROCEDURE(STRING pThreadId)
Window                WINDOW,AT(,,75,17),FONT('Segoe UI',9),TIMER(5)
                        STRING('Trhead Id:'),AT(3,4),USE(?STRING1)
                      END
cnt                   LONG
  CODE
  SHARE(MemFile) 
  Debug('Started thread '&pThreadId)
  OPEN(Window)
  ?STRING1{PROP:Text} = 'Thread Id:'&pThreadId
  ACCEPT
    CASE EVENT()
      OF EVENT:Timer
        DO Work 
        IF cnt >= threadRecords THEN POST(EVENT:CloseWindow).
    END
  END   
  threadFinished[pThreadId] = TRUE
  Debug('Finished thread '&pThreadId)
  CLOSE(MemFile)
  
  
Work                ROUTINE
  
  LOOP timerRecords TIMES
    IF cnt > threadRecords THEN BREAK.
    CLEAR(MEM:RECORD)
    MEM:Guid = MakeSGuid()
    MEM:Data = 'Thread No.:'&pThreadId&' Thread: '&THREAD()
    ADD(MemFile)
    cnt += 1    
  .
  
Debug               PROCEDURE(STRING pText)
cstr                  CSTRING(SIZE(pText)+1)
  CODE
  cstr = CLIP(pText)
  OutputDebugStringA(cstr)  


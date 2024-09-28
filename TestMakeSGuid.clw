  PROGRAM
  MAP
    INCLUDE('MakeSGuid.inc'),ONCE
  END
clk                 LONG
id                  STRING(16)
n                   EQUATE(100000)
  CODE

  PRAGMA('define(asserts=>on)')  
  ASSERT(MakeSGuid(8,1,1) = '000556O1')
  ASSERT(MakeSGuid(8,DATE(10,20,2024),1+15*60*60*100+24*60*100+56*100+78) = '90GRF3HR')
  
  clk = CLOCK()
  LOOP n TIMES
    id = MakeSGuid()
  .
  clk = CLOCK() - clk
  MESSAGE('Created '&n&' ids in '&clk/100&' seconds. ('&ROUND(n/clk*100,1)&'/s)||Last: '&id)

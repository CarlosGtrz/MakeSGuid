  MEMBER

  INCLUDE('svapi.inc'),ONCE
  MAP  
    INCLUDE('i64.inc'),ONCE
    MODULE('')
      i64Mod(*INT64 op1, *INT64 op2, *INT64 dest),UNSIGNED,PROC,RAW,NAME('Cla$i64Mod')
      GetLocalTime(*_SYSTEMTIME),RAW,PASCAL
    END
MakeSGuid   PROCEDURE(LONG pLength = 16,LONG pDate = 0,LONG pTime = 0),STRING
  END

MakeSGuid           PROCEDURE(LONG pLength = 16,LONG pDate = 0,LONG pTime = 0)!,STRING
sysdt                 LIKE(_SYSTEMTIME),AUTO           !To get the system local date and time
dt64                  LIKE(INT64),AUTO                 !To store date/time in hundredths of seconds since December 28 1800
tmp64                 LIKE(INT64),AUTO                 !Temporary variable to use with i64 operations
mod64                 LIKE(INT64),AUTO                 !To store dt % 36
guid                  STRING(32),AUTO                  !The returned id
idx                   LONG,AUTO                        !Index for string slicing
base36                STRING('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ') !Lookup table for base 36 encoding
digitsfordt           EQUATE(8)                        !Base 36 digits for the date/time part. Enough for dates until year 2694
  CODE
  IF pLength < digitsfordt THEN pLength = digitsfordt. !Check por valid length
  IF pLength > SIZE(guid) THEN pLength = SIZE(guid).
  IF NOT pDate
    GetLocalTime(sysdt)                                !Better accuracy than CLOCK() at the hundredths level
    pDate = DATE(sysdt.wMonth,sysdt.wDay,sysdt.wYear)  !Convert to clarion standard date and time
    pTime = sysdt.wHour * 360000 + sysdt.wMinute * 6000 + sysdt.wSecond * 100 + sysdt.wMilliseconds / 10 + 1 !60*60*100, 60*100
  .
  i64Assign(dt64,pDate)                                !dt64 = pDate
  i64Assign(tmp64,8640000) ; i64Mult(dt64,tmp64,dt64)  !dt64 *= 8640000  (24*60*60*100)
  i64Assign(tmp64,pTime)   ; i64Add(dt64,tmp64,dt64)   !dt64 += pTime
  i64Assign(tmp64,36)                                  !To use inside the loop
  LOOP idx = digitsfordt TO 1 BY -1                    !Convert to base 36, starting with last digit
    i64Mod(dt64,tmp64,mod64)                           !mod64 = dt64 % 36
    guid[idx] = base36[ mod64.lo + 1 ]                 !Get the encoded the digit. mod64.lo is a ULONG with the lower part of the int64
    i64Div(dt64,tmp64,dt64)                            !dt64 /= 36
  END
  LOOP idx = digitsfordt + 1 TO pLength                !Fill the rest of the string with random digits
    guid[idx] = base36[ RANDOM(1,36) ]
  END
  RETURN guid[1 : pLength]                             !Return clipped id
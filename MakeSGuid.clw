  MEMBER
  PRAGMA('link(bcryptrandom.lib)')
BCRYPT_USE_SYSTEM_PREFERRED_RNG EQUATE (2)
  INCLUDE('svapi.inc'),ONCE
  MAP  
    INCLUDE('i64.inc'),ONCE
    MODULE('')
      i64Mod(*INT64 op1, *INT64 op2, *INT64 dest),UNSIGNED,PROC,RAW,NAME('Cla$i64Mod'),DLL(1)
      GetLocalTime(*_SYSTEMTIME),RAW,PASCAL,DLL(1)
      BCryptGenRandom(HANDLE hAlgorithm,*STRING pbBuffer,UNSIGNED cbBuffer,UNSIGNED dwFlags),UNSIGNED,PROC,RAW,PASCAL,DLL(1)
    END    
MakeSGuid   PROCEDURE(LONG pLength = 16,LONG pDate = 0,LONG pTime = 0),STRING
  END

MakeSGuid           PROCEDURE(LONG pLength = 16,LONG pDate = 0,LONG pTime = 0)!,STRING
systemTime            LIKE(_SYSTEMTIME),AUTO           !System date/time
hundredthsPerDay      GROUP;LONG(8640000);LONG;END     !24*60*60*100 (one day in hundredths of a second)
dayInt64              LIKE(INT64),OVER(hundredthsPerDay) !As int64
base36Constant        GROUP;LONG(36);LONG;END          !Base 36
base36Int64           LIKE(INT64),OVER(base36Constant) !As int64
timestampInt64        LIKE(INT64),AUTO                 !Date/time in hundredths of a second since Dec 28, 1800
timeInt64             LIKE(INT64),AUTO                 !Time value
modResult             LIKE(INT64),AUTO                 !Modulo result
result                STRING(32),AUTO                  !Generated ID
position              LONG,AUTO                        !String position
base36Digits          STRING('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ') !Base 36 encoding table
timestampDigits       EQUATE(8)                        !Base 36 digits for date/time (valid until 2694)
randomBytes           STRING(24),AUTO                  !Crypto random bytes
randomByteArray       BYTE,DIM(SIZE(randomBytes)),OVER(randomBytes) !As byte array
  CODE
  IF pLength < timestampDigits THEN pLength = timestampDigits. !Minimum length check
  IF pLength > SIZE(result) THEN pLength = SIZE(result).!Maximum length check
  IF NOT pDate
    GetLocalTime(systemTime)                            !Get system time
    pDate = DATE(systemTime.wMonth,systemTime.wDay,systemTime.wYear)  !Convert to Clarion date
    pTime = systemTime.wHour * 360000 + systemTime.wMinute * 6000 + systemTime.wSecond * 100 + systemTime.wMilliseconds * .10 + 1 !Convert to hundredths of a second
  END
  i64Assign(timestampInt64,pDate)                       !timestampInt64 = pDate
  i64Mult(timestampInt64,dayInt64,timestampInt64)       !timestampInt64 *= day
  i64Assign(timeInt64,pTime) ; i64Add(timestampInt64,timeInt64,timestampInt64) !timestampInt64 += pTime
  LOOP position = timestampDigits TO 1 BY -1            !Convert to base 36 (reverse order)
    i64Mod(timestampInt64,base36Int64,modResult)        !modResult = timestampInt64 % 36
    result[position] = base36Digits[ modResult.lo + 1 ] !Get encoded digit
    i64Div(timestampInt64,base36Int64,timestampInt64)   !timestampInt64 /= 36
  END
  IF pLength > timestampDigits
    BCryptGenRandom(0,randomBytes,pLength - timestampDigits,BCRYPT_USE_SYSTEM_PREFERRED_RNG) !Get random bytes
    LOOP position = timestampDigits + 1 TO pLength      !Add random digits
      result[position] = base36Digits[ ( randomByteArray[ position - timestampDigits ] % 36 ) + 1 ] !Convert to base 36 (slight bias acceptable)
    END
  END
  RETURN result[1 : pLength]                            !Return clipped ID
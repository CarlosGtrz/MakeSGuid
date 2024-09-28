  MODULE('MakeSGuid.clw')
!!! <summary>
!!! Creates a lexicographically sortable unique id with uppercase letters and digits. Example: 90DKZP0B6WYLIFYZ
!!! </summary>
!!! <param name="pLength">The length of the id. Must be between 8 and 32, default is 16</param>
!!! <param name="pDate">Optional, used only when creating an id for old data</param>
!!! <param name="pTime">Optional, used only when creating an id for old data</param>
MakeSGuid   PROCEDURE(LONG pLength = 16,LONG pDate = 0,LONG pTime = 0),STRING,EXPORT
  END
  PRAGMA('compile(MakeSGuid.clw)')

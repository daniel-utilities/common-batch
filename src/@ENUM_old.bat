@echo off
setlocal DisableDelayedExpansion
set ^"LF=^
%= EMPTY LINE =%
^" 
set    ^"#LF=^^^%LF%%LF%^%LF%%LF%^"
set   ^"#EOL=^^^%LF%%LF%^"          %= User provides the missing LF when expanding this at the end of a macro line =%
set   ^"##LF=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set  ^"##EOL=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"
set  ^"###LF=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set ^"###EOL=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"

::----------------------------------------------------------------------------::
:: @ENUM                                                                      ::
::  Macros for emulating a C-like Enumeration data type.                      ::
::----------------------------------------------------------------------------::
:: Macro Overview:
::
::   %@ENUM.NEW% enumName ITEMNAME[=int] [ITEMNAME[=int]] ...
::      Instanciate a new enum, optionally initializing its items.
::      Each item is stored as: !enumName.ITEMNAME!=!int!
::
::   %@ENUM.FOREACH:NAME=enumName% ( ... )
::      Repeats the code block ( ... ) for each item in enumName.
::      Within () use:   %%v       The current item variable.
::                       !%%v!     The current item value.
::
::   (%@ENUM.CONTAINS% enumName int [ITEMVAR]) %% ( found ) || ( notfound )
::      Searches enumName for value int and sets ERRORLEVEL=0 if found.
::      Also sets ITEMVAR to the name of the first variable containing int.
::
::   %@ENUM.DELETE% enumName
::      Undefine an enum and all its associated variables.
::
:: Syntax and Usage Notes:
::  - All macros require EnableDelayedExpansion.
::  - %enumName% contains a space-separated list of all variables
::     associated with the enum.
::
::
:: Creating an enum:
::  Command:                        Result:
::    %@ENUM.NEW% enum                Enum with 0 item named "enum"
::    %@ENUM.NEW% enum item1          Enum with 1 item:  %enum.item1%=0
::    %@ENUM.NEW% enum item1=4        Enum with 1 item:  %enum.item1%=4
::    %@ENUM.NEW% enum item1=4 item2  Enum with 2 items: %enum.item1%=4, %enum.item2%=5
::
::  Enum items are automatically assigned consecutive, increasing integer values,
::   starting at 0, unless otherwise specified.
::
::  Example:
::    %@ENUM.NEW% enum ITEM1=6 ^        <-- enum.ITEM1=6
::                     ITEM2 ^          <-- enum.ITEM2=7
::                     ITEM3=0 ^        <-- enum.ITEM3=0
::                     ITEM4            <-- enum.ITEM4=1
::
::
:: Retrieving enum values:
::  Command:                        Result:
::    %enumName.itemName%              Integer value assigned to this item
::
::
:: Iterate over all items:
::    %@ENUM.FOREACH:NAME=enum% ( echo enum[%%i]=!enum[%%i]! )
::
::
:: Search for a specific value:
::    (%@ENUM.CONTAINS% enum 3) %% ( echo Found ) || ( echo Not Found )
::    (%@ENUM.CONTAINS% enum 3 ITEMV) && ( echo Found !ITEMV!=3 )
::
::
:: List of all variables associated with the enum:
::    %enum%
::
::  Example:
::    call :return %enum%       Returns an enum from a function or script.
::
::
:: Undefine an enum:
::    %@ENUM.DELETE% enum
::----------------------------------------------------------------------------::

:: @ENUM.NEW
set ^"@ENUM.NEW=for %%# in (1 2) do if %%#==2 ( %#EOL%
for /f "tokens=1* delims= " %%A in ("!@enum.args!") do ( %#EOL%
%========================================================================% %#EOL%
%= SECTION  Process Macro Args                                          =% %#EOL%
%=   token A  enum name                                                 =% %#EOL%
%=   token B  space-separated list of name=value pairs                  =% %#EOL%
%=                                                                      =% %#EOL%
if not "%%~A"=="" ( %#EOL%
  %= Undefine enum if it already exists =% %#EOL%
  for %%V in (!%%~A!) do set "%%V=" %#EOL%
  %= Define new enum =% %#EOL%
  set "%%~A=%%~A" %= Append to var association list =% %#EOL%
  %= Set each item in B an integer value =% %#EOL%
  set "@enum.args=%%~B" %#EOL%
  if defined @enum.args ( %#EOL%
    set /A "@enum.argn=0" %#EOL%
    for %%L in ("!LF!") do for /f "tokens=1* delims==" %%C in ("!@enum.args: =%%~L!") do ( %#EOL%
      if not "%%~D"=="" set /A "@enum.argn=%%~D" %= Value was explicitly specified =% %#EOL%
      set "%%~A=!%%~A! %%~A.%%~C" %= Append to var association list =% %#EOL%
      set /A "%%~A.%%~C=!@enum.argn!" %= Set value =% %#EOL%
      set /A "@enum.argn+=1" %#EOL%
    ) %#EOL%
  ) %#EOL%
) %#EOL%
%========================================================================% %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION  Cleanup Locals                                              =% %#EOL%
set "@enum.args=" %#EOL%
set "@enum.argn=" %#EOL%
%========================================================================% %#EOL%
) else set @enum.args="


:: @ENUM.DELETE
set ^"@ENUM.DELETE=for %%# in (1 2) do if %%#==2 ( %#EOL%
for %%A in (!@enum.args!) do for %%V in (!%%~A!) do set "%%V=" %#EOL%
set "@enum.args=" %#EOL%
) else set @enum.args="


:: @ENUM.FOREACH
set ^"@ENUM.FOREACH=for /F "tokens=1*" %%A in ("!NAME!") do for %%v in (%%B) do "


:: @ENUM.CONTAINS
set ^"@ENUM.CONTAINS=for %%# in (1 2) do if %%#==2 ( %#EOL%
for /f "tokens=1,2,3 delims= " %%A in ("!@enum.args!") do ( %#EOL%
%========================================================================% %#EOL%
%= SECTION  Process Macro Args                                          =% %#EOL%
%=   token A  enum name                                                 =% %#EOL%
%=   token B  value to search for                                       =% %#EOL%
%=   token C  optional var to hold name of item                         =% %#EOL%
%=                                                                      =% %#EOL%
%= Iterate over enum items, find first item val = (B) =% %#EOL%
set "@enum.item=" %#EOL%
for %%v in (!%%~A!) do ( %#EOL%
    if "!%%v!"=="%%~B" if not defined @enum.item set "@enum.item=%%v" %#EOL%
) %#EOL%
if not "%%~C"=="" set "%%~C=!@enum.item!" %#EOL%
%========================================================================% %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION  Cleanup Locals                                              =% %#EOL%
set "@enum.args=" %#EOL%
if defined @enum.item ( set "@enum.item=" ^& (call )) else (call) %#EOL%
%========================================================================% %#EOL%
) else set @enum.args="


setlocal EnableDelayedExpansion

echo.
echo @ENUM.NEW
%@ENUM.NEW% enum ITEM1=4 ^
                 ITEM2=0 ^
                 ITEM3="-2" ^
                 ITEM4= ^
                 ITEM5
set enum
echo.


echo.
echo @ENUM.FOREACH
%@ENUM.FOREACH:NAME=enum% ( echo %%v=!%%v! )
echo.


echo.
echo @ENUM.CONTAINS
set "itemv="
set "val=0"
(%@ENUM.CONTAINS% enum %val% itemv) && ( echo Found %val% at !itemv! ) || ( echo Value %val% not found )
echo.


echo.
echo @ENUM.DELETE
%@ENUM.DELETE% enum
set enum
echo.



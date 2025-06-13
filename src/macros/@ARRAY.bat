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
:: @ARRAY                                                                     ::
::   Macros for creating, indexing, and modifying array-like data structures. ::
::----------------------------------------------------------------------------::
:: Macro Overview:
::
:: %@ARRAY.NEW% arrayName [sizeN] ["initval1"|VAR1] ["initval2"|VAR2] ...
::    Instanciate a new array, optionally initializing its values.
::    Each element is stored as: arrayName[idx]=val
::    The final size is max(sizeN, num_initvals).
::
:: %@ARRAY.GET% arrayName idx [VAR]
::    Store the value at idx into variable VAR.
::    Supports negative indices. -1 is index of last element.
::
:: %@ARRAY.SET% arrayName idx VAR|"value"
::    Store the value into the element at idx.
::    Supports negative indices. -1 is index of last element.
::
:: %@ARRAY.FOREACH:NAME=arrayName% ( ... )
::    Repeats the code block ( ... ) for each element of arrayName.
::    Within ():   %%i                The current element index.
::                 !arrayName[%%i]!   The current element value.
::
:: (%@ARRAY.CONTAINS% arrayName VAR|"value" [IDXVAR]) && ( found ) || ( notfound )
::      Searches arrayName for value and sets ERRORLEVEL=0 if found.
::      Also sets IDXVAR to the index of the first element containing value.
::
:: %@ARRAY.APPEND% arrayName "appendval1"|VAR1 ["appendval2"|VAR2] ...
::    Append new values to the end of the array (increasing its size).
::
:: %@ARRAY.INSERT% arrayName idx "insertval1"|VAR1 ["insertval2"|VAR2] ...
::    Insert new values at the specified index.
::    All elements >= idx are shifted to higher idx to accomodate the new elements.
::    idx=0 is equivalent to idx=size+1. (Same result as @ARRAY.APPEND)
::    Supports negative indices. -1 is index of last element.
::
:: %@ARRAY.REMOVE% arrayName idx [idx2] [idx3] ...
::    Remove the specified indices and their values.
::    Supports negative indices. -1 is index of last element.
::
:: %@ARRAY.DELETE% arrayName
::    Undefine an array and all its associated variables.
::
::
:: Syntax and Usage Notes:
::  - All macros require EnableDelayedExpansion.
::  - Size of array is stored in %arr[#]% .
::  - Arrays are 1-indexed.
::      The first value is %arr[1]% and the last value is %arr[!arr[#]!]%
::  - Indices in macro args can be specified as positive, negative, or 0:
::      idx=-1 references arr[#] (last element)
::      idx=-2 references arr[#]-1
::      idx=0 references arr[#]+1 (first out-of-bounds index)
::  - "Quoted" macro args are treated as literal strings.
::      The corresponding array element (%arr[i]%) is set to the
::      string within the outer quotes.
::  - UNQUOTED macro args are treated as reference variables.
::      The corresponding array element (%arr[i]%) is set to the value of
::      the variable named by arg.
::  - %arr% contains a space-separated list of all variables associated with the array.
::
::
::
:: Creating an array:
::  Command:                        Result:
::    %@ARRAY.NEW% arr                0-element array
::    %@ARRAY.NEW% arr N              N-element array, each element is empty (undefined)
::    %@ARRAY.NEW% arr N VARNAME      N-element array, with arr[1]=!VARNAME!
::    %@ARRAY.NEW% arr N "string"     N-element array, with arr[1]=string
::
::  Example:
::    %@ARRAY.NEW% arr 2 VAR "string"
::  Variable:       Value:
::    arr             arr arr[#] arr[1] arr[2]
::    arr[#]          2
::    arr[1]          (value of VAR)
::    arr[2]          string
::
::
:: Retrieving array elements:
::  Command:                        Result:
::    %arr[#]%                        Size of array, idx of last element
::    !arr[1]!                        Value of first element
::    !arr[%arr[#]%]!                 Value of last element
::    !arr[idx]!                      Value of element at idx
::    %@ARRAY.GET% arr idx VAR        Sets VAR= Value at idx (idx may be negative)
::
::
:: Assigning array elements:
::  Command:                        Result:
::    set "arr[idx]=..."              Set value of element at idx
::    %@ARRAY.SET% arr idx VAR        Set value at idx to value of VAR (idx may be negative)
::
::
:: Iterate over all elements:
::    for /L %%i in (1,1,%arr[#]%) do ( echo arr[%%i]=!arr[%%i]! )
::  OR:
::    %@ARRAY.FOREACH:NAME=arr% ( echo arr[%%i]=!arr[%%i]! )
::
::
:: Append value(s) to end of array:
::  Command:                        Result:
::    %@ARRAY.APPEND% arr ""          Appends an empty value to the array
::    %@ARRAY.APPEND% arr VAR         Appends the value of VAR
::    %@ARRAY.APPEND% arr "string"    Appends the value "string" (without "")
::
::
:: Insert value(s) at the specified index:
::  Command:                            Result:
::    %@ARRAY.INSERT% arr idx ""          Inserts empty value at idx
::    %@ARRAY.INSERT% arr idx VAR         Inserts value of VAR at idx
::    %@ARRAY.INSERT% arr idx "string"    Inserts "string" at idx (without "")
::    %@ARRAY.INSERT% arr 1 "string"      Inserts "string" at the start of arr
::    %@ARRAY.INSERT% arr 0 "string"      Inserts "string" at the end of arr
::
::  Existing values are unchanged. Each element after idx is shifted to a
::    higher idx to accomodate the new element.
::
::
:: Remove element(s) from array:
::  Command:                        Result:
::   %@ARRAY.REMOVE% arr idx          Removes the value at idx, then decrements
::                                    the index of all elements after idx.
::   %@ARRAY.REMOVE% arr 1            Removes the first element of arr
::   %@ARRAY.REMOVE% arr -1           Removes the last element of arr
::
::
:: List of all variables associated with the array:
::    %arr%
::
::  Example:
::    call :return %arr%       Return an array from a function or script.
::
::
:: Undefine an array:
::    %@ARRAY.DELETE% arr
::


:: %@ARRAY.NEW% arrayName [sizeN] ["initval1"|VAR1] ["initval2"|VAR2] ...
set ^"@ARRAY.NEW=for %%# in (1 2) do if %%#==2 ( %#EOL%
for /f "tokens=1,2,* delims=[]= " %%A in ("!@array.args!") do ( %#EOL%
%========================================================================% %#EOL%
%= SECTION  Process Macro Args                                          =% %#EOL%
%=   token A  array name                                                =% %#EOL%
%=   token B  initial size                                              =% %#EOL%
%=   token C  list of values (REF variable or literal value)            =% %#EOL%
%=                                                                      =% %#EOL%
%= Undefine array if it already exists =% %#EOL%
for %%V in (!%%~A!) do set "%%V=" %#EOL%
%= Define new array =% %#EOL%
set "%%~A=%%~A %%~A[#]" %= Assoc vars =% %#EOL%
set /A "%%~A[#]=0" %= Size of array =% %#EOL%
%= Append initial values =% %#EOL%
for %%V in (%%C) do ( %#EOL%
  set /A "%%~A[#]+=1" %= Increment size =% %#EOL%
  set "%%~A=!%%~A! %%~A[!%%~A[#]!]" %= Append element name to var list =% %#EOL%
  set "@array.val=%%V" ^& if "!@array.val:~1,-1!"==!@array.val! ( %#EOL%
    set "%%~A[!%%~A[#]!]=!@array.val:~1,-1!" %= Assign literal value =% %#EOL%
  ) else set "%%~A[!%%~A[#]!]=!%%V!" %= Assign reference value =% %#EOL%
) %#EOL%
%= If size of array is less than the requested size, =% %#EOL%
%= append empty elements up to the requested array size. =% %#EOL%
set /A "@array.requestedsize=%%~B-1" %#EOL%
for /L %%i in (!%%~A[#]!,1,!@array.requestedsize!) do ( %#EOL%
  set /A "%%~A[#]+=1" %= Increment size =% %#EOL%
  set "%%~A=!%%~A! %%~A[!%%~A[#]!]" %= Append element name to var list =% %#EOL%
  set "%%~A[!%%~A[#]!]=" %= Assign empty value =% %#EOL%
) %#EOL%
%========================================================================% %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION  Cleanup Locals                                              =% %#EOL%
set "@array.args=" %#EOL%
set "@array.val=" %#EOL%
set "@array.requestedsize=" %#EOL%
%========================================================================% %#EOL%
) else set @array.args="


:: %@ARRAY.DELETE% arrayName
set ^"@ARRAY.DELETE=for %%# in (1 2) do if %%#==2 ( %#EOL%
for %%A in (!@array.args!) do for %%V in (!%%~A!) do set "%%V=" %#EOL%
set "@array.args=" %#EOL%
) else set @array.args="


:: %@ARRAY.GET% arrayName idx [VAR]
set ^"@ARRAY.GET=for %%# in (1 2) do if %%#==2 ( %#EOL%
for /f "tokens=1,2,3 delims=[]= " %%A in ("!@array.args!") do ( %#EOL%
%========================================================================% %#EOL%
%= SECTION  Process Macro Args                                          =% %#EOL%
%=   token A  array name                                                =% %#EOL%
%=   token B  index                                                     =% %#EOL%
%=   token C  variable name to assign value                             =% %#EOL%
%=                                                                      =% %#EOL%
if defined %%~A set /A "@array.idx=%%~B" 2^>nul ^&^& ( %#EOL%
  if !@array.idx! LEQ 0 set /A "@array.idx=!%%~A[#]!+1-(-!@array.idx! %% (!%%~A[#]!+1))" %#EOL%
  for %%i in (!@array.idx!) do if "%%~C"=="" ( echo %%~A[%%i]=!%%~A[%%i]!%#EOL%
  ) else set "%%~C=!%%~A[%%i]!" %#EOL%
) %#EOL%
%========================================================================% %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION  Cleanup Locals                                              =% %#EOL%
set "@array.args=" %#EOL%
set "@array.idx=" %#EOL%
%========================================================================% %#EOL%
) else set @array.args="


:: %@ARRAY.SET% arrayName idx VAR|"value"
set ^"@ARRAY.SET=for %%# in (1 4 2 3 1) do if %%#==1 ( %#EOL%
%========================================================================% %#EOL%
%= SECTION 1  Clear Locals                                              =% %#EOL%
for %%V in ( %#EOL%
@array.args %#EOL%
@array.nargs %#EOL%
@array.name %#EOL%
@array.size %#EOL%
@array.idx %#EOL%
@array.val %#EOL%
) do set "%%V=" %#EOL%
%========================================================================% %#EOL%
%= SECTION 2  Process Macro Args                     =% ) else if %%#==2 ( %#EOL%
%= @array.name      array name                                          =% %#EOL%
%= @array.idx       element index                                       =% %#EOL%
%= @array.val       value to store (REF variable or literal value)      =% %#EOL%
set "@array.nargs=0" %#EOL%
for %%A in (!@array.args!) do ( set /A "@array.nargs+=1" %#EOL%
  if !@array.nargs! EQU 1 ( set "@array.name=%%~A" %#EOL%
      if defined @array.name set /A "@array.size=!%%~A[#]!" %#EOL%
  ) else if !@array.nargs! EQU 2 ( set /A "@array.idx=%%~A" %#EOL%
      if defined @array.idx if !@array.idx! LEQ 0 set /A "@array.idx=!@array.size!+1-(-!@array.idx! %% (!@array.size!+1))" %#EOL%
  ) else if !@array.nargs! EQU 3 ( set "@array.val=%%A" %#EOL%
      %=                 =% if "!@array.val:~1,-1!"==!@array.val! ( set "@array.val=!@array.val:~1,-1!" ) else ( set "@array.val=!%%A!" ) %#EOL%
  ) %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION 3  Macro Body                             =% ) else if %%#==3 ( %#EOL%
if !@array.nargs! GEQ 3 ( %#EOL%
  if !@array.idx! LEQ !@array.size! set "!@array.name![!@array.idx!]=!@array.val!" %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION 4  Load Macro Args                        =% ) else set @array.args="


:: %@ARRAY.FOREACH:NAME=arrayName% ( ... )
set ^"@ARRAY.FOREACH=for /L %%i in (1,1,!NAME[#]!) do "


:: (%@ARRAY.CONTAINS% arrayName VAR|"value" [IDXVAR]) %% ( found ) || ( notfound )
set ^"@ARRAY.CONTAINS=for %%# in (1 4 2 3 1) do if %%#==1 ( %#EOL%
%========================================================================% %#EOL%
%= SECTION 1  Clear Locals                                              =% %#EOL%
for %%V in ( %#EOL%
@array.args %#EOL%
@array.nargs %#EOL%
@array.name %#EOL%
@array.size %#EOL%
@array.val %#EOL%
@array.var %#EOL%
) do set "%%V=" %#EOL%
if defined @array.idx ( set "@array.idx=" ^& (call )) else (call) %#EOL%
%========================================================================% %#EOL%
%= SECTION 2   Process Macro Args                    =% ) else if %%#==2 ( %#EOL%
%= @array.name    array name                                            =% %#EOL%
%= @array.val     value to search for (REF variable or literal value)   =% %#EOL%
%= @array.var     optional var to return array element index            =% %#EOL%
for %%A in (!@array.args!) do ( set /A "@array.nargs+=1" %#EOL%
  if !@array.nargs! EQU 1 (%#EOL%
    set "@array.name=%%~A" %#EOL%
    if defined @array.name set /A "@array.size=!%%~A[#]!" %#EOL%
  ) else if !@array.nargs! EQU 2 (%#EOL%
    set "@array.val=%%A" %#EOL%
    if "!@array.val:~1,-1!"==!@array.val! ( set "@array.val=!@array.val:~1,-1!" ) else ( set "@array.val=!%%A!" ) %#EOL%
  ) else if !@array.nargs! EQU 3 (%#EOL%
    set "@array.var=%%~A" %#EOL%
  ) %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION 3  Macro Body                             =% ) else if %%#==3 ( %#EOL%
if !@array.nargs! GEQ 2 for /F "tokens=1" %%A in ("!@array.name!") do ( %#EOL%
  %= Iterate over array elements, store first idx containing val =% %#EOL%
  for /L %%i in (1,1,!@array.size!) do ( %#EOL%
    if not defined @array.idx if "!%%~A[%%i]!"=="!@array.val!" set "@array.idx=%%i" %#EOL%
  ) %#EOL%
  if defined @array.var set "!@array.var!=!@array.idx!" %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION 3   Load Input Args                       =% ) else set @array.args="


:: %@ARRAY.APPEND% arrayName "appendval1"|VAR1 ["appendval2"|VAR2] ...
set ^"@ARRAY.APPEND=for %%# in (1 2) do if %%#==2 ( %#EOL%
for /f "tokens=1* delims=[]= " %%A in ("!@array.args!") do ( %#EOL%
%========================================================================% %#EOL%
%= SECTION  Process Macro Args                                          =% %#EOL%
%=   token A  array name                                                =% %#EOL%
%=   token B  list of values (REF variable or literal value)            =% %#EOL%
%=                                                                      =% %#EOL%
set "@array.vals=%%B" %#EOL%
if defined @array.vals ( %#EOL%
  %= Define new array if necessary =% %#EOL%
  if not defined %%~A ( %#EOL%
    set "%%~A=%%~A %%~A[#]" %= Assoc vars =% %#EOL%
    set /A "%%~A[#]=0" %= Size of array =% %#EOL%
  ) %#EOL%
  %= Append new values to end of array =% %#EOL%
  for %%V in (!@array.vals!) do ( %#EOL%
    set /A "%%~A[#]+=1" %= Increment size =% %#EOL%
    set "%%~A=!%%~A! %%~A[!%%~A[#]!]" %= Append element name to var list =% %#EOL%
    set "@array.val=%%V" %#EOL%
    if "!@array.val:~1,-1!"==!@array.val! ( %#EOL%
      set "%%~A[!%%~A[#]!]=!@array.val:~1,-1!" %= Assign literal value =% %#EOL%
    ) else set "%%~A[!%%~A[#]!]=!%%V!" %= Assign reference value =% %#EOL%
  ) %#EOL%
) %#EOL%
%========================================================================% %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION  Cleanup Locals                                              =% %#EOL%
set "@array.args=" %#EOL%
set "@array.vals=" %#EOL%
set "@array.val=" %#EOL%
%========================================================================% %#EOL%
) else set @array.args="


:: %@ARRAY.INSERT% arrayName idx "insertval1"|VAR1 ["insertval2"|VAR2] ...
set ^"@ARRAY.INSERT=for %%# in (1 2) do if %%#==2 ( %#EOL%
for /f "tokens=1,2* delims=[]= " %%A in ("!@array.args!") do ( %#EOL%
%========================================================================% %#EOL%
%= SECTION  Process Macro Args                                          =% %#EOL%
%=   token A  array name                                                =% %#EOL%
%=   token B  index                                                     =% %#EOL%
%=   token C  list of values (REF variables or literal values)          =% %#EOL%
%=                                                                      =% %#EOL%
set "@array.vals=%%C" %#EOL%
if defined @array.vals ( %#EOL%
  %= Define new array if necessary =% %#EOL%
  if not defined %%~A ( %#EOL%
    set "%%~A=%%~A %%~A[#]" %= Assoc vars =% %#EOL%
    set /A "%%~A[#]=0" %= Size of array =% %#EOL%
  ) %#EOL%
  set "@array.oldsize=!%%~A[#]!" %#EOL%
  set /A "@array.insertidx=%%~B" 2^>nul ^|^| set /A "@array.insertidx=0" %#EOL%
  if !@array.insertidx! LEQ 0 set /A "@array.insertidx=!@array.oldsize!+1-(-!@array.insertidx! %% (!@array.oldsize!+1))" %#EOL%
  %= Increase size of array to accomodate the new elements =% %#EOL%
  set "@array.insertqty=0" ^& for %%V in (!@array.vals!) do set /A "@array.insertqty+=1" %#EOL%
  if !@array.insertidx! GTR !@array.oldsize! set /A "@array.insertqty+=!@array.insertidx!-!@array.oldsize!-1" %#EOL%
  for /L %%i in (1,1,!@array.insertqty!) do ( %#EOL%
    set /A "%%~A[#]+=1" %= Increment size =% %#EOL%
    set "%%~A=!%%~A! %%~A[!%%~A[#]!]" %= Append element name to var list =% %#EOL%
    set "%%~A[!%%~A[#]!]=" %= Assign empty value =% %#EOL%
  ) %#EOL%
  %= Shift every element GEQ index by the number of values being inserted =% %#EOL%
  for /L %%i in (!@array.oldsize!,-1,!@array.insertidx!) do ( %#EOL%
    set /A "@array.newidx=%%i+!@array.insertqty!" %#EOL%
    set "%%~A[!@array.newidx!]=!%%~A[%%i]!" %#EOL%
  ) %#EOL%
  %= Write new values starting at idx =% %#EOL%
  set "@array.newidx=!@array.insertidx!" %#EOL%
  for %%V in (!@array.vals!) do ( %#EOL%
    set "@array.val=%%V" %#EOL%
    if "!@array.val:~1,-1!"==!@array.val! ( %#EOL%
      set "%%~A[!@array.newidx!]=!@array.val:~1,-1!" %= Assign literal value =% %#EOL%
    ) else set "%%~A[!@array.newidx!]=!%%V!" %= Assign reference value =% %#EOL%
    set /A "@array.newidx+=1" %#EOL%
  ) %#EOL%
) %#EOL%
%========================================================================% %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION  Cleanup Locals                                              =% %#EOL%
set "@array.args=" %#EOL%
set "@array.oldsize=" %#EOL%
set "@array.insertidx=" %#EOL%
set "@array.insertqty=" %#EOL%
set "@array.newidx=" %#EOL%
set "@array.vals=" %#EOL%
set "@array.val=" %#EOL%
%========================================================================% %#EOL%
) else set @array.args="


:: %@ARRAY.REMOVE% arrayName idx [idx2] [idx3] ...
set ^"@ARRAY.REMOVE=for %%# in (1 2) do if %%#==2 ( %#EOL%
for /f "tokens=1* delims=[]= " %%A in ("!@array.args!") do ( %#EOL%
%========================================================================% %#EOL%
%= SECTION  Process Macro Args                                          =% %#EOL%
%=   token A  array name                                                =% %#EOL%
%=   token B  list of indices to remove                                 =% %#EOL%
%=                                                                      =% %#EOL%
if defined %%~A ( %#EOL%
  %= Prepare the list of indicies to remove (clamp -idx to size range) =% %#EOL%
  set "@array.idxlist= " %#EOL%
  for %%i in (%%~B) do set /A "@array.removeidx=%%i" 2^>nul ^&^& ( %#EOL%
    if !@array.removeidx! LEQ 0 set /A "@array.removeidx=!%%~A[#]!+1-(-!@array.removeidx! %% (!%%~A[#]!+1))" %#EOL%
    set "@array.idxlist=!@array.idxlist!!@array.removeidx! " %#EOL%
  ) %#EOL%
  set "%%~A=%%~A %%~A[#]" %= Clear old assoc vars list =% %#EOL%
  %= For each element, keep the value if its index is NOT in the idxlist. =% %#EOL%
  %=    So increment newidx and copy the value back to that spot. =% %#EOL%
  set "@array.newidx=0" %#EOL%
  for /L %%i in (1,1,!%%~A[#]!) do ( %#EOL%
    if "!@array.idxlist: %%i =!"=="!@array.idxlist!" ( %= i is not in idxlist =% %#EOL%
      set /A "@array.newidx+=1" %= Increment size =% %#EOL%
      set "%%~A=!%%~A! %%~A[!@array.newidx!]" %= Append element name to var list =% %#EOL%
      set "%%~A[!@array.newidx!]=!%%~A[%%i]!" %= Assign original value =% %#EOL%
  ) ) %#EOL%
  %= Clear old values left at the end of the array =% %#EOL%
  for /L %%i in (!@array.newidx!,1,!%%~A[#]!) do ( %#EOL%
    if %%i GTR !@array.newidx! set "%%~A[%%i]=" %#EOL%
  ) %#EOL%
  set "%%~A[#]=!@array.newidx!" %= Store new size =% %#EOL%
) %#EOL%
%========================================================================% %#EOL%
) %#EOL%
%========================================================================% %#EOL%
%= SECTION  Cleanup Locals                                              =% %#EOL%
set "@array.args=" %#EOL%
set "@array.removeidx=" %#EOL%
set "@array.idxlist=" %#EOL%
set "@array.newidx=" %#EOL%
%========================================================================% %#EOL%
) else set @array.args="


cls
setlocal EnableDelayedExpansion

echo.
echo ARRAY.NEW
set "REFVAR=item 2"
%@ARRAY.NEW% arr[0]="item 1" REFVAR
set arr
echo.

echo.
echo ARRAY.GET ARRAY.SET
%@ARRAY.SET% arr 1 "firstitem"
%@ARRAY.SET% arr -1 "lastitem"
%@ARRAY.SET% arr 0 "outofbounds"
set "VAR="
for /L %%i in (1,1,!arr[#]!) do (
  %@ARRAY.GET% arr[%%i] VAR
  echo arr[%%i]=!VAR!
)
echo.

echo.
echo ARRAY.FOREACH
%@ARRAY.FOREACH:NAME=arr% echo arr[%%i]=!arr[%%i]!
echo.

echo.
echo @ARRAY.CONTAINS
set "idx="
set "val1=lastitem"
set "val2=outofbounds"
(%@ARRAY.CONTAINS% arr   val1   idx) && ( echo Found "%val1%" at idx=!idx! ) || ( echo Value "%val1%" not found )
(%@ARRAY.CONTAINS% arr "%val2%" idx) && ( echo Found "%val2%" at idx=!idx! ) || ( echo Value "%val2%" not found )
echo.

echo.
echo ARRAY.REMOVE
%@ARRAY.REMOVE% arr 1 -1
set arr
echo.

echo.
echo ARRAY.INSERT
set "REFVAR=item 5"
%@ARRAY.INSERT% arr[3] "item 3" REFVAR
%@ARRAY.INSERT% arr[-1] "item 4"
%@ARRAY.INSERT% arr[1] "item 1" "item 2"
%@ARRAY.INSERT% arr[0] "item 6"
%@ARRAY.FOREACH:NAME=arr% echo arr[%%i]=!arr[%%i]!
echo.

echo.
echo ARRAY.APPEND
set "REFVAR=item 8"
%@ARRAY.APPEND% arr "item 7" REFVAR
%@ARRAY.FOREACH:NAME=arr% echo arr[%%i]=!arr[%%i]!
echo.

echo.
echo ARRAY.DELETE
%@ARRAY.DELETE% arr
set arr
echo.

exit /b 0


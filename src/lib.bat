::==============================================================================
::  lib.bat
::==============================================================================
:::.{head}.Summary:
:::  Common Library of Batchfile Macros.
:::
:::..{general}.Loading and Using Macros:
:::  Run  <basename> /list  to show available macros.
:::
:::    :: Load macros
:::    setlocal DisableDelayedExpansion
:::    call "path\to\<basename>" /import || exit /b 1
:::
:::    :: Use macros
:::    setlocal EnableDelayedExpansion
:::    %@MACRO.NAME% [arg1] [arg2] ...
:::
:::..{general}.What is a macro?
:::  Batchfile "Macros" are regular variables containing executable code,
:::  which executes upon expansion.
:::
:::  Their purpose is portability and performance. It is often easier to
:::  source a macro library (such as this one) than to maintain a function
:::  and its dependencies within a script. Moreover, macros are typically
:::  an order of magnitude faster than the equivalent function, since they
:::  are already loaded into memory.
:::
:::  Macros are defined in DDE mode (`setlocal DisableDelayedExpansion`)
:::  because they contain many special characters which would otherwise need
:::  lengthy escape sequences.
:::
:::  Macro expansion requires EDE mode (`setlocal EnableDelayedExpansion`),
:::  because code is parsed after %%-expansion and before !!-expansion.
:::
:::..{category}.Categories:
:::
:::..{category}.@ARGS     Macros for processing command-line arguments and other
:::          structured strings
:::
:::..{category}.@ARRAY    Macros for creating, indexing, and modifying
:::          array-like data structures.
:::          Detailed examples are available; run
:::            <basename> /? <subtitle>
:::
:::....{detail}.Syntax and Usage Notes:
:::  - All macros require EnableDelayedExpansion.
:::  - Size of array is stored in %arr[#]% .
:::  - Arrays are 1-indexed.
:::      The first value is %arr[1]% and the last value is %arr[!arr[#]!]%
:::  - Indices in macro args can be specified as positive, negative, or 0:
:::      idx=-1 references arr[#] (last element)
:::      idx=-2 references arr[#]-1
:::      idx=0 references arr[#]+1 (first out-of-bounds index)
:::  - "Quoted" macro args are treated as literal strings.
:::      The corresponding array element (%arr[i]%) is set to the
:::      string within the outer quotes.
:::  - UNQUOTED macro args are treated as reference variables.
:::      The corresponding array element (%arr[i]%) is set to the value of
:::      the variable named by arg.
:::  - %arr% contains a space-separated list of all variables associated with the array.
:::
:::.....Examples:
:::
:::......Creating an array:
:::  Command:                        Result:
:::    %@ARRAY.DEFINE% arr                0-element array
:::    %@ARRAY.DEFINE% arr N              N-element array, each element is empty (undefined)
:::    %@ARRAY.DEFINE% arr N VARNAME      N-element array, with arr[1]=!VARNAME!
:::    %@ARRAY.DEFINE% arr N "string"     N-element array, with arr[1]=string
:::
:::  Example:
:::    %@ARRAY.DEFINE% arr 2 VAR "string"
:::  Variable:       Value:
:::    arr             arr arr[#] arr[1] arr[2]
:::    arr[#]          2
:::    arr[1]          (value of VAR)
:::    arr[2]          string
:::
:::
:::......Retrieving array elements:
:::  Command:                        Result:
:::    %arr[#]%                        Size of array, idx of last element
:::    !arr[1]!                        Value of first element
:::    !arr[%arr[#]%]!                 Value of last element
:::    !arr[idx]!                      Value of element at idx
:::    %@ARRAY.GET% arr idx VAR        Sets VAR= Value at idx (idx may be negative)
:::
:::
:::......Assigning array elements:
:::  Command:                        Result:
:::    set "arr[idx]=..."              Set value of element at idx
:::    %@ARRAY.SET% arr idx VAR        Set value at idx to value of VAR (idx may be negative)
:::
:::
:::......Iterate over all elements:
:::    for /L %%i in (1,1,%arr[#]%) do ( echo %%v[%%i]=!%%v[%%i]! )
:::  OR:
:::    %@ARRAY.FOREACH:NAME=arr% ( echo %%v[%%i]=!%%v[%%i]! )
:::
:::
:::......Append value(s) to end of array:
:::  Command:                        Result:
:::    %@ARRAY.APPEND% arr ""          Appends an empty value to the array
:::    %@ARRAY.APPEND% arr VAR         Appends the value of VAR
:::    %@ARRAY.APPEND% arr "string"    Appends the value "string" (without "")
:::
:::
:::......Insert value(s) at the specified index:
:::  Command:                            Result:
:::    %@ARRAY.INSERT% arr idx ""          Inserts empty value at idx
:::    %@ARRAY.INSERT% arr idx VAR         Inserts value of VAR at idx
:::    %@ARRAY.INSERT% arr idx "string"    Inserts "string" at idx (without "")
:::    %@ARRAY.INSERT% arr 1 "string"      Inserts "string" at the start of arr
:::    %@ARRAY.INSERT% arr 0 "string"      Inserts "string" at the end of arr
:::
:::  Existing values are unchanged. Each element after idx is shifted to a
:::    higher idx to accomodate the new element.
:::
:::
:::......Remove element(s) from array:
:::  Command:                        Result:
:::   %@ARRAY.REMOVE% arr idx          Removes the value at idx, then decrements
:::                                    the index of all elements after idx.
:::   %@ARRAY.REMOVE% arr 1            Removes the first element of arr
:::   %@ARRAY.REMOVE% arr -1           Removes the last element of arr
:::
:::
:::......List of all variables associated with the array:
:::    %arr%
:::
:::
:::......Undefine an array:
:::    %@ARRAY.DELETE% arr
:::
:::..{category}.@STRING   Macros for string manipulation
:::
::==============================================================================

@echo off & for /f "tokens=1-3 delims=/-" %%1 in (".autogoto./%1") do (if "%%3"=="" (goto :%%1%%2) else goto) 2>nul || (%=Usage Info=% setlocal DisableDelayedExpansion&echo.&echo Usage:&echo.&(for /F "tokens=1* delims=:." %%A in ('findstr /RIC:"^:\.autogoto\.[^\ ]" "%~f0"') do echo   %~nx0 /%%B)&endlocal)



%====================================================================%  goto :EOF
:.autogoto.import              Import macros into the current scope.

if "!!"=="" 2>&1 echo ERROR: Macro definition requires DisableDelayedExpansion.& exit /b 1

set ^"LF=^
%= EMPTY LINE =%
^"
set "TAB=	"
if defined #LF goto :continue
set    ^"#LF=^^^%LF%%LF%^%LF%%LF%^"                           %= Percent-Expands to a single LF in DDE =%
set   ^"#EOL=^^^%LF%%LF%^"                                    %= User provides the missing LF when expanding this at the end of a macro line =%
set   ^"##LF=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"   %= Produces a single LF after two percent-expansions in DDE =%
set  ^"##EOL=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"
set  ^"###LF=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set ^"###EOL=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"
:continue




::==============================================================================
:::.%@ARGS<dot>SPLIT%      [var:in] [var:out] [str:extra_carets] [var:sep]
:::.%@#ARGS<dot>SPLIT%     [var:in] [var:out] [str:extra_carets] [var:sep] (Embeddable)
:::
:::  Quote-aware string split. For each unquoted string of whitespace in [in],
:::    replaces that string with [sep].
:::  Inside "quotes", all characters, including whitespace, are preserved.
:::
:::..Parameters:
:::  [var:in]                Name of variable containing arguments string.
:::                            No-op if omitted.
:::  [var:out]               Name of variable to store results.
:::                            Overwrites [var:in] if omitted.
:::  [str:extra_carets]      String containing an escape sequence which is
:::                            placed before each occurrance of '^' and '!'.
:::  [var:sep]               Unquoted whitespace is replaced with [sep].
:::                            If omitted, uses the value of linefeed (LF).
:::
:::..Formatting:
:::   - Within quotes, spaces, tabs, and linefeeds are preserved.
:::   - '^' and '!' are escaped such that they are returned verbatim.
:::     Additional carets can be added by specifying [extra_carets]="^".
:::   - Literal " should be escaped as "" within a "quoted block".
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@#ARGS.SPLIT) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 (%##EOL%
%------------------------------------------------------------------------% %##EOL%
%- SECTION 2  Macro Body                                                -% %##EOL%
for /f "tokens=1-4" %%1 in ("!%%@.args!") do if not "%%~1"=="" for /f "tokens=1" %%2 in ("%%~2 %%~1") do for %%L in (^^^^^^^"%###LF%^^^^^^^") do ( %##EOL%
	set "%%@.in=!%%~1!" %##EOL%
	set "%%2=" %##EOL%
	if not "!%%@.in!"=="" ( %##EOL%
		set "%%@.in=!%%@.in:#=#p!"					%= 1. Escape # first so future steps can use # as a marker =% %##EOL%
		set "%%@.in=!%%@.in:%%~L=#l!"				%= 2. Remove linefeeds or Step 5, 7 will fail =% %##EOL%
		set ^"%%@.in=!%%@.in:"=#q!^"				%= 3. Remove quotes or step 5, 7, 8 will sometimes fail =% %##EOL%
		set "%%@.in=!%%@.in:^=#c^^!"				%= 4. Escape carets to survive percent-expansion. Place a marker before each caret so we can easly do more escaping later on. =% %##EOL%
		call set "%%@.in=%%!=!%%@.in:^!=#e^!%%" 	%= 5. Need to escape exclamations, so must use percent-expansion, but cannot set the correct escape sequence with 'call set', so just mark where the exclamations are for now.=% %##EOL%
		set "%%@.in=!%%@.in:#e=#c^!"!				%= 6. Escape exclamations to survive percent-expansion. Place a marker before each exclamation so we can easily do more escaping later on. =% %##EOL%
		set "%%@.numq=0" %##EOL%
		for /f tokens^^^^=*^^^^ delims^^^^=^^^^ eol^^^^= %%T in ("!%%@.in:#q=#q%%~L!") do ( %= 7. Split on doublequotes. For each quoted block... =% %##EOL%
			set /A "%%@.numq=(%%@.numq+1) %% 2"		%= Alternates btw 1 (outside quotes) and 0 (inside quotes) =% %##EOL%
			set "%%@.tok=%%T"!						%= 8. Collect the quoted block. Requires percent expansion, but all weird characters are gone or escaped now =% %##EOL%
			if !%%@.numq!==1 if not "!%%@.tok!"=="" (%= 9. Outside quotes, replace each block of whitespace with [sep] =% %##EOL%
				set "%%@.tok=!%%@.tok: =" "!"		%=    Mark (quote) before and after each whitespace char =% %##EOL%
				set "%%@.tok=!%%@.tok:%TAB%=" "!" %##EOL%
				set "%%@.tok=!%%@.tok:#l=" "!" %##EOL%
				set "%%@.tok=!%%@.tok:""=!"			%=    Combine consecutive marks. Now only remaining marks are at beginning and end of whitespace blocks. =% %##EOL%
				set "%%@.tok=!%%@.tok: =!"			%=    Remove whitespace, bringing the start+end marks together. =% %##EOL%
				set "%%@.tok=!%%@.tok:""=#s!"		%=    Replace what was once a whitespace block with a single [sep]. =% %##EOL%
			)										%= 9. Inside quotes, do nothing, keep whitespace intact =% %##EOL%
			set "%%2=!%%2!!%%@.tok!"				%=10. Append to output =% %##EOL%
		) %##EOL%
		if "!%%2:~,2!"=="#s" set "%%2=!%%2:~2!"		%= 11. Trim leading and trailing [sep] =% %##EOL%
		if "!%%2:~-2!"=="#s" set "%%2=!%%2:~,-2!" %##EOL%
		if "%%~4"=="" (set "%%2=!%%2:#s=%%~L!") else for %%L in ("!%%~4!") do set "%%2=!%%2:#s=%%~L!" %##EOL%
		set "%%2=!%%2:#c=%%~3!" %##EOL%
		set ^"%%2=!%%2:#q="!^" %##EOL%
		set "%%2=!%%2:#l=%%~L!" %##EOL%
		set "%%2=!%%2:#p=#!" %##EOL%
	) %##EOL%
) %##EOL%
%= Cleanup local variables =% %##EOL%
set "%%@.args="%##EOL%
set "%%@.in="%##EOL%
set "%%@.tok="%##EOL%
set "%%@.numq="%##EOL%
%------------------------------------------------------------------------% %##EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
set ^"@ARGS.SPLIT=%@#ARGS.SPLIT%"
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@ARGS.SPLIT [var:args]
	setlocal EnableDelayedExpansion
	set "in=!%~1!" & if "!in: =!"=="" set ^"in=%#EOL%
		item1 "item 2"		%#EOL%
		"item=""^^3^^"""	%#EOL%
		item4="!LF!"		%#EOL%
							%#EOL%
		"%%item6%%"			%#EOL%
		"^!item7^!"			%#EOL%
	^"
	set "out="
	set "carets=^"
	set "sep=#LF"

	echo in=[!in!]
	echo.
	echo Executing:!LF!  %%@ARGS.SPLIT%% in out !carets! !sep!
	%@ARGS.SPLIT% in out !carets! !sep!
	echo.
	echo out=[!out!]
	echo.
	exit /b 0
:continue
::==============================================================================





::==============================================================================
:::.%@ARGS<dot>PARSE%      [var:in] [var:out] [str:extra_carets] [/preserve-quotes] [/debug]
:::  Splits a string into arguments, storing each in a uniquely-named variable.
:::
:::  Arguments must be separated by tabs, spaces, or linefeeds, and may be formatted as:
:::    ARGUMENT                TYPE                 RESULT
:::    value                   Positional arg   --> %out[1]%    --> value
:::    "val with spaces"       Positional arg   --> %out[2]%    --> val with spaces
:::    ""                      Empty positional --> %out[3]%    -->
:::    /flg1=value             Flag with value  --> %out[flg1]% --> value
:::    /flg2="val with space"  Flag with value  --> %out[flg2]% --> val with space
:::    /flg3                   Empty flag       --> %out[flg3]% -->
:::    /flg4=                  Empty flag       --> %out[flg4]% -->
:::    /flg5=""                Empty flag       --> %out[flg5]% -->
:::    /3="override"           Positional arg   --> %out[3]%    --> override
:::
:::  This set of arguments also results in the following special varaiables:
:::
:::  - %out%       --> out[1] out[2] out[3] out[flg1] ...
:::    List of generated argument variables.
:::    If provided multiple flags with the same name, only the last value is kept:
:::        /1="default"  "new value"  -->   %out[1]% --> new value
:::
:::  - %out.npos%  --> 3
:::    Total number of positional arguments (not including numbered flags /N=...)
:::
:::..Parameters:
:::  [var:in]                Name of variable containing arguments string.
:::                            No-op if omitted.
:::  [var:out]               Name of variable to store results.
:::                            Overwrites [var:in] if omitted.
:::  [str:extra_carets]      String containing an escape sequence which is
:::                            placed before each occurrance of '^' and '!'.
:::  [/preserve-quotes]      If provided, doublequotes in values are preserved.
:::                            If omitted, one layer of exterior quotes are
:::                            stripped, and internal "" are replaced with ".
:::
:::..Formatting:
:::  Flag Arguments:
:::     /flag[=value]        Flags start with '/' or '-'. Values start with '=' with ':'.
:::     /flag[="value"]      Values with spaces or other special characters should be quoted.
:::     /"flag"[=value]      Quoted flags may contain spaces, but this should be avoided.
:::                          Flags may not contain '!', '^', '~', '=', '%', '*' or errors will occur.
:::
:::  Positional Arguments:
:::     value                Unquoted values may not contain whitespace.
:::     "value"              Quoted values may contain any characters.
:::                            Escape doublequotes " with double-doublequotes "".
:::     /3[=value]           Numbered flags override the corresponding positional argument
:::                            but do not increment the special variable '[out].npos'.
:::
:::  Example usage:
:::    Parse command line arguments:
:::
:::      setlocal DisableDelayedExpansion
:::      set ^"args=/1="default value" %*"
:::      setlocal EnableDelayedExpansion
:::      %@ARGS.PARSE% args
:::
:::    Print all arguments:
:::
:::      for /f "delims=" %%v in ("!args!") do echo(%%v=[!%%v!]
:::
:::    Print all positional arguments:
:::
:::      for /L %%i in (1,1,!args.npos!) do echo(args[%%i]=!args[%%i]!
:::
:::    Check if the /? flag was specified:
:::
:::      if not "!args:args[?]=!"=="!args!" ( %= flag was specified =% )
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@ARGS.PARSE) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 (%#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 2  Macro Body                                                -% %#EOL%
for /f "tokens=1-4" %%1 in ("!%%@.args!") do if not "%%~1"=="" for /f "tokens=1" %%2 in ("%%~2 %%~1") do for %%L in (^^^"%##LF%^^^") do ( %#EOL%
	set "%%@.in=!%%~1!"%#EOL%
	for %%v in (!%%2!) do set "%%v="%#EOL%
	set "%%2="%#EOL%
	set "%%2.npos=0"%#EOL%
	if defined %%@.in ( %#EOL%
		set "%%@.in=!%%@.in:#=#p!"%= Escape '#' so next line can use '#c' as a marker =%%#EOL%
		%@#ARGS.SPLIT% %%@.in %%@.in "#c^^^^^^^"%= Produces a linefeed-separated list of arguments, with enough extra carets to survive 2x percent expansion in EDE, and '#c' markers for more carets later on =%%#EOL%
		for /f tokens^^=*^^ delims^^=^^=:^^ ^^%TAB%^^ eol^^= %%a in ("!%%@.in!") do (%= For each argument... =%%#EOL%
			set "%%@.arg=%%a"!%= First Percent Expansion =%%#EOL%
			if not "%%~5"=="" echo(--^^^> arg=[!%%@.arg!]%#EOL%
			if not "!%%@.arg:~,1!"=="/" if not "!%%@.arg:~,1!"=="-" (%= Prepend numbered flag to positional arguments. =% %#EOL%
				set /A "%%2.npos+=1"%#EOL%
				set "%%@.arg=/!%%2.npos!=!%%@.arg!"%#EOL%
			) %#EOL%
			for /f tokens^^=1*^^ delims^^=^^=:^^ eol^^= %%b in ("!%%@.arg!") do (%= In arg, strip leading equals and colon, and split into a flag and value. Block does not run if arg contains only equals or colon. =%%#EOL%
				for /f tokens^^=*^^ delims^^=/-^^ eol^^= %%b in ("%%b") do (%= In flag, strip leading '/' and '-'. Block does not run if flag contains only '/' or '-'. =%%#EOL%
					if defined %%2 (set "%%2=!%%2:%%2[%%b]%%~L=!%%2[%%b]%%~L") else set "%%2=%%2[%%b]%%~L"%= Store flag =%%#EOL%
					if "%%~4"=="" (set "%%@.val=%%~c") else set "%%@.val=%%c"!%= Second Percent Expansion =%%#EOL%
					if defined %%@.val if "%%~4"=="" set ^"%%@.val=!%%@.val:""="!"%= Remove one layer of quotes =%%#EOL%
					if defined %%@.val set "%%@.val=!%%@.val:#c=%%~3!"%#EOL%
					if defined %%@.val set "%%@.val=!%%@.val:#p=#!"%#EOL%
					set "%%2[%%b]=!%%@.val!"%= Store value =%%#EOL%
					if not "%%~5"=="" echo(    flg=[%%b]^&echo(    val=[!%%@.val!]%#EOL%
				)%#EOL%
			)%#EOL%
		) %#EOL%
	) %#EOL%
) %#EOL%
%= Cleanup local variables =% %#EOL%
set "%%@.args="%#EOL%
set "%%@.in="%#EOL%
set "%%@.val="%#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@ARGS.PARSE [var:args]
	setlocal EnableDelayedExpansion
	set "in=!%~1!" & if "!in: =!"=="" set ^"in=%#EOL%
		^^!value^^!						%= out[1]        =%%#EOL%
		"val ""^!with^!"" spaces"		%= out[2]        =%%#EOL%
		=weird" "positional				%= out[3]        =%%#EOL%
		""								%= out[4]        =%%#EOL%
		"" /5="override 5"				%= out[5]        =%%#EOL%
		/flg1=value						%= out[flg1]     =%%#EOL%
		/flg2:"val ""^!with^!"" spaces"	%= out[flg2]     =%%#EOL%
		--flg3							%= out[flg3]     =%%#EOL%
		/flg4=							%= out[flg4]     =%%#EOL%
		--flg5:""						%= out[flg5]     =%%#EOL%
		/"flag 6"						%= out["flag 6"] =%%#EOL%
		/"flag 7"="value"				%= out["flag 7"] =%%#EOL%
		/?								%= out[?]        =%%#EOL%
		/="no flag"						%= invalid       =%%#EOL%
		/								%= invalid       =%%#EOL%
		=								%= invalid       =%%#EOL%
		:								%= invalid       =%%#EOL%
	^"
	set "out="
	set "extra_carets=#c"
	::set "preserve_quotes=/preserve-quotes"
	set "debug=/debug"

	echo in=[!in!]
	echo.
	echo Executing:!LF!  %%@ARGS.SPLIT%% in out "!extra_carets!" "!preserve_quotes!" "!debug!"
	%@ARGS.PARSE% in out "!extra_carets!" "!preserve_quotes!" "!debug!"
	echo.
	for /f "delims=" %%v in ("out.npos!LF!!out!") do echo(%%v=[!%%v!]
	echo.
	exit /b 0
:continue
::==============================================================================




::==============================================================================
:::.%@ARRAY<dot>DEFINE%    {var:array} [int|"":size] [var|"str"] [var|"str"] ...
:::
:::  Initializes a new array, optionally initializing its values.
:::  Each element is stored as: array[idx]=val
:::  The final size is max(size, num_vals).
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@ARRAY.DEFINE) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 (%#EOL%
%========================================================================% %#EOL%
%= SECTION 2  Macro Body                                                =% %#EOL%
set "%%@.err="^&for /f "tokens=1-2* delims=[]= " %%1 in ("!%%@.args!") do (%#EOL%
       if "%%~1"=="" (set %%@.err=1%#EOL%
) else if defined %%~1 (set %%@.err=1%#EOL%
) else (%=                                   Define new array           =% %#EOL%
	set "%%~1=%%~1 %%~1[#]" %=               Init var list              =% %#EOL%
	set /A "%%~1[#]=0" %=                    Init array size            =% %#EOL%
	for %%3 in (%%3) do ( %=                 Append values              =% %#EOL%
		if %%3=="%%~3" (set "%%@.val=%%~3") else set "%%@.val=!%%3!"!%= Dereference unquoted value =% %#EOL%
		set /A "%%~1[#]+=1" %=               Increment array size       =% %#EOL%
		set "%%~1=!%%~1! %%~1[!%%~1[#]!]" %= Append name to var list    =% %#EOL%
		set "%%~1[!%%~1[#]!]=!%%@.val!" %=   Store new value            =% %#EOL%
	) %#EOL%
	set /A "%%@.size=%%~2-1" %=              Expand array               =% %#EOL%
	for /L %%i in (!%%~1[#]!,1,!%%@.size!) do (%#EOL%
		set /A "%%~1[#]+=1" %=               Increment array size       =% %#EOL%
		set "%%~1=!%%~1! %%~1[!%%~1[#]!]" %= Append name to var list    =% %#EOL%
		set "%%~1[!%%~1[#]!]=" %=            Store empty value          =% %#EOL%
	) %#EOL%
)) %#EOL%
%= Cleanup local variables =% %#EOL%
set "%%@.args="%#EOL%
set "%%@.val="%#EOL%
set "%%@.size="%#EOL%
%= Return error if something went wrong =% %#EOL%
if defined %%@.err (set "%%@.err=" ^& call) else (call )%#EOL%
%========================================================================% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@ARRAY.DEFINE [var:args]
	setlocal EnableDelayedExpansion
	set "array=arr"
	set "size=4"
	set "vals=!%~1!" & if "!vals: =!"=="" set "vals=ref1 "literal 1""
	set "ref1=reference 1"

	echo(!LF!Executing:!LF!  %%@ARRAY.DEFINE%% !array! !size! !vals!
	%@ARRAY.DEFINE% !array! !size! !vals!

	echo(!LF!Result:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.
	exit /b 0
:continue
::==============================================================================





::==============================================================================
:::.%@ARRAY<dot>DELETE%    [var:array] [var:array] ...
:::
:::  Undefines [array] and all its associated variables.
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@ARRAY.DELETE) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 (%#EOL%
%========================================================================% %#EOL%
%= SECTION 2  Macro Body                                                =% %#EOL%
for %%a in (!%%@.args!) do for %%v in (!%%~a!) do set "%%v=" %#EOL%
%= Cleanup local variables =% %#EOL%
set "%%@.args="%#EOL%
%========================================================================% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@ARRAY.DELETE [var:args]
	setlocal EnableDelayedExpansion
	set "array=arr"

	set "ref1=reference 1"
	%@ARRAY.DEFINE% !array! 3 ref1 "literal 1"
	echo(Array:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.

	echo(!LF!Executing:!LF!  %%@ARRAY.DELETE%% !array!
	%@ARRAY.DELETE% !array!

	echo(!LF!Result:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.
	exit /b 0
:continue
::==============================================================================




::==============================================================================
:::.%@ARRAY<dot>GET%       {var:array} {int:idx} {var}
:::
:::  Store the value at {idx} into variable [var].
:::  Supports negative indices; -1 indexes the last element.
:::
:::  --> idx = (0<idx<=size)*idx + (-size<=idx<0)*(idx+size+1)
:::  --> idx = (0<idx<size-1)*idx + (-size+1<idx<0)*(idx+size+1)
:::  --> idx = (idx*(idx-size-1)>>31&1)*idx + (idx*(idx+size+1)>>31&1)*(idx+size+1)
:::
:::  See src/examples/ex_inline_conditionals.bat for more details.
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@ARRAY.GET) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 ( %#EOL%
%========================================================================% %#EOL%
%= SECTION 2  Macro Body                                                =% %#EOL%
set "%%@.err="^&for /f "tokens=1-3 delims=[]= " %%1 in ("!%%@.args!") do ( %#EOL%
       if "%%~1"=="" (set %%@.err=1%#EOL%
) else if "%%~3"=="" (set %%@.err=1%#EOL%
) else if not defined %%~1 (set %%@.err=1%#EOL%
) else set /A "%%~1[#]+=0,%%@.idx=((%%~2+0)*((%%~2+0)-(0!%%~1[#]!)-1)>>31&1)*(%%~2+0)+((%%~2+0)*((%%~2+0)+(0!%%~1[#]!)+1)>>31&1)*((%%~2+0)+(0!%%~1[#]!)+1)"^&if !%%@.idx!==0 (set %%@.err=1%= Check idx is in valid range and wrap it to a positive number =%%#EOL%
) else for %%2 in (!%%@.idx!) do (%#EOL%
	set "%%~3=!%%~1[%%2]!"%= Set var 3 to value at 2 =%%#EOL%
)) %#EOL%
%= Cleanup local variables =% %#EOL%
set "%%@.args="%#EOL%
set "%%@.idx="%#EOL%
%= Return error if something went wrong =% %#EOL%
if defined %%@.err (set "%%@.err=" ^& call) else (call )%#EOL%
%========================================================================% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@ARRAY.GET [var:args]
	setlocal EnableDelayedExpansion
	set "array=arr"
	set "idx=2"
	set "var=out"

	set "ref1=reference 1"
	%@ARRAY.DEFINE% !array! 3 ref1 "literal 1"
	echo(Array:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.

	set "!var!="
	echo(!LF!Executing:!LF!  %%@ARRAY.GET%% !array! !idx! !var!
	%@ARRAY.GET% !array! !idx! !var!

	echo(!LF!Result:
	if defined !var! (for %%v in (!var!) do echo(  %%v=[!%%v!]) else echo   !var! is undefined.
	exit /b 0
:continue
::==============================================================================



::==============================================================================
:::.%@ARRAY<dot>SET%       {var:array} {int:idx} {var|"str"}
:::
:::  Stores a value at the specified {idx}, if {idx} already exists.
:::  Supports negative indices; -1 indexs the last element.
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@ARRAY.SET) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 ( %#EOL%
%========================================================================% %#EOL%
%= SECTION 2  Macro Body                                                =% %#EOL%
set "%%@.err="^&for /f "tokens=1-2* delims=[]= " %%1 in ("!%%@.args!") do (%#EOL%
       if "%%~1"=="" (set %%@.err=1%#EOL%
) else if "%%3"=="" (set %%@.err=1%#EOL%
) else if not defined %%~1 (set %%@.err=1%#EOL%
) else set /A "%%~1[#]+=0,%%@.idx=((%%~2+0)*((%%~2+0)-(0!%%~1[#]!)-1)>>31&1)*(%%~2+0)+((%%~2+0)*((%%~2+0)+(0!%%~1[#]!)+1)>>31&1)*((%%~2+0)+(0!%%~1[#]!)+1)"^&if !%%@.idx!==0 (set %%@.err=1%= Check idx is in valid range and wrap it to a positive number =%%#EOL%
) else for %%2 in (!%%@.idx!) do (%#EOL%
	if %%3=="%%~3" (set "%%@.val=%%~3") else set "%%@.val=!%%3!"%= Dereference unquoted value =%%#EOL%
	set "%%~1[%%2]=!%%@.val!"%= Set value at 2 to value of 3 =%%#EOL%
)) %#EOL%
%= Cleanup local variables =% %#EOL%
set "%%@.args="%#EOL%
set "%%@.idx="%#EOL%
set "%%@.val="%#EOL%
%= Return error if something went wrong =% %#EOL%
if defined %%@.err (set "%%@.err=" ^& call) else (call )%#EOL%
%========================================================================% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@ARRAY.SET [var:args]
	setlocal EnableDelayedExpansion
	set "array=arr"
	set "idx=-1"
	set "val="new value""

	set "ref1=reference 1"
	%@ARRAY.DEFINE% !array! 3 ref1 "literal 1"
	echo(Array:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.

	echo(!LF!Executing:!LF!  %%@ARRAY.SET%% !array! !idx! !val!
	%@ARRAY.SET% !array! !idx! !val!

	echo(!LF!Result:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.
	exit /b 0
:continue
::==============================================================================



::==============================================================================
:::.%@ARRAY<dot>FOREACH:$$={var:array}% ( echo %%v[%%i]=[!%%v[%%i]!] )
:::
:::  Repeats the code block ( ... ) for each element of {array}.
:::  Within ():   %%i           --> The current element index.
:::               %%v           --> The name of the array.
:::               !%%v[%%i]!    --> The current element value.
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@ARRAY.FOREACH) do 2>nul set ^"%%@=for %%v in ($$) do for /L %%i in (1,1,!%%v[#]!) do ^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="do " (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@ARRAY.FOREACH [var:args]
	setlocal EnableDelayedExpansion
	set "array=arr"

	set "ref1=reference 1"
	%@ARRAY.DEFINE% !array! 3 ref1 "literal 1"
	echo(Array:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.

	echo(!LF!Executing:!LF!  %%@ARRAY.FOREACH:$$=!array!%% ^( ... ^)
	%@ARRAY.FOREACH:$$=!array!% ( echo(  %%v[%%i]=[!%%v[%%i]!])
	echo(
	exit /b 0
:continue
::==============================================================================



::==============================================================================
:::.(%@ARRAY<dot>CONTAINS% {var:array} {var|"":idx} {var|"str":find}) && ( found ) || ( notfound )
:::
:::  Searches [array] for [find].
:::  - If found, sets ERRORLEVEL=0 and [idx]=position.
:::  - If not found, sets ERRORLEVEL=1
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@ARRAY.CONTAINS) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 ( %#EOL%
%========================================================================% %#EOL%
%= SECTION 2  Macro Body                                                =% %#EOL%
set "%%@.err="^&for /f "tokens=1-2* delims=[]= " %%1 in ("!%%@.args!") do (%#EOL%
       if "%%~1"=="" (set %%@.err=1%#EOL%
) else if "%%3"=="" (set %%@.err=1%#EOL%
) else if not defined %%~1 (set %%@.err=1%#EOL%
) else for /f "tokens=1" %%2 in ("%%~2 %%@.idx") do (%= Ensure metavariable 2 is nonempty =% %#EOL%
	if %%3=="%%~3" (set "%%@.val=%%~3") else set "%%@.val=!%%3!"%= Dereference unquoted value in metavariable 3 =%%#EOL%
	%= Search Array =% %#EOL%
	set "%%2="%#EOL%
	for /L %%i in (1,1,!%%~1[#]!) do if not defined %%2 ( %#EOL%
		if "!%%~1[%%i]!"=="!%%@.val!" set "%%2=%%i"%#EOL%
	) %#EOL%
	if not defined %%2 set %%@.err=1%#EOL%
)) %#EOL%
%= Cleanup local variables =% %#EOL%
set "%%@.args="%#EOL%
set "%%@.idx="%#EOL%
set "%%@.val="%#EOL%
%= Return error if value not found or if something else went wrong =% %#EOL%
if defined %%@.err (set "%%@.err=" ^& call) else (call )%#EOL%
%========================================================================% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@ARRAY.CONTAINS [var:args]
	setlocal EnableDelayedExpansion
	set "array=arr"
	set "idxv=idx"
	set "find1="
	set "find2=reference 1"
	set "find3=literal"

	set "ref1=reference 1"
	%@ARRAY.DEFINE% !array! 3 ref1 "literal 1"
	echo(Array:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.

	echo(!LF!Executing:!LF!  ^( %%@ARRAY.CONTAINS%% !array! !idxv! {find} ^) ...
	for %%v in (!idxv!) do for %%f in (find1 find2 find3) do (
		%@ARRAY.CONTAINS% !array! %%v %%f
	) && (
		echo(  %%f=[!%%f!] found at !array![!%%v!]
	) || (
		echo(  %%f=[!%%f!] not found in !array!
	)
	echo(
	exit /b 0
:continue
::==============================================================================



::==============================================================================
:::.%@ARRAY<dot>APPEND%    {var:array} [var|"str"] [var|"str"] ...
:::
:::  Appends new values to the end of the [array].
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@ARRAY.APPEND) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 ( %#EOL%
%========================================================================% %#EOL%
%= SECTION 2  Macro Body                                                =% %#EOL%
set "%%@.err="^&for /f "tokens=1* delims=[]= " %%1 in ("!%%@.args!") do (  %#EOL%
       if "%%~1"=="" (set %%@.err=1%#EOL%
) else if not defined %%~1 (set %%@.err=1%#EOL%
) else for %%2 in (%%2) do (%= For each value =%%#EOL%
	if %%2=="%%~2" (set "%%@.val=%%~2") else set "%%@.val=!%%2!"!%= Dereference unquoted value =% %#EOL%
	set /A "%%~1[#]+=1" %=               Increment array size            =% %#EOL%
	set "%%~1[!%%~1[#]!]=!%%@.val!" %=   Store value                     =% %#EOL%
	set "%%~1=!%%~1! %%~1[!%%~1[#]!]" %= Append element name to var list =% %#EOL%
)) %#EOL%
%= Cleanup local variables =% %#EOL%
set "%%@.args="%#EOL%
set "%%@.val="%#EOL%
%= Return error if something went wrong =% %#EOL%
if defined %%@.err (set "%%@.err=" ^& call) else (call )%#EOL%
%========================================================================% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@ARRAY.APPEND [var:args]
	setlocal EnableDelayedExpansion
	set "array=arr"
	set "vals="literal2" ref2"

	set "ref1=reference 1"
	set "ref2=reference 2"
	%@ARRAY.DEFINE% !array! 3 ref1 "literal 1"
	echo(Array:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.

	echo(!LF!Executing:!LF!  %%@ARRAY.APPEND%% !array! !vals!
	%@ARRAY.APPEND% !array! !vals!

	echo(!LF!Result:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.
	exit /b 0
:continue
::==============================================================================



::==============================================================================
:::.%@ARRAY<dot>INSERT%    {var:array} {int:idx} [var|"str"] [var|"str"] ...
:::
:::  Inserts new values at the specified {idx}.
:::  - All positions >= {idx} are shifted to higher positions to
:::    accomodate the new elements.
:::  - {idx}=size+1 is valid here, and has the same result as @ARRAY.APPEND.
:::  - Supports negative indices; -1 indexes the last element.
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@ARRAY.INSERT) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 ( %#EOL%
%========================================================================% %#EOL%
%= SECTION 2  Macro Body                                                =% %#EOL%
set "%%@.err="^&for /f "tokens=1-2* delims=[]= " %%1 in ("!%%@.args!") do (%#EOL%
       if "%%~1"=="" (set %%@.err=1%#EOL%
) else if "%%3"=="" (set %%@.err=1%#EOL%
) else if not defined %%~1 (set %%@.err=1%#EOL%
) else set /A "%%~1[#]+=0,%%@.idx=((%%~2+0)*((%%~2+0)-(0!%%~1[#]!+1)-1)>>31&1)*(%%~2+0)+((%%~2+0)*((%%~2+0)+(0!%%~1[#]!)+1)>>31&1)*((%%~2+0)+(0!%%~1[#]!)+1)"^&if !%%@.idx!==0 (set %%@.err=1%= Check idx is in valid range and wrap it to a positive number =%%#EOL%
) else for %%2 in (!%%@.idx!) do (%#EOL%
	%= Expand array to new size =% %#EOL%
	set "%%@.old=!%%~1[#]!" %#EOL%
	for %%3 in (%%3) do set /A "%%~1[#]+=1" ^& set "%%~1=!%%~1! %%~1[!%%~1[#]!]" %#EOL%
	%= Shift every position GEQ idx by the [qty] of new items =% %#EOL%
	for /L %%i in (!%%@.old!,-1,%%2) do ( %#EOL%
		set /A "%%@.idx=%%i+!%%~1[#]!-!%%@.old!" %= Calculate new position     =% %#EOL%
		set "%%~1[!%%@.idx!]=!%%~1[%%i]!" %=        Copy value to new position =% %#EOL%
	) %#EOL%
	%= Store new values starting at idx =% %#EOL%
	set "%%@.idx=%%2"^&for %%3 in (%%3) do (%#EOL%
		if %%3=="%%~3" (set "%%@.val=%%~3") else set "%%@.val=!%%3!"%= Dereference unquoted value =%%#EOL%
		set "%%~1[!%%@.idx!]=!%%@.val!"%= Set value at idx to value of 3 =%%#EOL%
		set /A "%%@.idx+=1" %#EOL%
	) %#EOL%
)) %#EOL%
%= Cleanup Local Variables =% %#EOL%
set "%%@.args="%#EOL%
set "%%@.old="%#EOL%
set "%%@.idx="%#EOL%
set "%%@.val="%#EOL%
%= Return error if something went wrong =% %#EOL%
if defined %%@.err (set "%%@.err=" ^& call) else (call )%#EOL%
%========================================================================% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@ARRAY.INSERT [var:args]
	setlocal EnableDelayedExpansion
	set "array=arr"
	set "idx=4"
	set "vals="literal2" ref2"

	set "ref1=reference 1"
	set "ref2=reference 2"
	%@ARRAY.DEFINE% !array! 3 ref1 "literal 1"
	echo(Array:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.

	echo(!LF!Executing:!LF!  %%@ARRAY.INSERT%% !array! !idx! !vals!
	%@ARRAY.INSERT% !array! !idx! !vals!

	echo(!LF!Result:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.
	exit /b 0
:continue
::==============================================================================



::==============================================================================
:::.%@ARRAY<dot>REMOVE%    {var:array} [int:idx] [int:idx] ...
:::
:::  Removes each [idx] from the array.
:::  Remaining positions are shifted down to remove gaps.
:::  Supports negative indices; -1 indexes last element.
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@ARRAY.REMOVE) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 ( %#EOL%
%========================================================================% %#EOL%
%= SECTION 2  Macro Body                                                =% %#EOL%
set "%%@.err="^&for /f "tokens=1* delims=[]= " %%1 in ("!%%@.args!") do (  %#EOL%
       if "%%~1"=="" (set %%@.err=1%#EOL%
) else if not defined %%~1 (set %%@.err=1%#EOL%
) else (%#EOL%
	%= Prepare the list of indicies to remove                           =% %#EOL%
	set "%%@.idxs=;" ^& for %%2 in (%%2) do (%#EOL%
		set /A "%%~1[#]+=0,%%@.idx=((%%~2+0)*((%%~2+0)-(0!%%~1[#]!)-1)>>31&1)*(%%~2+0)+((%%~2+0)*((%%~2+0)+(0!%%~1[#]!)+1)>>31&1)*((%%~2+0)+(0!%%~1[#]!)+1)"^&if !%%@.idx!==0 (set %%@.err=1%= Check idx is in valid range and wrap it to a positive number =%%#EOL%
		) else set "%%@.idxs=!%%@.idxs!!%%@.idx!;"%#EOL%
	) %#EOL%
	%= Rebuild array without the items at these positions               =% %#EOL%
	set "%%~1=%%~1 %%~1[#]" %=                    Init var list         =% %#EOL%
	set /A "%%@.oldsize=!%%~1[#]!,%%~1[#]=0" %=   Init array size       =% %#EOL%
	for /L %%i in (1,1,!%%@.oldsize!) do ( %#EOL%
		if "!%%@.idxs:;%%i;=!"=="!%%@.idxs!" ( %= Keep this index       =% %#EOL%
			set /A "%%~1[#]+=1" %=                Increment array size  =% %#EOL%
			set "%%~1=!%%~1! %%~1[!%%~1[#]!]" %=  Append name to varlist=% %#EOL%
			set "%%~1[!%%~1[#]!]=!%%~1[%%i]!" %=  Store value           =% %#EOL%
		) %#EOL%
	) %#EOL%
	%= Clear leftover values from the end of the old array              =% %#EOL%
	set /A "%%@.idx=!%%~1[#]!+1" %#EOL%
	for /L %%i in (!%%@.idx!,1,!%%@.oldsize!) do set "%%~1[%%i]=" %#EOL%
)) %#EOL%
%= Cleanup Local Variables =% %#EOL%
set "%%@.args="%#EOL%
set "%%@.oldsize="%#EOL%
set "%%@.idxs="%#EOL%
set "%%@.idx="%#EOL%
%= Return error if something went wrong =% %#EOL%
if defined %%@.err (set "%%@.err=" ^& call) else (call )%#EOL%
%========================================================================% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@ARRAY.REMOVE [var:args]
	setlocal EnableDelayedExpansion
	set "array=arr"
	set "idxs=-1"

	set "ref1=reference 1"
	set "ref2=reference 2"
	%@ARRAY.DEFINE% !array! 3 ref1 "literal 1"
	echo(Array:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.

	echo(!LF!Executing:!LF!  %%@ARRAY.REMOVE%% !array! !idxs!
	%@ARRAY.REMOVE% !array! !idxs!

	echo(!LF!Result:
	if defined !array! (for %%a in (!array!) do for %%v in (!%%a!) do echo(  %%v=[!%%v!]) else echo   !array! is undefined.
	exit /b 0
:continue
::==============================================================================





::==============================================================================
:::.%@STRING<dot>CONCAT%   {var:out} {var|"str":sep} {/keepempty|""} [var|"str"] [var|"str"] ...
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@STRING.CONCAT) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 ( %#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 2  Macro Body                                                -% %#EOL%
set "%%@.err="^&for /f "tokens=1-3* delims=	 " %%1 in ("!%%@.args!") do (%#EOL%
       if "%%~1"=="" (set %%@.err=1%#EOL%
) else if "%%2"=="" (set %%@.err=1%#EOL%
) else ( %#EOL%
	if %%2=="%%~2" (set "%%@.sep=%%~2") else set "%%@.sep=!%%2!"%= Dereference unquoted value =% %#EOL%
	set "%%@.out=" %#EOL%
	for %%4 in (%%4) do (%= Construct output string=% %#EOL%
		if %%4=="%%~4" (set "%%@.val=%%~4") else set "%%@.val=!%%4!"%= Dereference unquoted value =%%#EOL%
		if not "%%~3"=="" (       if defined %%@.out (set "%%@.out=!%%@.out!!%%@.sep!!%%@.val!") else set "%%@.out=!%%@.val!" %= /keepempty              =% %#EOL%
		) else if defined %%@.val if defined %%@.out (set "%%@.out=!%%@.out!!%%@.sep!!%%@.val!") else set "%%@.out=!%%@.val!" %= keep nonempty (default) =% %#EOL%
	) %#EOL%
	set "%%~1=!%%@.out!" %= Store value =% %#EOL%
)) %#EOL%
%= Cleanup local variables =% %#EOL%
set "%%@.args="%#EOL%
set "%%@.out="%#EOL%
set "%%@.sep="%#EOL%
set "%%@.val="%#EOL%
%= Return error if something went wrong =% %#EOL%
if defined %%@.err (set "%%@.err=" ^& call) else (call )%#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@STRING.CONCAT [var:args]
	setlocal EnableDelayedExpansion
	set "out="
	set "sep=<>"
	set "vals=var1 "value 2" "" var2"
		set "var1=value 1"
		set "var2=value 3"

	echo(Executing:!LF!  %%@STRING.CONCAT%% out "!sep!" /keepempty !vals!
	%@STRING.CONCAT% out "!sep!" /keepempty !vals!
	echo(

	echo(Result:
	for %%v in (out) do if defined %%v (echo(  %%v=[!%%v!]) else echo(  %%v is undefined.
	exit /b 0
:continue
::==============================================================================





::==============================================================================
:::.%@STRING<dot>SPLIT%    {var:in} {var:out} {var|"str":sep}
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@STRING.SPLIT) do 2>nul set ^"%%@=for %%# in (1 2) do if %%#==2 ( %#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 2  Macro Body                                                -% %#EOL%
set "%%@.err="^&for /f "tokens=1-2*" %%1 in ("!%%@.args!") do (%#EOL%
	       if "%%~1"=="" (set %%@.err=1%#EOL%
	) else if "%%~2"=="" (set %%@.err=1%#EOL%
	) else if "%%3"=="" (set %%@.err=1%#EOL%
	) else if not defined %%~1 (set "%%~2="%#EOL%
	) else for %%L in (^^^"%##LF%^^^") do (%#EOL%
		if %%3=="%%~3" (set "%%@.sep=%%~3") else set "%%@.sep=!%%3!"%= Dereference unquoted value =% %#EOL%
		set "%%~2=!%%~1:#=#p!"    ^& if defined %%@.sep set "%%@.sep:#=#p"%#EOL%
		set "%%~2=!%%~2:%%~L=#l!" ^& if defined %%@.sep set "%%@.sep:%%~L=#l"%#EOL%
		for /f tokens^^=*^^ delims^^=^^ eol^^= %%s in ("!%%@.sep!") do set "%%~2=!%%~2:%%~s=%%~L!"!%= Split happens here =%%#EOL%
		set "%%~2=!%%~2:#l=%%~L!"%#EOL%
		set "%%~2=!%%~2:#p=#!"%#EOL%
	)%#EOL%
) %#EOL%
%= Cleanup local variables =% %#EOL%
set "%%@.args="%#EOL%
set "%%@.sep="%#EOL%
%= Return error if something went wrong =% %#EOL%
if defined %%@.err (set "%%@.err=" ^& call) else (call )%#EOL%
%------------------------------------------------------------------------% %#EOL%
%- SECTION 1  Collect Macro Arguments               -% ) else set %%@.args=!=!^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-3!"=="^!=^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@STRING.SPLIT [var:args]
	setlocal EnableDelayedExpansion
	set @STRING.SPLIT
	set "str=this is a string"
	set "sep=i"

	echo(Input:
	for %%v in (str) do if defined %%v (echo(  %%v=[!%%v!]) else echo(  %%v is undefined.
	echo(

	echo(Executing:!LF!  %%@STRING.SPLIT%% str str "!sep!"
	%@STRING.SPLIT% str str "!sep!"
	echo(

	echo(Result:
	for %%v in (str) do if defined %%v (echo(  %%v=[!%%v!]) else echo(  %%v is undefined.
	exit /b 0
:continue
::==============================================================================





::==============================================================================
:::.%@STRING<dot>LOWER:$$=var%                                      (Embeddable)
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@STRING.LOWER) do 2>nul set ^"%%@=for %%v in ($$) do if defined %%v for %%c in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "%%v=!%%v:%%c=%%c!"^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-2,-1!"=="^!" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@STRING.LOWER [var:args]
	setlocal EnableDelayedExpansion
	set "str=thIs IS A StrinG"

	echo(Input:
	for %%v in (str) do if defined %%v (echo(  %%v=[!%%v!]) else echo(  %%v is undefined.
	echo(

	echo(Executing:!LF!  %%@STRING.LOWER:$$=str%%
	%@STRING.LOWER:$$=str%
	echo(

	echo(Result:
	for %%v in (str) do if defined %%v (echo(  %%v=[!%%v!]) else echo(  %%v is undefined.
	exit /b 0
:continue




::==============================================================================
:::.%@#STRING<dot>LENGTH:$$={var:in},{var:out}%                     (Embeddable)
:::.%@STRING<dot>LENGTH:$$={var:in},{var:out}%
:::
:::  Based on: https://ss64.org/viewtopic.php?f=2&t=17
:::
::-------- BEGIN MACRO DEFINITION ----------------------------------------------
for %%@ in (@#STRING.LENGTH) do 2>nul set ^"%%@=for /f "tokens=1-2 delims=, " %%1 in ("$$") do (%##EOL%
	set "%%@.tmp=_!%%~1!"^^^&set "%%~2=0"%##EOL%
	for %%n in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do if not "!%%@.tmp:~%%n,1!"=="" (%##EOL%
		set /A "%%~2+=%%n"%##EOL%
		set "%%@.tmp=!%%@.tmp:~%%n!"%##EOL%
	)%##EOL%
	set "%%@.tmp="%##EOL%
)^"^
&& (setlocal EnableDelayedExpansion & if not "!%%@:~-1!"==")" (endlocal&call) else endlocal) || (1>&2 echo(ERROR: Invalid macro definition in %~nx0.& exit /b 1)
set ^"@STRING.LENGTH=%@#STRING.LENGTH%"
::-------- END MACRO DEFINITION ------------------------------------------------
goto :continue
:.autotest.@STRING.LENGTH [var:args]
	setlocal EnableDelayedExpansion
	set "in=EighteenCharacters"
	set "out="

	echo(Input:
	for %%v in (in out) do if defined %%v (echo(  %%v=[!%%v!]) else echo(  %%v is undefined.
	echo(

	echo(Executing:!LF!  %%@STRING.LENGTH:$$=in,out%%
	%@STRING.LENGTH:$$=in,out%
	echo(

	echo(Result:
	for %%v in (in out) do if defined %%v (echo(  %%v=[!%%v!]) else echo(  %%v is undefined.
	exit /b 0
:continue




set "IMPORTS=%IMPORTS% %~n0"
exit /b 0
%======================  END .autogoto.import  ======================%  goto :EOF



%====================================================================%  goto :EOF
:.autogoto.list [keyword]      Lists available macros.
setlocal DisableDelayedExpansion
set "file=%~f0"
set "find=%~2"
echo(---------------------------------------------------------------------------
echo For more info on a particular definition, use:
echo   %~nx0 /? [macro]
echo.
echo Available macros:    Arguments:
echo(---------------------------------------------------------------------------
setlocal EnableDelayedExpansion
if defined find set "find=!find:@=!"
for /F tokens^=^*^ delims^=:.^ eol^= %%l in ('findstr /RIC:"^:::\..*%%@.*!find!.*%%" "!file!"') do (
	endlocal
	set "line=%%l"
	setlocal EnableDelayedExpansion
	set "line=!line:<basename>=%~nx0!"
	set "line=!line:<basename_no_ext>=%~n0!"
	set "line=!line:<dot>=.!"
	set "line=!line:<pct>=%%!"
	set "line=!line:<tab>=	!"
	echo(  !line!
)
endlocal
echo.
exit /b 0
%========================  END .autogoto.list =======================%  goto :EOF



%====================================================================%  goto :EOF
:.autogoto.? [macro]           Prints detailed documentation.
setlocal DisableDelayedExpansion
set "file=%~f0"
set "find=%~2"
set "manbat=" & for %%a in ("man.bat") do set "manbat=%%~$PATH:a"
setlocal EnableDelayedExpansion
if "!find!"=="" goto :info.general
if not "!find:@=!"=="!find!" if "!find:.=!"=="!find!" (goto :info.category) else goto :info.macro
goto :info.macro
:info.general
	call "!file!" print/usage
	if defined manbat call "!manbat!" "!file!" "/inc:{head} /inc:{general}" "/inc:{head} /inc:{category} /exc:{detail}"
	exit /b 1
:info.category
	if defined manbat call "!manbat!" "!file!" "/inc:{head} /inc:{category} /inc:!find!"
	call "!file!" /list "!find!"
	exit /b 1
:info.macro
	if defined manbat call "!manbat!" "!file!" "/exc:{head} /exc:autogoto /exc:autotest /inc:@ /inc:!find:@=!"
	exit /b 1
%=========================  END .autogoto.?  ========================%  goto :EOF



%====================================================================%  goto :EOF
:.autogoto.test name [args]    Runs built-in unit tests.
setlocal DisableDelayedExpansion
set "div==================================================="
set "file=%~f0"
set "n0=%~n0"
set "nx0=%~nx0"
set "tests=%~2"
set ^"args=%3 %4 %5 %6 %7 %8 %9^"
if defined tests (set "quiet=") else set "quiet=>nul"
if defined tests (set "printdef=echo(!div!!LF!%%T=!%%T!!LF!!div!") else set "printdef="

:: Import macro definitions from this file
call "%file%" /import || (2>&1 echo One or more macros failed to import.& exit /b 1)
setlocal EnableDelayedExpansion

:: Scan this file for autotest labels
if not defined tests (
	echo !div!!LF!!nx0!: Scanning for tests...
	for /f "tokens=1" %%l in ('findstr /BLIC:":.autotest." "!file!"') do (
		set "label=%%l" & echo   Found label: [!label!]
		set "tests=!tests! !label::.autotest.=!"
	)
)

:: Run tests
echo !LF!!nx0!: Running tests...
set /A "num_tests=0,num_success=0"
for %%T in (!tests!) do (
	%printdef%
	set /A "num_tests+=1"
	%quiet% echo !LF!---^> Test !num_tests! ^(%%T^):
	%quiet% call :.autotest.%%T args && (
		set /A "num_success+=1"
		%quiet% echo !div!!LF!
		        echo ---^> Test !num_tests!%tab%%%T%tab%%tab%SUCCESS
	) || (
		%quiet% echo !div!!LF!
		        echo ---^> Test !num_tests!%tab%%%T%tab%%tab%FAILED
	)
)

:: Print results
echo !LF!!div!!LF!!nx0!: !num_success!/!num_tests! tests passed.!LF!
if "!num_tests!"=="!num_success!" (exit /b 0) else exit /b 1
%=======================  END .autogoto.test  =======================%  goto :EOF



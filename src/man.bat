::==============================================================================
:::.Usage:
:::   <basename> {"path\to\file"} ["sectiontitle1"] ["sectiontitle2"] ...
:::
:::      Displays help text embedded within the file.
:::
:::      ["sectiontitle"]    Only print comments belonging to this section.
:::                          Can exclude sections by prefixing with "/exc:".
:::
:::   <basename> /?
:::
:::      Shows this help message.
:::
:::   <basename> /test [/debug]
:::
:::      Runs built-in tests of this script.
:::
:::..Examples:
:::
:::   <basename> "<basename>" usage test
:::     Prints all sections whos titles contain "usage" or "test".
:::
:::   <basename> "<basename>" usage "test /exc:3"
:::     Prints all sections whos titles contain "usage" or ("test" and not "3").
:::
@echo off
setlocal DisableDelayedExpansion

::==============================================================================
:: Special characters, global definitions
::
set "ERRORLEVEL="
set ^"LF=^
%= EMPTY LINE =%
^"
set    ^"#LF=^^^%LF%%LF%^%LF%%LF%^"
set   ^"#EOL=^^^%LF%%LF%^"          %= User provides the missing LF when expanding this at the end of a macro line =%
set   ^"##LF=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set  ^"##EOL=^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"
set  ^"###LF=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^"
set ^"###EOL=^^^^^^^^^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^%LF%%LF%^^^^^^^%LF%%LF%^%LF%%LF%^^^%LF%%LF%^"

((for /L %%A in (1,1,70) do pause>nul) & set /p "TAB=")<"%COMSPEC%"
set "TAB=%TAB:~0,1%"
set "ws=%TAB% "

set "TRUE=true"
set "FALSE=false"

:: Run this script with flag "/debug" to print extra info
set "DEBUG=%false%"

:: Function to call on errors
set "ERROR_HOOK=exit_on_error"

:: Begin main routine
goto :start
exit /b 1 %= Should not get here=%


::==============================================================================
:::.handler.Supported file types:
:::
:.handler.cmd  file_var  args_var
:.handler.bat  file_var  args_var
    setlocal DisableDelayedExpansion
    set "file_var=%~1"
    set "args_var=%~2"

    :: Regex strings which match comment lines (used in findstr)
    set ^"LINE_MATCHES=         %#EOL%
        "^[%ws%]*:::"           %#EOL%
        "^[%ws%]*:\."           %#EOL%
        "^[%ws%]*rem"           %#EOL%
    "
    :: Strings to remove from the start of each comment line
    set ^"COMMENT_MARKERS=      %#EOL%
        "rem "                  %#EOL%
        ":"                     %#EOL%
    "

    :: String which denotes the start of a new comment section
    set ^"SECTION_MARKERS=      %#EOL%
        "."                     %#EOL%
    "

    :: Read the file and print its comments
    call :.print_comments                   ^
        file_path=%file_var%                ^
        line_matches=LINE_MATCHES           ^
        comment_markers=COMMENT_MARKERS     ^
        section_markers=SECTION_MARKERS     ^
        section_filters=%args_var%

    exit /b 0


:.handler.exe  file_var  args_var
    setlocal EnableDelayedExpansion
    set "file_var=%~1"
    set "args_var=%~2"
    set "cmd_args=!%args_var%!"
    if defined cmd_args ( set "cmd_args=/?"
    ) else set ^"cmd_args=!cmd_args:%#LF%= !"

    cmd /d /c "!%file_var%!" !cmd_args!

    exit /b 0



::==============================================================================
:start
::
::  Main routine
::

:: Split %* into args
set ^"args=%*"
if "%~1"=="" set ^"args="%~f0" "Usage"^"
call :Args.split args args "^"

:: Get FILE and process any recognized flags.
setlocal EnableDelayedExpansion
set "file="
set "args.unprocessed="
for /F delims^=^ eol^= %%A in ("!args!") do (
    set "uarg=%%~A"!
    set "arg=%%A"!
    if defined arg (
               if /i "!arg!"=="/debug" (     set "DEBUG=%true%" & set "arg="
        ) else if /i "!arg!"=="--debug" (    set "DEBUG=%true%" & set "arg="
        ) else if not defined file (
                   if /i "!arg!"=="/?" (     set "file=%~f0" & set "arg=Usage"
            ) else if /i "!arg!"=="/help" (  set "file=%~f0" & set "arg=Usage"
            ) else if /i "!arg!"=="--help" ( set "file=%~f0" & set "arg=Usage"
            ) else if /i "!arg!"=="/test" (  set "file=%~f0" & set "arg=test"
            ) else if /i "!arg!"=="--test" ( set "file=%~f0" & set "arg=test"
            ) else                           set "file=!uarg!" & set "arg="
        )
    )
    if defined arg set ^"args.unprocessed=!args.unprocessed!!LF!!arg!"
) & set "arg=" & set "uarg="


:: Get file's full path and extension
call :File.getFilePath file file.f || call :throw "File not found: ""^^!file^^!"""
for %%F in ("!file.f!") do set "file.x=%%~xF"


:: Debug Print
if /i "%DEBUG%"=="%true%" ( setlocal EnableDelayedExpansion
    cls
    echo(
    echo(===============================================================
    setlocal DisableDelayedExpansion & echo(   %~nx0 %* & endlocal
    echo(===============================================================
    for %%V in (args args.unprocessed file.f file.x) do echo(  %%V=[!%%V!]
    echo(
endlocal)


:: Run file type handler
call :.handler%file.x% file.f args.unprocessed 2>nul || call :throw "No handler defined for filetype: ""^^!file.x^^!"""
exit /b 0



::==============================================================================
:.print_comments {file_path=...} [line_matches=...] [comment_markers=...] [section_markers=...] [section_filters=...]
:::
:::  Prints the line comments in a file, optionally applying filters.
:::  Arguments can be specified as UNQUOTED_VARIABLE_NAME or "quoted string value".
:::
:::    file_path             Path to file.
:::    [line_matches]        Regex strings to match lines using findstr
:::    [comment_markers]     Sequences which identify the start of a comment line.
:::    [section_markers]     Sequences which identify the start of a new section.
:::    [section_filters]     Print only comments belonging to these sections.
:::
:::..DETAIL.Procedure:
:::
:::    1. findstr.exe filters only the lines matching a regex in LINE_MATCHES.
:::    2. COMMENT_MARKERS are trimmed from the beginning of each line.
:::    3. Line is parsed for section/subsection markers.
:::    4. SECTION_FILTERS are applied. Only lines which are part of a matching section are printed.
:::    5. In-line substitutions are applied according to BODY_SUBST_MAP. See source for valid substitutions.
:::
:::..DETAIL.Detail:
:::
:::  'findstr' returns each comment line formatted as:
:::
:::  <<line>> = <<linenum>><<colon>><<ws>><<start>><<comment>>
:::
:::     <<linenum>>  Line number
:::     <<colon>>    Colon character
:::     <<ws>>       0 or more whitespace (tabs or spaces)
:::     <<start>>    String marking start of comment.
:::     <<comment>>  Remainder of line after <<start>> marker.
:::
:::
:::  <<comment>> is either a section header or a plain body text.
:::  Section headers are composed of one or more subtitles.
:::
:::    if <<comment>> == <<ws>><<------------head-------------->><<ws>><<desc>>
:::           <<head>> =     <<mark>><<title>>...<<mark>><<subtitle>>
:::           <<tail>> =                                     <<ws>><<desc>>
:::           <<body>> =                           <<subtitle>><<ws>><<desc>>
:::    else
:::           <<head>> =
:::           <<tail>> =
:::           <<body>> = <<comment>>
:::
:::    <<body>>      Text that is actually displayed.
:::    <<desc>>      (Optional) Section description.
:::    <<mark>>      String indicating start of section/subsection title.
:::    <<title>>     (Optional) Title of outermost section.
:::    <<subtitle>>  (Optional) Title of innermost section.
:::
:::
:::  <<section>> is a string built by filling in missing <<subtitle>> in <<head>>, where possible.
:::    If <<title>> or <<subtitle>> is missing (only <<mark>> is present),
:::      they are carried from the previous section.
:::    <<section>> is carried from previous comment lines, but a non-comment line clears <<section>>.
:::
:::
:::  <<mark>> undefined implies <<head>>, <<tail>>, <<desc>>, <<title>>, <<subtitle>>, <<section>> undefined.
:::
:::
:::  SECTION_FILTERS are applied against <<section>>.
:::

setlocal DisableDelayedExpansion

:: Get function arguments
set "_args=%*"
set ^"_valid_args=file_path line_matches comment_markers section_markers section_filters     ^
                  section_filter_inclusion_marker section_filter_exclusion_marker           "
set "_required_args=file_path"
call :Args.parse_pairs.DDE _args "%_valid_args%" "%_required_args%" _errmsg || call :throw "[%0] !_errmsg!"

if not defined FILE_PATH                        call :throw "Should've been caught already"
if not exist "%FILE_PATH%"                      call :throw "File not found: ""%FILE_PATH%"""
    setlocal EnableDelayedExpansion
    for %%A in ("!FILE_PATH!") do ( endlocal
        set "FILE=%%~A"
        set "FILE.f=%%~fA"
        set "FILE.nx=%%~nxA"
        set "FILE.n=%%~nA"
        set "FILE.x=%%~xA"
    )
if not defined LINE_MATCHES                     set "LINE_MATCHES=.*"
call :Args.split LINE_MATCHES "" "^"
if not defined COMMENT_MARKERS                  set "COMMENT_MARKERS="
call :Args.split COMMENT_MARKERS "" "^"
if not defined SECTION_MARKERS                  set "SECTION_MARKERS="
call :Args.split SECTION_MARKERS "" "^"
if not defined SECTION_FILTER_INCLUSION_MARKER  set "SECTION_FILTER_INCLUSION_MARKER=/inc:"
if not defined SECTION_FILTER_EXCLUSION_MARKER  set "SECTION_FILTER_EXCLUSION_MARKER=/exc:"
if not defined SECTION_FILTERS                  set "SECTION_FILTERS=%SECTION_FILTER_INCLUSION_MARKER%"
call :Args.split SECTION_FILTERS "" "^"


:: Substitution maps
:: STR=REP
::  Characters disallowed on both sides: !
::  Characters disallowed only on left-hand side: * = ~
set ^"SUBS.ESCAPE=%#EOL%
    "<<=<<\"                    %= Allows user to escape '<' and '>'    =%%#EOL%
    ">>=\>>"                    %=   with '<<' and '>>'                 =%%#EOL%
    "%TAB%=<tab>"               %= Tab sometimes causes problems        =%%#EOL%
    "<start>=<<\start\>>"       %= Automatically escape reserved tags   =%%#EOL%
    "<mark>=<<\mark\>>"         %=                                      =%%#EOL%
    "<null>=<<\null\>>"         %=                                      =%%#EOL%
    "</>=<<\/\>>"               %=                                      =%%#EOL%
"
call :Args.split SUBS.ESCAPE "" "^" #LF


set "SUBS.TRIM_COMMENT="
setlocal EnableDelayedExpansion & for /F delims^=^ eol^= %%M in ("!COMMENT_MARKERS!") do set ^"SUBS.TRIM_COMMENT=!SUBS.TRIM_COMMENT!^^%##EOL%
    "%%~M=<start>%%~M</>"       %= Mark before and after each comment marker =% !^^^
"
endlocal & set ^"SUBS.TRIM_COMMENT=%SUBS.TRIM_COMMENT%%#EOL%
    "</><start>="               %= Group adjacent start markers         =%%#EOL%
    "*</>="                     %= Remove up to and including first group of start markers =%%#EOL%
    "<start>="                  %= Cleanup                              =%%#EOL%
    "</>="                      %=                                      =%%#EOL%
"
call :Args.split SUBS.TRIM_COMMENT "" "^" #LF


set "SUBS.MARK_SECTIONS="
setlocal EnableDelayedExpansion & for /F delims^=^ eol^= %%M in ("!SECTION_MARKERS!") do set ^"SUBS.MARK_SECTIONS=!SUBS.MARK_SECTIONS!^^%##EOL%
    "%%~M=<mark>%%~M</>"        %= Mark before and after each section marker =% !^^^
"
endlocal & set ^"SUBS.MARK_SECTIONS=%SUBS.MARK_SECTIONS%%#EOL%
    "</><mark>=</><null><mark>" %= <null> between adjacent <mark>s      =%%#EOL%
    "</> =</><null> "           %= <null> after final empty <mark>s     =%%#EOL%
"
call :Args.split SUBS.MARK_SECTIONS "" "^" #LF


set ^"SUBS.DYNAMIC=%#EOL%
    "<subtitle>=!subtitle!"     %= Tags which expand to a variable      =%%#EOL%
    "<title>=!title!"           %=                                      =%%#EOL%
    "<linenum>=!linenum!"       %=                                      =%%#EOL%
    "<section>=!section!"       %=                                      =%%#EOL%
    "<fullpath>=!FILE.f!"       %=                                      =%%#EOL%
    "<basename>=!FILE.nx!"      %=                                      =%%#EOL%
    "<basename_no_ext>=!FILE.n!"%=                                      =%%#EOL%
    "<fileext>=!FILE.x!"        %=                                      =%%#EOL%
"
call :Args.split SUBS.DYNAMIC "" "" #LF


set ^"SUBS.CLEANUP=%#EOL%
    "</>="                      %= Cleanup reserved tags                =%%#EOL%
    "<null>="                   %=                                      =%%#EOL%
    "<mark>="                   %=                                      =%%#EOL%
    "<pct>=%%"                  %= Unescape special characters          =%%#EOL%
    "<sp>= "                    %=                                      =%%#EOL%
    "<tab>=%TAB%"               %=                                      =%%#EOL%
    "\>>=>"                     %= Unescape '<' and '>'                 =%%#EOL%
    "<<\=<"                     %=                                      =%%#EOL%
"
call :Args.split SUBS.CLEANUP "" "^" #LF


setlocal EnableDelayedExpansion

:: Use LINE_MATCHES to create a space-separated list of FINDSTR flags
set "FINDSTR_FLAGS=/N /I /R"
for /F delims^=^ eol^= %%T in ("!LINE_MATCHES!") do (
    set "tok=%%~T"!
    if defined tok (
        set ^"tok=!tok:""=\"!"
        set "FINDSTR_FLAGS=!FINDSTR_FLAGS! /C:"!tok!""
    )
)


:: Split SECTION_FILTERS into SECTION_FILTER_SETS.
::   Remove SECTION_FILTER_INCLUSION_MARKER before each filter
::   Remove SECTION_FILTER_EXCLUSION_MARKER before each filter and place quotes around exclusion filters
:: call :Args.split SECTION_FILTERS _tmp 1 & set "SECTION_FILTER_SETS="
for /F delims^=^ eol^= %%S in ("!SECTION_FILTERS!") do (
    set "filter_set=%%~S"!
    if defined filter_set (
        set ^"filter_set=!filter_set:""="!"
        call :Args.split filter_set
        for /F delims^=^ eol^= %%F in ("!filter_set!") do (
            set ^"filter=%%F"!
            if defined SECTION_FILTER_INCLUSION_MARKER if "!filter!"=="%SECTION_FILTER_INCLUSION_MARKER%!filter:*%SECTION_FILTER_INCLUSION_MARKER%=!" ( %= Filter starts with inclusion marker =%
                set "filter=!filter:*%SECTION_FILTER_INCLUSION_MARKER%=!"
            ) else if defined SECTION_FILTER_EXCLUSION_MARKER if "!filter!"=="%SECTION_FILTER_EXCLUSION_MARKER%!filter:*%SECTION_FILTER_EXCLUSION_MARKER%=!" ( %= Filter starts with exclusion marker =%
                set ^"filter="!filter:*%SECTION_FILTER_EXCLUSION_MARKER%=!"^"
            )
            set "SECTION_FILTER_SETS=!SECTION_FILTER_SETS! !filter!"
        )
        set "SECTION_FILTER_SETS=!SECTION_FILTER_SETS!!LF!"
    )
)


:: Debug
if /i "%DEBUG%"=="%true%" ( setlocal EnableDelayedExpansion
    echo(
    echo(===============================================================
    setlocal DisableDelayedExpansion & echo(   %0 %* & endlocal
    echo(===============================================================
    echo(Properties:
    for %%V in (LINE_MATCHES FINDSTR_FLAGS SECTION_FILTERS SECTION_FILTER_SETS SUBS.ESCAPE SUBS.TRIM_COMMENT SUBS.MARK_SECTIONS SUBS.DYNAMIC SUBS.CLEANUP) do echo(%%V=[!%%V!]!LF!
    echo(
    echo(===============================================================
    echo(Printing comments in file:
    echo(  !FILE!
    echo(===============================================================
    echo(
    endlocal
) else (
    echo(
)


:: For each comment line...
set "linenum="
set "section="
set "title="
set "subtitle="
set "section_filter_match="
for %%L in ("!LF!") do for /F usebackq^ tokens^=^*^ delims^=^ eol^= %%C in (`findstr !FINDSTR_FLAGS! "!FILE!"`) do (

    %=                                                                      =%
    %= Get <line>                                                           =%
    %=  <line> = <linenum><colon><ws><start><comment>                       =%
    %=                                                                      =%
    setlocal DisableDelayedExpansion
    set ^"line=%%C "
    setlocal EnableDelayedExpansion


    %=                                                                      =%
    %= Get <linenum>                                                        =%
    %=                                                                      =%
    for /F "tokens=1 delims=:" %%N in ("!line!") do (
        set /A "linegap=%%N-linenum"
        set /A "linenum=%%N"
    )


    %=                                                                      =%
    %= Detect section breaks                                                =%
    %=                                                                      =%
    if !linegap! GTR 1 (
        set "section="
        set "title="
        set "subtitle="
        set "section_filter_match="
    )


    %=                                                                      =%
    %= Get <comment>                                                        =%
    %=   Remove <linenum><colon>                                            =%
    %=   Apply SUBS.ESCAPE                                          =%
    %=   Apply SUBS.TRIM_COMMENT                                  =%
    %=   Apply SUBS.MARK_SECTIONS                                           =%
    %=                                                                      =%
    set "comment=!line:*:=!"
    for /F delims^=^ eol^= %%S in (^"%SUBS.ESCAPE%%#LF%%SUBS.TRIM_COMMENT%%#LF%%SUBS.MARK_SECTIONS%^") do if defined comment set "comment=!comment:%%~S!"


    %=                                                                      =%
    %= Get <head> and <tail>                                                =%
    %=   if <comment> == <ws><------------head--------------><ws><desc>     =%
    %=          <head> =     <mark><title>...<mark><subtitle>               =%
    %=          <tail> =                                     <ws><desc>     =%
    %=   else                                                               =%
    %=          <head> =                                                    =%
    %=          <tail> =                                                    =%
    %=                                                                      =%
    set "head=" & set "tail="
    if defined comment (
        set "_tmp=!comment: =!"
        if "!_tmp!"=="<mark>!_tmp:*<mark>=!" ( %= Comment starts with <ws><mark> =%
            for /F "tokens=1 eol=  delims= " %%H in ("!comment!") do (
                set ^"head=%%H"!
                set ^"tail=!comment:*%%H=!"!
            )
        )
    )


    %=                                                                      =%
    %= Get <section>, <title>, <subtitle>                                   =%
    %=   <head> defined  implies-->  <mark> defined                         =%
    %=                                                                      =%
    if defined head (
        set "old_section=" & if defined section set "old_section=!section:<mark>=%%~L!!LF!"
        set "section="
        set "title="
        set "subtitle="

        %= Loop over all tok=<mark>.</><subtitle> in <head> =%
        for /F delims^=^ eol^= %%H in ("!head:<mark>=%%~L!") do (
            if defined old_section set "old_section=!old_section:*%%~L=!"   %= Consume one token from front of old_section. =%
            set ^"tok=%%H"!
            if "!tok:*</>=!"=="<null>" ( %= Current subtitle == <null>. Replace tok with first token in old_section. =%
                if defined old_section set "tok=" & for /F delims^=^ eol^= %%S in ("!old_section!") do if not defined tok set ^"tok=%%S"!
            ) else set "old_section="    %= Current subtitle not <null>. Keep tok and CLEAR old_section. =%
            set "subtitle=!tok:*</>=!"                      %= Set <subtitle> every iteration. Remove leading <mark>.<\> =%
            if not defined section set "title=!subtitle!"   %= Set <title> on first iteration only =%
            set "section=!section!<mark>!tok!"              %= Append new token to end of new <section>. =%
        )
    )


    %=                                                                      =%
    %= Get <body>:                                                          =%
    %=   if <comment> == <ws><-----head-----><ws><desc>                     =%
    %=          <body> =           <subtitle><ws><desc>                     =%
    %=   else                                                               =%
    %=          <body> = <comment>                                          =%
    %=                                                                      =%
    %=   Apply SUBS.DYNAMIC                                                 =%
    %=   Apply SUBS.CLEANUP                                                 =%
    %=                                                                      =%
    if defined head (
        set "body=!subtitle!!tail!"
    ) else set "body=!comment!"
    for /F delims^=^ eol^= %%S in (^"%SUBS.DYNAMIC%%#LF%%SUBS.CLEANUP%^") do if defined body set "body=!body:%%~S!"


    %=                                                                      =%
    %= Get section_filter_match (process SECTION_FILTER_SETS)               =%
    %=   Only reevaluate when <comment> contains <head>                     =%
    %=   Empty SECTION_FILTER_SETS matches every <section>                  =%
    %=   <head> defined  implies-->  <section> defined                      =%
    %=                                                                      =%
    if defined head if defined SECTION_FILTER_SETS (
        set "section_filter_match="

        %= Process substitutions in <section> =%
        set "section_=!section!"
        for /F delims^=^ eol^= %%S in (^"%SUBS.DYNAMIC%%#LF%%SUBS.CLEANUP%^") do if defined section_ set "section_=!section_:%%~S!"

        %= section_ must match ANY filter_set =%
        for /F delims^=^ eol^= %%S in ("!SECTION_FILTER_SETS!") do if not defined section_filter_match ( %= Define section_filter_match to break loop =%
            %= section_ must match ALL filters within this individual filter_set =%
            set ^"filter_set=%%S"!
            if defined filter_set for /F delims^=^ eol^= %%F in ("!filter_set: =%%~L!") do if defined filter_set ( %= Undefine filter_set to break loop =%
                set ^"filter=%%F"!
                if defined filter if "!filter:~0,1!!filter:~-1,1!"=="""" (                  %= EXCLUDE FILTER =%
                    %= If section_ contains this filter, fail this filter_set. =%
                    if not "!section_!"=="!section_:%%~F=!" set "filter_set="
                ) else (                                                                    %= INCLUDE FILTER =%
                    %= If section_ doesn't contain this filter, fail this filter_set. =%
                    if "!section_!"=="!section_:%%F=!" set "filter_set="
                )
            )
            %= If filter_set is still defined, all its filters were matched successfully. =%
            if defined filter_set set "section_filter_match=!filter_set!"
        )
    ) else ( %= no filters defined =%
        set "section_filter_match="
    )


    %=                                                                      =%
    %= Print                                                                =%
    %=                                                                      =%
    if /i "%DEBUG%"=="%true%" (
        if defined head if defined section_filter_match (
            echo(
            echo(===============================================================
            echo(!linenum!:%TAB%Section: !section!%TAB%    ^(Matched: !section_filter_match!^)
            echo(===============================================================
            for %%V in (comment head title subtitle section_filter_match) do echo(  ^<%%V^>=[!%%V!]
            echo(
        ) else (
            echo(!linenum!:%TAB%Skipped header:  !section!
        )
        if defined section_filter_match (
            echo(!linenum!:!body!
        ) else (
            echo(!linenum!:%TAB%Skipped content: !body!
        )
    ) else if defined section_filter_match (
        if !linegap! GTR 1 echo(
        echo(!body!
    )

    %=                                                                      =%
    %= Return some values to the base scope                                 =%
    %=                                                                      =%
    for /F "tokens=*" %%A in (^"endlocal%#LF%endlocal%#EOL%
        set "linenum=!linenum!"%#EOL%
        set "section=!section!"%#EOL%
        set "title=!title!"%#EOL%
        set "subtitle=!subtitle!"%#EOL%
        set "section_filter_match=!section_filter_match!"%#EOL%
    ^") do (
        %%A
    )
)
exit /b 0





::==============================================================================
:Args.parse_pairs.DDE args_var valid_args required_args [errmsg_var]
:::
:::  Splits an argument string into NAME=VALUE pairs, returning each valid NAME as a variable.
:::  Assumes the caller is running in DisableDelayedExpansion (DDE) mode.
:::  VALUE can be either a "Quoted Literal" or an UnquotedVariableName.
:::    "Quoted Literal" is stored directly in variable NAME. Most special characters not supported.
:::    UnquotedVariableName is dereferenced into variable NAME. Special characters and linefeeds are supported.
:::
:::      args_var        Name of variable containing function arguments string (typically %*).
:::      valid_args      "Quoted string"; space-separated list of valid argument names.
:::                          If valid_args is empty (""), all names are considered valid.
:::      required_args   "Quoted string"; space-separated list of required argument names.
:::                          If required_args is empty (""), all names are considered optional.
:::      [errmsg_var]    If provided, store an error message in this variable if problems occur.
:::
    setlocal EnableDelayedExpansion
    set "_args_var=%~1"
    set "_valid_args=%~2"
    set "_required_args=%~3"
    set "_errmsg_var=%~4"
    set "_errmsg_invalid=Unknown or incomplete function argument"
    set "_errmsg_missing=Missing or undefined function argument"
    set "_key=" & set "@_return=set "%_errmsg_var%=""
    for %%A in (!%_args_var%!) do if defined _key (
        if "!_key:~0,9!"=="__invalid" (     %= Discard value bc invalid arg     =%
            set "@_return=!@_return!!LF!set ^^"%_errmsg_var%=%_errmsg_invalid%: !_key:~10!""
        ) else if "%%A"==""%%~A"" (         %= Arg is a "Quoted string value"   =%
            set "@_return=!@_return!!LF!set ^^"!_key!=%%~A""
        ) else (                            %= Arg is an UnquotedVariableName   =%
            set "@_return=!@_return!!LF!set ^^"!_key!=!%%~A:%#LF%=%##LF%!""
        )
        set "_key="
    ) else if "!_valid_args:%%~A=!"=="!_valid_args!" (
        set "_key=__invalid:%%~A"
    ) else (
        set "_key=%%~A"
    )
    if defined _key set "@_return=!@_return!!LF!set ^^"%_errmsg_var%=%_errmsg_invalid%: !_key!""
    (goto) 2>nul & (
        %@_return%  %= Macro which sets each valid argument to a variable =%
        for %%V in (%_required_args%) do if not defined %%V set "%_errmsg_var%=%_errmsg_missing%: %%V"
    ) & if defined %_errmsg_var% (call) else (call )


::==============================================================================
:Args.split input_var output_var [extra_carets] [linefeed_var]
::
::   Splits a string onto multiple lines by its whitespace.
::   Whitespace in "quoted blocks" are maintained, not split.
::
::   Notes on special characters:
::    -  Input string may contain linefeeds, but newlines appearing within a
::         "quoted block" are replaced with space " ".
::    -  ^ and ! are escaped according to the caller's context. Additional carets
::         can be added by specifying [extra_carets]="^".
::    -  Literal " should be escaped as "" within a "quoted block".
::    -  Most other special characters must be manually ^escaped or "within quotes".
::
    if "!!"=="" (   %= Returns to EnableDelayedExpansion context =%
        setlocal EnableDelayedExpansion
        if "%~4"=="" ( set "args.return.LF=!LF!" ) else set "args.return.LF=!%~4!"
        set "args.return.PCT=%%"!
        set "args.return.DQT=""!
        set "args.return.CRT=%~3^^^^"!
        set "args.return.EXC=%~3^^^!"!
    ) else (        %= Returns to DisableDelayedExpansion context =%
        setlocal EnableDelayedExpansion
        if "%~4"=="" ( set "args.return.LF=!LF!" ) else set "args.return.LF=!%~4!"
        set "args.return.PCT=%%"!
        set "args.return.DQT=""!
        set "args.return.CRT=%~3^^"!
        set "args.return.EXC=%~3^!"!
    )
    set "args.str=!%~1!"
    set "args.outv=%~2" & if not defined args.outv set "args.outv=%~1"
    if not defined args.str ((goto) 2>nul & set "%args.outv%=" & (call ))
    set ^"args.str=!args.str:%#LF%= !"                  %= 1. Remove linefeeds (permanently) or Step 5, 7 will fail =%
    set "args.str=!args.str:%%=%%2!"                    %= 2. Remove percents first or this step will fail =%
    set "args.str=!args.str:"=%%3!"                     %= 3. Remove quotes or step 5, 7, 8 will sometimes fail =%
    set "args.str=!args.str:^=%%4!"                     %= 4. Remove carets or they will be mangled during step 5 =%
    set "tmp=%%5" & set "args.str=%args.str:!=!tmp!%"   %= 5. Remove exclamations. Can only be done from pct expansion. Good thing we escaped all the other weird characters first =%
    set ^"args.str=!args.str:%%3=%%3%#LF%!"             %= 6. Split on doublequotes to loop over quoted blocks =%
    :: call :printvar args.str
    set "args.return=" & set "numq=0"
    for /F delims^=^ eol^= %%T in ("!args.str!") do (   %= 7. For each quoted block... =%
        set /A "numq=(numq+1) %% 2"           %= Alternates btw 1 (outside quotes) and 0 (inside quotes) =%
        set "tok=%%T"                         %= 8. Collect the block. Requires percent expansion, but all weird characters are gone now =%
        if !numq!==1 if defined tok (         %= 9. Outside quotes, replace each block of whitespace with LF =%
            set "tok=!tok: =" "!"                   %= Mark before and after each whitespace char =%
            set "tok=!tok:%TAB%=" "!"
            set "tok=!tok:""=!"                     %= Combine consecutive marks. Only remaining marks are at beginning and end of whitespace blocks. =%
            set "tok=!tok: =!"                      %= Remove whitespace, bringing the start+end marks together. =%
            set "tok=!tok:""=%%~1!"                 %= Replace what was once a whitespace block with a single LF. =%
        )                                     %= 9. Inside quotes, do nothing, keep whitespace intact    =%
        set "args.return=!args.return!!tok!"  %=10. Append block(s) to output =%
    )
    if "!args.return:~0,3!"=="%%~1" set "args.return=!args.return:~3!"     %= 11. Trim leading and trailing newline =%
    if "!args.return:~-3!"=="%%~1"  set "args.return=!args.return:~0,-3!"
    :: call :printvar args.return
    for %%1 in ("!args.return.LF!") do for /F "tokens=1-4" %%2 in ("!args.return.PCT! !args.return.DQT! !args.return.CRT! !args.return.EXC!") do (goto) 2>nul & ( %= Fails in such a way that the function call exits but the remainder of the code block continues running =%
        set "%args.outv%=%args.return%"       %=12. Now inside the caller's context. Secondary (Metavariable) expansion replaces the previously-removed special characters. =%
    ) & (call )                               %= Set ERRORLEVEL=0 (success). Execution returns to the caller =%



::==============================================================================
:File.getFilePath input_file_var [output_file_var]
::
::   Smarter file path resolution.
::   Given a partial or unresolved path, returns the full path to the file, if it exists.
::   If the file is not immediately locatable, searches for the file in PATH
::   (and other system locations) using external "where" utility.
::
    setlocal EnableDelayedExpansion
    set "inv=%1" & if not defined inv exit /b 1
    set "outv=%2" & if not defined outv set "outv=%inv%"
    set "file=!%inv%!"
    if not defined file ( (goto) 2>nul & set "%outv%=" & (call) ) %= Failure =%

    for /F delims^=^ eol^= %%F in ("!file!") do (
        set "file.attrib=%%~aF" %= Empty if file does not exist =%

        if defined file.attrib (    %= File exists =%
            if "!file.attrib:~0,1!"=="d" (            set "file="
            ) else setlocal DisableDelayedExpansion & set "file=%%~fF"
        ) else (    %= Attempt to locate file using 'where' =%
            setlocal DisableDelayedExpansion
            if not "%%~xF"=="" set "PATHEXT="
            set "file=" & for /F usebackq^ delims^=^ eol^= %%P in (`where "%%~dpF;.;%PATH%:%%~nxF" 2^>nul`) do if not defined file set "file=%%P"
        )
    )

    if defined file ( (goto) 2>nul
        if "!!"=="" ( set "%outv%=%file:!=^!%"!
        ) else set "%outv%=%file%"
        (call ) %= Success =%
    ) else ( (goto) 2>nul
        set "%outv%="
        (call) %= Failure =%
    )


::==============================================================================
:throw "Error message"|msg_var [ERRORLEVEL]
::
::   Prints an error message, returns to the caller, calls ERROR_HOOK, sets ERRORLEVEL.
::   If [ERRORLEVEL] is provided, :throw returns that error value to the caller's context.
::   Otherwise, if :throw is called while ERRORLEVEL is nonzero, its original value is maintained;
::   Otherwise, :throw returns ERRORLEVEL=1.
::
    setlocal DisableDelayedExpansion & set "ERRORLEVEL=%ERRORLEVEL%"
    set "throw.msgv=%1"
    set ^"throw.msg=%~1"
    setlocal EnableDelayedExpansion
    if defined throw.msgv if "!throw.msgv!"=="!throw.msg!" ( set "throw.msg=!%1!"
    ) else set ^"throw.msg=!throw.msg:""="!"
    if not defined throw.msg set "throw.msg=ERROR: A critical error has occurred."
    if not "%~2"=="" ( set "ERRORLEVEL=%~2"
    ) else if "!ERRORLEVEL!"=="0" set "ERRORLEVEL=1"
    (goto) 2>nul & (
        setlocal DisableDelayedExpansion & call echo(  --[ %%~nx0 ]-- 1>&2 & endlocal
        setlocal EnableDelayedExpansion  &      echo(%throw.msg%      1>&2 & endlocal !
        if defined ERROR_HOOK call :%ERROR_HOOK% %ERRORLEVEL%
        if %ERRORLEVEL% equ 1 (call) else if %ERRORLEVEL% equ 0 (call ) else cmd /c exit %ERRORLEVEL%
    )


::==============================================================================
:exit_on_error [ERRORLEVEL]
::
::  Generic error hook. Exits the caller and sets ERRORLEVEL.
::
    (goto) 2>nul & (
        exit /b %~1
    )



::==============================================================================
:printvar var [var2 [var3...]]
::
::  Prints the contents of one or more variables.
::
    setlocal EnableDelayedExpansion
    for %%V in (%*) do echo(%%~V=[!%%~V!]
    endlocal
    exit /b 0







::==============================================================================
::  TESTS
::  WARNING: This section contains invalid code. Do not execute directly!


NOT A COMMENT: This line should not be displayed. (<linenum>:<section>)
::: This line should not be displayed.
:::.TEST_1                     <tab>Section with 3 lines.
:::  This is a comment.
:::  Next line is empty.
:::
:.TEST_1.Sub1           <tab>Subsection with 3 lines. (<linenum>:<section>)
:::  This is a comment.
:::  Next line is empty.
:::
 :::  .TEST_1.Sub1.Sub2 <tab>Subsection with 2 lines.
  :::  This is a comment.
   :::  This is a comment.
:label NOT A COMMENT: This line should not be displayed.
::: This line should not be displayed.


rem .TEST_2         <tab>Section with 3 lines.
rem   This is a comment.
rem   Next line is empty.
rem
REM ..Sub1    <tab>Subsection with 3 lines.
REM   This is a comment.
REM   Next line is empty.
REM
 Rem ...Sub2   <tab>Subsection with 2 lines.
  Rem   This is a comment.
   Rem   This is a comment.
NOT A COMMENT: This line should not be displayed.


:::.TEST_3.Sub1.Sub2  New section with 0 lines.
:.TEST_4..Sub2_2 New section with 0 lines.
:::.TEST_5 New section with 4 lines.
:::  <<fullpath>>=[<fullpath>]
:::  <<basename>>=[<basename>]
:::  <<basename_no_ext>>=[<basename_no_ext>]
:::  <<fileext>>=[<fileext>]

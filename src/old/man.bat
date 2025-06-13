::##############################################################################
::.Usage:
::   <basename> {"path/to/file"} ["search string"] ...
::
::      Displays help text embedded within the file.
::
@echo off
setlocal DisableDelayedExpansion
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

set "TRUE=true"
set "FALSE=false"

:: Set to TRUE to print extra debug info
if /i "%DEBUG%"=="%true%" ( set "DEBUG=%true%" ) else set "DEBUG=%false%"

:: Function to call on errors
set "ERROR_HOOK=exit_on_error"


goto :START
call :throw "CRITICAL: Execution should not get to this point^! (1)"
exit /b 1

::##############################################################################
::.handler.Supported file types:
::
:.handler.cmd
:.handler.bat
    setlocal EnableDelayedExpansion
    set "FILE=!file.f!"
    set "SECTION_FILTERS=!args.unprocessed!"

    setlocal DisableDelayedExpansion

    set "ws=[%TAB% ]"
    set ^"LINE_FILTERS_REGEX=    %#EOL%
        "^%ws%*:::"         %#EOL%
        "^%ws%*::"          %#EOL%
        "^%ws%*:\."         %#EOL%
        "^%ws%*rem"         %#EOL%
    "

    set ^"COMMENT_START_MARKERS=%#EOL%
        ":::"             %#EOL%
        "::"              %#EOL%
        ":"               %#EOL%
        "rem"             %#EOL%
    ^"

    set "SECTION_TITLE_MARKER=."

    set "SUBST_START_MARKER=<"
    set "SUBST_END_MARKER=>"

    call :.print_comments FILE

    exit /b %ERRORLEVEL%


:.handler.exe
    setlocal EnableDelayedExpansion
    set "FILE=!file.f!"
    set "cmd_args=!args.unprocessed!"
    if defined cmd_args ( set "cmd_args=/?"
    ) else set ^"cmd_args=!cmd_args:%#LF%= !"

    cmd /d /c "!FILE!" !cmd_args!

    exit /b %ERRORLEVEL%


::##############################################################################
:.print_comments file_var
::
::  Prints the contents of a file, optionally applying filters to the file contents.
::
::..DETAIL.Configuration
::
::    LINE_FILTERS_REGEX        Regex strings to match lines using findstr
::    COMMENT_START_MARKERS     Comment <<start>> marker strings to remove from each matched line
::    SECTION_TITLE_MARKER      Section <<mark>> string indicating start of a section/subsection
::    SECTION_FILTERS
::    SUBST_START_MARKER        Character indicating beginning of a substitution key
::    SUBST_END_MARKER          Character indicating end of a subsitution key
::
::..DETAIL.Procedure:
::
::    1. findstr.exe filters only the lines matching LINE_FILTERS_REGEX.
::    2. COMMENT_START_MARKERS are trimmed from the beginning of each line.
::    3. Line is parsed for section/subsection markers.
::    4. SECTION_FILTERS are applied. Only lines which are part of a matching section are printed.
::    5. In-line substitutions are applied according to BODY_SUBST_MAP. See source for valid substitutions.
::
::..DETAIL.Detail:
::
::  'findstr' returns each comment line formatted as:
::
::  <<line>> = <<linenum>><<colon>><<ws>><<start>><<comment>>
::
::     <<linenum>>  Line number
::     <<colon>>    Colon character
::     <<ws>>       0 or more whitespace (tabs or spaces)
::     <<start>>    String marking start of comment.
::     <<comment>>  Remainder of line after <<start>> marker.
::
::
::  <<comment>> is either a section header or a plain body text.
::  Section headers are composed of one or more subtitles.
::
::    if <<comment>> == <<ws>><<------------head-------------->><<ws>><<desc>>
::           <<head>> =     <<mark>><<title>>...<<mark>><<subtitle>>
::           <<tail>> =                                     <<ws>><<desc>>
::           <<body>> =                           <<subtitle>><<ws>><<desc>>
::    else
::           <<head>> =
::           <<tail>> =
::           <<body>> = <<comment>>
::
::    <<body>>      Text that is actually displayed.
::    <<desc>>      (Optional) Section description.
::    <<mark>>      String indicating start of section/subsection title.
::    <<title>>     (Optional) Title of outermost section.
::    <<subtitle>>  (Optional) Title of innermost section.
::
::
::  <<section>> is a string built by filling in missing <<subtitle>> in <<head>>, where possible.
::    If <<title>> or <<subtitle>> is missing (only <<mark>> is present),
::      they are carried from the previous section.
::    <<section>> is carried from previous comment lines, but a non-comment line clears <<section>>.
::
::
::  <<mark>> undefined implies <<head>>, <<tail>>, <<desc>>, <<title>>, <<subtitle>>, <<section>> undefined.
::
::
::  SECTION_FILTERS are applied against <<section>>.
::
setlocal EnableDelayedExpansion
set "FILE=!%1!" & if not defined FILE call :throw "[%0] No file provided."
if not exist "!FILE!" call :throw "File not found: ""^^!FILE^^!"""

setlocal DisableDelayedExpansion

:: File properties
for %%F in ("%FILE%") do (
    set ^"FILE.f=%%~fF"
    set ^"FILE.nx=%%~nxF"
    set ^"FILE.n=%%~nF"
    set ^"FILE.x=%%~xF"
)

:: Defaults
::  All support escaping " as ""
if not defined S_TAB                            set "S_TAB=    "            %= Size of tab character, in spaces. =%
if not defined LINE_FILTERS_REGEX               set "LINE_FILTERS_REGEX=.*" %= Regex strings to match lines using findstr =%
if not defined COMMENT_START_MARKERS            set "COMMENT_START_MARKERS="      %= Comment <start> marker strings to remove from each matched line =%
if not defined SECTION_TITLE_MARKER             set "SECTION_TITLE_MARKER="       %= Section <mark> string indicating start of a section/subsection =%
if not defined SECTION_FILTER_INCLUSION_MARKER  set "SECTION_FILTER_INCLUSION_MARKER=/inc:"
if not defined SECTION_FILTER_EXCLUSION_MARKER  set "SECTION_FILTER_EXCLUSION_MARKER=/exc:"
if not defined SECTION_FILTERS                  set "SECTION_FILTERS="      %= Section <mark> string indicating start of a section/subsection =%
if not defined SUBST_START_MARKER               set "SUBST_START_MARKER="   %= String indicating beginning of a substitution key =%
if not defined SUBST_END_MARKER                 set "SUBST_END_MARKER="     %= String indicating end of a subsitution key =%



:: Substitution map.
::  '<' and '>' are later replaced with SUBST_START_MARKER and SUBST_END_MARKER.
set ^"SECTION_SUBST_MAP=%#EOL%
    "<<=<<\"                      %#EOL%
    ">>=\>>"                      %#EOL%
    "<fullpath>=!FILE.f!"         %#EOL%
    "<basename>=!FILE.nx!"        %#EOL%
    "<basename_no_ext>=!FILE.n!"  %#EOL%
    "<fileext>=!FILE.x!"          %#EOL%
    "<sp>= "                      %#EOL%
    "<tab>=%TAB%"                 %#EOL%
    "<pct>=%%"                    %#EOL%
    "<<\=<"                       %#EOL%
    "\>>=>"                       %#EOL%
"

set ^"BODY_SUBST_MAP=%#EOL%
    "<<=<<\"                      %#EOL%
    ">>=\>>"                      %#EOL%
    "<fullpath>=!FILE.f!"         %#EOL%
    "<basename>=!FILE.nx!"        %#EOL%
    "<basename_no_ext>=!FILE.n!"  %#EOL%
    "<fileext>=!FILE.x!"          %#EOL%
    "<linenum>=!linenum!"         %#EOL%
    "<section>=!section!"         %#EOL%
    "<title>=!title!"             %#EOL%
    "<subtitle>=!subtitle!"       %#EOL%
    "<sp>= "                      %#EOL%
    "<tab>=%TAB%"                 %#EOL%
    "<pct>=%%"                    %#EOL%
    "<<\=<"                       %#EOL%
    "\>>=>"                       %#EOL%
"

setlocal EnableDelayedExpansion

:: Repack LINE_FILTERS_REGEX as a space-separated list of findstr regex args
call :Args.split.EDE LINE_FILTERS_REGEX _tmp & set "LINE_FILTERS_REGEX="
for /F delims^=^ eol^= %%A in ("!_tmp!") do (
    set ^"tok=%%~A"!
    if defined tok (
        set ^"tok=!tok:""=\"!"
        set "LINE_FILTERS_REGEX=!LINE_FILTERS_REGEX! /C:"!tok!""
    )
)

:: Repack COMMENT_START_MARKERS
call :Args.split.EDE COMMENT_START_MARKERS _tmp & set "COMMENT_START_MARKERS="
for /F delims^=^ eol^= %%A in ("!_tmp!") do (
    set ^"tok=%%~A"!
    if defined tok (
        set ^"tok=!tok:""="!"
        set "COMMENT_START_MARKERS=!COMMENT_START_MARKERS!!LF!!tok!"
    )
)

:: Repack SECTION_TITLE_MARKER, SECTION_FILTER_INCLUSION_MARKER, SECTION_FILTER_EXCLUSION_MARKER
if defined SECTION_TITLE_MARKER set ^"SECTION_TITLE_MARKER=!SECTION_TITLE_MARKER:""="!"
if defined SECTION_FILTER_INCLUSION_MARKER set ^"SECTION_FILTER_INCLUSION_MARKER=!SECTION_FILTER_INCLUSION_MARKER:""="!"
if defined SECTION_FILTER_EXCLUSION_MARKER set ^"SECTION_FILTER_EXCLUSION_MARKER=!SECTION_FILTER_EXCLUSION_MARKER:""="!"

:: Repack SECTION_FILTERS for easier processing later.
::   Replace tabs with S_TABs
::   Remove SECTION_FILTER_INCLUSION_MARKER before each filter
::   Remove SECTION_FILTER_EXCLUSION_MARKER before each filter and place quotes around exclusion filters
call :Args.split.EDE SECTION_FILTERS _tmp & set "SECTION_FILTERS="
for /F delims^=^ eol^= %%S in ("!_tmp!") do (
    set ^"filter_set=%%~S"!
    if defined filter_set (
        set ^"filter_set=!filter_set:""="!"
        call :Args.split.EDE filter_set
        for /F delims^=^ eol^= %%F in ("!filter_set!") do (
            set ^"filter=%%F"!
            if defined SECTION_FILTER_INCLUSION_MARKER if "!filter!"=="%SECTION_FILTER_INCLUSION_MARKER%!filter:*%SECTION_FILTER_INCLUSION_MARKER%=!" ( %= Filter starts with inclusion marker =%
                set "filter=!filter:*%SECTION_FILTER_INCLUSION_MARKER%=!"
            ) else if defined SECTION_FILTER_EXCLUSION_MARKER if "!filter!"=="%SECTION_FILTER_EXCLUSION_MARKER%!filter:*%SECTION_FILTER_EXCLUSION_MARKER%=!" ( %= Filter starts with exclusion marker =%
                set ^"filter="!filter:*%SECTION_FILTER_EXCLUSION_MARKER%=!"^"
            )
            set "filter=!filter:%TAB%=<tab>!"
            set "filter=!filter: =<sp>!"
            set "SECTION_FILTERS=!SECTION_FILTERS! !filter!"
        )
        set "SECTION_FILTERS=!SECTION_FILTERS!!LF!"
    )
)

:: Repack subsitution maps, replacing '<', '>' with SUBST_START_MARKER and SUBST_END_MARKER
set ^"SUBST_START_MARKER=!SUBST_START_MARKER:""="!"
set ^"SUBST_END_MARKER=!SUBST_END_MARKER:""="!"
for %%M in (BODY_SUBST_MAP SECTION_SUBST_MAP) do (
    call :Args.split.EDE %%M _tmp & set "%%M="
    for /F delims^=^ eol^= %%A in ("!_tmp!") do (
        set ^"tok=%%~A"!
        if defined tok (
            set ^"tok=!tok:""="!"
            set "%%M=!%%M!!LF!"!tok!""
        )
    )
    for /F delims^=^ eol^= %%S in ("<=!SUBST_START_MARKER!!LF!>=!SUBST_END_MARKER!") do (
        if defined %%M set "%%M=!%%M:%%S!"
    )
)

:: Debug
if /i "%DEBUG%"=="%true%" ( setlocal EnableDelayedExpansion
    echo(
    echo(===============================================================
    setlocal DisableDelayedExpansion & echo(   %0 %* & endlocal
    echo(===============================================================
    echo(Properties:
    for %%V in (S_TAB LINE_FILTERS_REGEX COMMENT_START_MARKERS SECTION_TITLE_MARKER SECTION_FILTER_INCLUSION_MARKER SECTION_FILTER_EXCLUSION_MARKER SECTION_FILTERS SUBST_START_MARKER SUBST_END_MARKER BODY_SUBST_MAP SECTION_SUBST_MAP) do echo(  %%V=[!%%V!]
    echo(
    echo(===============================================================
    echo(Printing comments in file:
    echo(  !FILE!
    echo(===============================================================
    echo(
    endlocal
)


:: For each comment line...
set "linenum="
set "section="
set "title="
set "subtitle="
set "section_filter_match="
for %%L in ("!LF!") do for /F usebackq^ tokens^=^*^ delims^=^ eol^= %%C in (`findstr /N /I /R !LINE_FILTERS_REGEX! "!FILE!"`) do (
    setlocal DisableDelayedExpansion
    %=  <line> = <linenum><colon><ws><start><comment>             =%
    set ^"line=%%C"

    setlocal EnableDelayedExpansion
    %= Get <linenum> =%
    for /F "tokens=1 delims=:" %%N in ("!line!") do (
        set /A "linegap=%%N-linenum"
        set /A "linenum=%%N"
    )


    %= Detect section breaks =%
    if !linegap! GTR 1 (
        set "section="
        set "title="
        set "subtitle="
        set "section_filter_match="
    )


    %= Get <comment> =%
    %= Remove <linenum><colon> =%
    set "comment=!line:*:=!"

    %= Replace tabs with spaces (S_TAB) =%
    if defined comment set "comment=!comment:%TAB%=%S_TAB%!"

    %= Remove <ws><start> =%
    if defined comment (
        set "_tmp=!comment: =!"
        for /F delims^=^ eol^= %%M in ("!COMMENT_START_MARKERS!") do if defined _tmp ( %= Undefine _tmp to break loop =%
            if /i "!_tmp!"=="%%M!_tmp:*%%M=!" ( %= comment starts with marker M =%
                set ^"comment=!comment:*%%M=!"!
                set "_tmp=" %= Break loop =%
            )
        )
    )


    %= Get <head> and <tail> =%
    %=   if <comment> == <ws><------------head--------------><ws><desc>     =%
    %=          <head> =     <mark><title>...<mark><subtitle>               =%
    %=          <tail> =                                     <ws><desc>     =%
    %=   else                                                               =%
    %=          <head> =                                                    =%
    %=          <tail> =                                                    =%
    %=                                                                      =%
    %= Never attempt to parse <head> or <tail> if <mark> is undefined.      =%

    set "head=" & set "tail="
    if defined SECTION_TITLE_MARKER (
        set "_tmp=!comment: =!"
        if /i "!_tmp!"=="%SECTION_TITLE_MARKER%!_tmp:*%SECTION_TITLE_MARKER%=!" ( %= <comment> starts with <ws><mark> =%
            for /F "tokens=1 eol=  delims= " %%H in ("%SECTION_TITLE_MARKER%!comment:*%SECTION_TITLE_MARKER%=!") do (
                set ^"head=%%H"!
                set ^"tail=!comment:*%%H=!"!
            )
        )
    )


    %= Get <section>, <title>, <subtitle>                   =%
    %=   <head> defined  implies-->  <mark> defined         =%
    if defined head (
        %= Split old section on <mark> =%
        if defined section ( %= Add a linefeed before each <mark> (except the first one) =%
            set "old_section=!section:%SECTION_TITLE_MARKER%=%%~L%SECTION_TITLE_MARKER%!!LF!"
            set "old_section=!old_section:*%%~L=!"
        ) else set "old_section=%SECTION_TITLE_MARKER%"
        set "section="
        set "title="
        set "subtitle="

        %= Loop over all tok=<mark><subtitle> in <head> =%
        for /F delims^=^ eol^= %%T in ("!head:%SECTION_TITLE_MARKER%=%%~L%SECTION_TITLE_MARKER%!") do (
            set "tok=%%T"
            if /i "!tok!"=="%SECTION_TITLE_MARKER%" (
                %= Current <head> tok does NOT have a subtitle (just a <mark>) =%
                %= Replace with the current <old_section> token (even if that's empty too) =%
                set "tok=" & for /F delims^=^ eol^= %%S in ("!old_section!") do if not defined tok set "tok=%%S"
            ) else (
                %= Current <head> tok DOES have a subtitle =%
                %= Keep the current <head> tok and CLEAR old_section; it is no longer useful to us =%
                set "old_section="
            )
            if not defined tok set "tok=%SECTION_TITLE_MARKER%"

            set "subtitle=!tok:*%SECTION_TITLE_MARKER%=!"                         %= Set <subtitle> every iteration. Remove leading <mark>. =%
            if not defined section set "title=!subtitle!"                   %= Set <title> on first iteration only =%
            if defined old_section set "old_section=!old_section:*%%~L=!"   %= Consume one token from front of old_section. =%
            set "section=!section!!tok!"                                    %= Append new token to end of new <section>. =%
        )
    )


    %= Get <body>:                                          =%
    %=   if <comment> == <ws><-----head-----><ws><desc>     =%
    %=          <body> =           <subtitle><ws><desc>     =%
    %=   else                                               =%
    %=          <body> = <comment>                          =%
    if defined head (
        set "body=!subtitle!!tail!"
    ) else set "body=!comment!"

    %= Process substitution tags in <body> =%
    if defined body for /F delims^=^ eol^= %%S in (^"%BODY_SUBST_MAP%^") do (
        if defined body set "body=!body:%%~S!"
    )


    %= Get section_filter_match (process SECTION_FILTERS)   =%
    %=   Only reevaluate when <comment> contains <head>     =%
    %=   Empty SECTION_FILTERS matches every <section>      =%
    %=   <head> defined  implies-->  <section> defined      =%
    if defined SECTION_FILTERS (
        if defined head (
            %= Process substitution tags in <section> =%
            set "section_=!section!"
            for /F delims^=^ eol^= %%S in (^"%SECTION_SUBST_MAP%^") do (
                if defined section_ set "section_=!section_:%%~S!"
            )
            set "section_filter_match="
            for /F delims^=^ eol^= %%S in ("!SECTION_FILTERS!") do if not defined section_filter_match ( %= Define section_filter_match to break loop =%
                %= <section> must match all filters in filter_set =%
                set ^"filter_set=%%S"!
                if defined filter_set for /F delims^=^ eol^= %%F in ("!filter_set: =%%~L!") do if defined filter_set ( %= Undefined filter_set to break loop =%
                    set ^"filter=%%F"!
                    if defined filter if "!filter:~0,1!!filter:~-1,1!"=="""" ( %= If <section> doesn't exclude filter, fail this set. =%
                        if not "!section_!"=="!section_:%%~F=!" set "filter_set="
                    ) else ( %= If <section> doesn't include filter, fail this set. =%
                        if "!section_!"=="!section_:%%F=!" set "filter_set="
                    )
                )
                %= If filter_set is still defined, all its filters were matched successfully. =%
                if defined filter_set set "section_filter_match=!filter_set!"
            )
        )
    ) else ( %= no filters defined =%
        set "section_filter_match="
    )




    %= Print =%
    if /i "%DEBUG%"=="%true%" (
        if defined head if defined section_filter_match (
            echo(
            echo(===============================================================
            echo(!linenum!:%TAB%Section: !SECTION!%TAB%    ^(Matched: !section_filter_match!^)
            echo(===============================================================
            for %%V in (comment head title subtitle section_filter_match) do echo(  ^<%%V^>=[!%%V!]
            echo(
        ) else (
            echo(!linenum!:%TAB%Skipped: !SECTION!
        )
        if defined section_filter_match (
            echo(!linenum!:!body!
        )
    ) else if defined section_filter_match (
        if !linegap! GTR 1 echo(
        echo(!body!
    )


    %= Return some values to the base scope =%
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


::##############################################################################
:START

:: Split %* into args
set ^"args=%*"
if not defined args ( call "%~f0" "%~f0" "Usage" & exit /b 1 )
setlocal EnableDelayedExpansion
call :Args.split.EDE args


:: Get FILE, SECTION_FILTERS, and process any recognized flags.
set "file="
set "args.unprocessed="
for /F delims^=^ eol^= %%A in ("!args!") do (
    set ^"uarg=%%~A"!
    set ^"arg=%%A"!
    if defined arg (
               if /i "!arg!"=="/debug" (     set "DEBUG=%true%" & set "arg="
        ) else if /i "!arg!"=="--debug" (    set "DEBUG=%true%" & set "arg="
        ) else if not defined file (
                   if /i "!arg!"=="/test" (  set "file=%~f0" & set "arg=test"
            ) else if /i "!arg!"=="--test" ( set "file=%~f0" & set "arg=test"
            ) else                           set "file=!uarg!" & set "arg="
        )
    )
    if defined arg set ^"args.unprocessed=!args.unprocessed!!LF!!arg!"
) & set "arg=" & set "uarg="


:: Get file's full path and extension
call :File.getFilePath file file.f || call :throw "File not found: ""^^!file^^!"""
for %%F in ("!file.f!") do set "file.x=%%~xF"


:: Debug
if /i "%DEBUG%"=="%true%" ( setlocal EnableDelayedExpansion
    echo(
    echo(===============================================================
    setlocal DisableDelayedExpansion & echo(   %~nx0 %* & endlocal
    echo(===============================================================
    for %%V in (args args.unprocessed file.f file.x) do echo(  %%V=[!%%V!]
    echo(
endlocal)


:: Run file type handler
goto :.handler%file.x% 1>nul 2>nul || call :throw "No handler defined for filetype: ""^^!file.x^^!"""

call :throw "CRITICAL: Execution should not get to this point^! (2)"
exit /b 1


::##############################################################################


:Args.split.EDE input_var output_var  ( Must be called from EDE )
    set "args.split.numq=0"
    setlocal EnableDelayedExpansion
    set "args.split.str=!%~1!"
    set "args.split.outv=%~2" & if not defined args.split.outv set "args.split.outv=%~1"
    if not defined args.split.str (goto) 2>nul & set "%args.split.outv%=" & set "args.split.numq=" & (call )
    set ^"args.split.str=!args.split.str:%#LF%= !"
    set ^"args.split.str=!args.split.str:^%%=%%!"
    setlocal DisableDelayedExpansion
    set ^"args.split.str=%args.split.str:^=^^^^^^^^%"
    set ^"args.split.str=%args.split.str:!=^^^^^^^!%"
    (goto) 2>nul & (
        set "%args.split.outv%="
        for /F delims^=^ eol^= %%T in (^"%args.split.str:"="!LF!%^") do (
            set /A "args.split.numq=(args.split.numq+1) %% 2"
            set ^"args.split.tok=%%T"!
            if !args.split.numq!==1 ( set ^"args.split.tok=!args.split.tok: =%#LF%!^"
                                      set ^"args.split.tok=!args.split.tok:%TAB%=%#LF%!^"
            )
            set "%args.split.outv%=!%args.split.outv%!!args.split.tok!"
        )
        set "args.split.numq=" & set "args.split.tok="
    ) & (call )


:File.getFilePath input_file_var [output_file_var]
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


:throw "Error message"|msg_var [ERRORLEVEL]
    setlocal DisableDelayedExpansion & set "ERRORLEVEL=%ERRORLEVEL%"
    set ^"throw.msgv=%1"
    set ^"throw.msg=%~1"
    setlocal EnableDelayedExpansion
    if defined throw.msgv if "!throw.msgv!"=="!throw.msg!" ( set "throw.msg=!%1!"
    ) else set ^"throw.msg=!throw.msg:""="!"
    if not defined throw.msg set "throw.msg=ERROR: A critical error has occurred."
    if not "%~2"=="" ( set "ERRORLEVEL=%~2"
    ) else if "!ERRORLEVEL!"=="0" set "ERRORLEVEL=1"
    (goto) 2>nul & (
        setlocal DisableDelayedExpansion
        call echo(  --[ %%~nx0 ]-- 1>&2
        endlocal
        setlocal EnableDelayedExpansion
        echo(%throw.msg% 1>&2 !
        endlocal
        if defined ERROR_HOOK call :%ERROR_HOOK% %ERRORLEVEL%
        if %ERRORLEVEL% equ 1 (call) else if %ERRORLEVEL% equ 0 (call ) else cmd /c exit %ERRORLEVEL%
    )


:exit_on_error [ERRORLEVEL]
    (goto) 2>nul & (
        exit /b %~1
    )

::##############################################################################
::  TESTS
::  WARNING: This section contains invalid code. Do not execute directly!


NOT A COMMENT: This line should not be displayed. (<linenum>:<section>)
:: This line should not be displayed.
::.TEST_1                     <tab>Section with 3 lines.
::  This is a comment.
::  Next line is empty.
::
:.TEST_1.Sub1           <tab>Subsection with 3 lines. (<linenum>:<section>)
::  This is a comment.
::  Next line is empty.
::
 ::  .TEST_1.Sub1.Sub2 <tab>Subsection with 2 lines.
  ::  This is a comment.
   ::  This is a comment.
:label NOT A COMMENT: This line should not be displayed.
:: This line should not be displayed.


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


::.TEST_3.Sub1.Sub2  New section with 0 lines.
:.TEST_4..Sub2_2 New section with 0 lines.
::.TEST_5 New section with 4 lines.
::  <<fullpath>>=[<fullpath>]
::  <<basename>>=[<basename>]
::  <<basename_no_ext>>=[<basename_no_ext>]
::  <<fileext>>=[<fileext>]

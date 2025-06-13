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

:: ENDLOCAL Macro
::   By Jeb (https://stackoverflow.com/a/29869518/10001931)
:: Calls endlocal, preserving the values of one or more variables across the boundary.
:: Usage:
::   %endlocal% var1 var2 ...
::
set ^"@ENDLOCAL=for %%# in (1 2) do if %%#==2 (%#EOL%
  setlocal EnableDelayedExpansion%#EOL%
  %= Take all variable names into the varName array =%%#EOL%
  set varName_count=0%#EOL%
  for %%C in (!args!) do set "varName[!varName_count!]=%%~C" ^& set /a varName_count+=1%#EOL%
  %= Build one variable with a list of set statements for each variable delimited by newlines =%%#EOL%
  %= The lists looks like --> set result1=myContent\n"set result1=myContent1"\nset result2=content2\nset result2=content2\n     =%%\n%
  %= Each result exists two times, the first for the case returning to DDE, the second for EDE =%%#EOL%
  %= The correct line will be detected by the (missing) enclosing quotes  =%%#EOL%
  set "retcontent=1!LF!"%#EOL%
  for /L %%n in (0 1 !varName_count!) do (%#EOL%
    for /F "delims=" %%C in ("!varName[%%n]!") do (%#EOL%
      set "content=!%%c!"%#EOL%
      set "retcontent=!retcontent!"set !varname[%%n]!=!content!"!LF!"%#EOL%
      if defined content (%#EOL%
        %= This complex block is only for replacing '!' with '^!'      =%%#EOL%
        %= First replacing   '"'->'""q'   '^'->'^^'                    =%%#EOL%
        set ^"content_EDE=!content:"=""q!"%#EOL%
        set "content_EDE=!content_EDE:^=^^!"%#EOL%
        %= Now it's possible to use CALL SET and replace '!'->'""e!' =%%#EOL%
        call set "content_EDE=%%content_EDE:^!=""e^!%%"%#EOL%
        %= Now it's possible to replace '""e' to '^', this is effectivly '!' -> '^!'  =%%#EOL%
        set "content_EDE=!content_EDE:""e=^!"%#EOL%
        %= Now restore the quotes  =%%#EOL%
        set ^"content_EDE=!content_EDE:""q="!"%#EOL%
      ) else set "content_EDE="%#EOL%
      set "retcontent=!retcontent!set "!varName[%%n]!=!content_EDE!"!LF!"%#EOL%
    )%#EOL%
  )%#EOL%
  %= Now return all variables from retcontent over the barrier =%%#EOL%
  for /F "delims=" %%V in ("!retcontent!") do (%#EOL%
    %= Only the first line can contain a single 1 =%%#EOL%
    if "%%V"=="1" (%#EOL%
      %= We need to call endlocal twice, as there is one more setlocal in the macro itself =%%#EOL%
      endlocal%#EOL%
      endlocal%#EOL%
    ) else (%#EOL%
      %= This is true in EDE =%%#EOL%
      if "!"=="" (%#EOL%
        if %%V==%%~V (%#EOL%
            %%V !%#EOL%
        )%#EOL%
      ) else if not %%V==%%~V (%#EOL%
        %%~V%#EOL%
      )%#EOL%
    )%#EOL%
  )%#EOL%
) else set args= "

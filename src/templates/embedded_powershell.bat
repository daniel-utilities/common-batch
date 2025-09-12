<# ::============================= BEGIN BATCH =================================
::  embedded_powershell.bat
::==============================================================================
:::.Summary:
:::
:::  Simple description text.
:::
:::.Details:
:::
:::  Detailed description text.
:::
::==============================================================================
@echo off


powershell -c "iex ((Get-Content '%~f0') -join [Environment]::Newline); iex 'main %*'"



goto :EOF & ::================================  END BATCH  ===============================#>

function main
{
    param(
        [string] $Argument1,
        [switch] $Argument2
    )

    Write-Host '... we can run PowerShell!'
}

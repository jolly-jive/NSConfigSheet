<#
.SYNOPSIS
Define constant variables for given enumeration type.

.DESCRIPTION
This function receives a list of enumeration types as input, and
for each enumeration type, defines constant variables from it.
The variable names are with the prefix argument as the prefix.

.INPUTS
Enumeration types.

.OUTPUTS
nothing
#>
function Set-ConstantsForEnum
{
    [CmdletBinding()]
    param(
        # Enumeration types.
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [type[]]
        $TypeList,

        # Prefix of the constant variables. Value "enum" is used as default value.
        [string]
        $prefix = 'enum'
    )

    foreach($type in $TypeList) {
        [Enum]::GetNames($type) | foreach {
            Set-Variable -Option ReadOnly -Scope Script -Name "$prefix$_" -Value $type::$_
        }
    }
}

$wdDoNotSaveChanges = [Microsoft.Office.Interop.Word.WdSaveOptions]::wdDoNotSaveChanges
$wdMissing = [System.Reflection.Missing]::Value

[Microsoft.Office.Interop.Word.WdDefaultTableBehavior] | Set-ConstantsForEnum
[Microsoft.Office.Interop.Word.WdAutoFitBehavior] | Set-ConstantsForEnum
[Microsoft.Office.Interop.Word.WdUnits] | Set-ConstantsForEnum
[Microsoft.Office.Interop.Word.WdMovementType] | Set-ConstantsForEnum
[Microsoft.Office.Interop.Word.WdGoToItem] | Set-ConstantsForEnum
[Microsoft.Office.Interop.Word.WdGoToDirection] | Set-ConstantsForEnum
[Microsoft.Office.Interop.Word.WdListGalleryType] | Set-ConstantsForEnum
[Microsoft.Office.Interop.Word.WdPreferredWidthType] | Set-ConstantsForEnum
[Microsoft.Office.Interop.Word.WdBuiltinStyle] | Set-ConstantsForEnum
[Microsoft.Office.Interop.Word.WdBuiltInProperty] | Set-ConstantsForEnum
[Microsoft.Office.Interop.Word.WdListApplyTo] | Set-ConstantsForEnum

$whatWdGoToLine = $enumWdGoToLine
$whichWdGoToLast = $enumWdGoToLast
$whichWdGoToAbsolute = $enumWdGoToAbsolute

[System.Reflection.BindingFlags] | Set-ConstantsForEnum

Set-Variable -Option Constant -Name ComObject -Value ('System.__ComObject' -as [type])

Set-Variable -Option Constant -Name ProjectURL -Value 'http://...'

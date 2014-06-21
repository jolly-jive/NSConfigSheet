Function Split-Row
{
    [CmdletBinding()]
    param(
        # The table.
        [parameter(Mandatory=$true)]
        $table,

        # The start row number of the range.
        [int]
        [parameter(Mandatory=$true)]
        $FromRow,

        # The start column number of the range.
        [int]
        [parameter(Mandatory=$true)]
        $FromCol,

        # The start row number of the range.
        [int]
        [parameter(Mandatory=$true)]
        $ToRow,

        # The start column number of the range.
        [int]
        [parameter(Mandatory=$true)]
        $ToCol,

        # The number of rows
        [int]
        [parameter(Mandatory=$true)]
        $rows
    )

    [int]$split_rows = 0
    while($rows -gt 0) {
        if($rows -ge 9) {
            $split_rows = 9
            $rows -= $split_rows
        } else {
            $split_rows = $rows
            $rows = 0
        }
        $start = $table.Cell($FromRow,$FromCol).Range.Start
        $end = $table.Cell($ToRow,$ToCol).Range.End
        $doc.Range([ref]$start,[ref]$end).Cells.Split($split_rows,1)
    }
}

Function Select-CellRange
{
    [CmdletBinding()]
    param(
        # The table.
        [parameter(Mandatory=$true)]
        $table,

        # The start row number of the range.
        [int]
        [parameter(Mandatory=$true)]
        $FromRow,

        # The start column number of the range.
        [int]
        [parameter(Mandatory=$true)]
        $FromCol,

        # The start row number of the range.
        [int]
        [parameter(Mandatory=$true)]
        $ToRow,

        # The start column number of the range.
        [int]
        [parameter(Mandatory=$true)]
        $ToCol
    )

    $start = $table.Cell($FromRow,$FromCol).Range.Start
    $end = $table.Cell($ToRow,$ToCol).Range.End
    $doc.Range([ref]$start,[ref]$end).Select()
    $msword.Selection
}



Function Add-TableToDoc
{
    [CmdletBinding()]
    param(
        # The range.
        [parameter(Mandatory=$true)]
        $Range,

        # The number of rows without the title row.
        [int]
        [parameter(Mandatory=$true)]
        $rows,

        # The number of columns.
        [int]
        [parameter(Mandatory=$true)]
        $cols,

        # The list of title for each column.
        [array]
        $title = @(),

        # The list of style for each column.
        [array]
        $style = @(),

        # The list of title for each column.
        [switch]
        $DontRenumber
    )

    $table = $doc.Tables.Add($range,$rows + 1,$cols,$enumWdWord9TableBehavior,$enumWdAutoFitWindow)

    if($title.Count -ge $cols) {
        Write-Block2Cells $table.Cell(1,1) { $title }
    }


    if($rows -gt 0) {
        if($style.Count -ge $cols) {
            for($col = 1; $col -le $cols; $col++) {
                if($style[$col - 1] -ne $Null) {
                    (Select-CellRange $table 2 $col ($rows + 1) $col).Style = $style[$col - 1]
                }
            }
        }

        if(-not $DontRenumber) {
            $table.Cell(2,1).Range.Select()
            $selection_col = $msword.Selection
            $list_format = $selection_col.Range.ListFormat
            $list_format.ApplyListTemplate($list_format.ListTemplate,$False,$enumWdListApplyToWholeList)
        }
    }


    $table.Columns.PreferredWidthType = $enumWdPreferredWidthAuto

    $table
}


Function Insert-TextAtLast
{
    [CmdletBinding()]
    param(
        # the style.
        [parameter(Mandatory=$true)]
        $Style,

        # The text.
        [string]
        $Text = ''
    )

    $range = $doc.GoTo([ref]$whatWdGoToLine,[ref]$whichWdGoToLast)
    $range.Style = $Style
    $range.InsertAfter($Text)

    $range
}

Function EnabledOrDisabled
{
    param(
        # the value.
        $value
    )

    switch($value) {
        $True { 'ENABLED' }
        $False { 'disabled' }
        0 { 'disabled' }
        default { '(default)' }
    }
}

Function ConcreteValueOrDefault
{
    param(
        # the value.
        $value
    )

    if($value -eq $Null) {
        '(default)'
    } else {
        $value
    }
}

Function OmitEmptyString
{
    param(
        # the value.
        [string]
        $value
    )

    if($value -eq '' ) {
        $Null
    } else {
        $value
    }
}

Function Write-Block2Cells
{
    param(
        # the cell.
        [parameter(Mandatory=$true)]
        $cell,

        # the script block.
        [parameter(Mandatory=$true)]
        $block
    )

    $block.Invoke() | foreach {
        if($_ -ne $Null) {
            $cell.Range.Text = $_
        }
        $cell = $cell.Next
    }
}

Function Write-Block2Row
{
    param(
        # the script block.
        [parameter(Mandatory=$true)]
        $block
    )

    Write-Block2Cells $current_row.Cells.Item(1) $block
}


Function Write-AVRow
{
    param(
        # the name.
        [string]
        $name = $Null,

        # the value.
        $value = $Null,

        # the format.
        [string]
        $format = '{0}'
    )

    if($value -eq $Null) {
        return
    }

    if($current_row -eq $Null ) {
        $script:current_row = $table.Rows.Add()
    }

    $cell = $current_row.Cells.Item(2)

    if($name -ne $Null) {
        $cell.Range.Text = $name
        $cell = $cell.Next
    }

    if($value -is [bool]) {
        $value = EnabledOrDisabled $value
    }
    $cell.Range.Text = $format -f $value
    $script:current_row = $Null
}

Function Write-SE2AVRow
{
    param(
        # the name
        [string]
        $name = $Null,

        # the element.
        [ScreeningElement]
        $element = $Null,

        # the format
        [string]
        $format = '{0}'
    )

    if($element -eq $Null) {
        return
    }

    Write-AVRow $name ($(
    if($element -is [ScreeningElementWithThreshold] -and $element.Threshold -ne $Null) {
        EnabledOrDisabled $element.Enabled
        if($element.Threshold -ne $Null) {
            $format -f $element.Threshold
        }
    } else {
        EnabledOrDisabled $element.Enabled
    }) -join "`n")
}


Function Write-Section
{
    param(
        # Style of the section.
        [parameter(Mandatory=$true)]
        $style,

        # Name of the section.
        [parameter(Mandatory=$true)]
        $name,

        # the script block.
        [parameter(Mandatory=$true)]
        $block,

        # Don't write and skip.
        [switch]
        $skip,

        # Don't write and skip.
        [string]
        $keyword = $Null
    )

    if($skip -or ($keyword -ne $Null -and $ExcludeSection -contains $keyword)) {
        return
    }

    Write-Verbose "Write-Section: [$($style.NameLocal)] $name"

    $position0 = $doc.GoTo([ref]$whatWdGoToLine,[ref]$whichWdGoToLast).Start
    $range = Insert-TextAtLast $STYLE_BODYTEXT "`n"
    $position1 = $doc.GoTo([ref]$whatWdGoToLine,[ref]$whichWdGoToLast).Start
    $block.Invoke()
    $position2 = $doc.GoTo([ref]$whatWdGoToLine,[ref]$whichWdGoToLast).Start
    $range = $doc.Content
    $range.Start = $position0
    $range.End = $position0
    if( $position1 -ne $position2 ) {
        $range.InsertBefore($name)
        $range.Style = $style
    } else {
        $range.Delete() | Out-Null
    }
}

Function Get-AuthServerType
{
    param(
        [AuthServerProfile]
        [parameter(Mandatory=$true)]
        $profile
    )

    switch($profile.GetType()) {
        [LDAPAuthServerProfile] { 'LDAP'; break }
        [RadiusAuthServerProfile] { 'Radius'; break }
        [SecuIDAuthServerProfile] { 'SecuID'; break }
        [TACACSAuthServerProfile] { 'TACACS+'; break }
        default { 'Local' }
    }
}

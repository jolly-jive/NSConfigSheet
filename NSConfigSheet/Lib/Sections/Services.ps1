Set-Variable -Scope Script -Option Constant -Name SectionServices -Value {
    ########## == Serivce Object
    Write-Section $STYLE_HEADING2 'Service Objects' -skip:($ServiceObjecteDic.Count -lt 1) {
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows $ServiceObjecteDic.Count -Cols 8 `
          -Title @('#','name','protocol','source',$Null,'destination',$Null,'memo') `
          -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$Null,$Null,$Null,$Null,$Null,$Null)

        (Select-CellRange $table  1 4  1 7).Cells.Split(2,1)

        Write-Block2Cells $table.Cell(2,4) {
            'lower'
            'upper'
            'lower'
            'upper'
        }

        (Select-CellRange $table  1 6  1 7).Cells.Merge()
        (Select-CellRange $table  1 4  1 5).Cells.Merge()

        $i_row = 3
        foreach($name in $ServiceObjecteDic.keys | Sort-Object) {
            $list = $ServiceObjecteDic[$name].List
            $script:table.Cell($i_row,2).Range.Text = $name

            Split-Row $table  $i_row 3  $i_row 7  $list.Count

            foreach($element in $list) {
                Write-Block2Cells $table.Cell($i_row,3) {
                    $element.protocol
                    $element.SrcPortRange.lower
                    $element.SrcPortRange.upper
                    $element.DstPortRange.lower
                    $element.DstPortRange.upper
                }
                $i_row += 1
            }
        }
    }

    ########## == Serivce Group
    Write-Section $STYLE_HEADING2 'Service Groups' -skip:($ServiceGroupDic.Count -lt 1) {
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows $ServiceGroupDic.Count -Cols 4 `
          -Title @('#','name','members','memo') `
          -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$STYLE_CODE,$Null)

        $i_row = 2
        foreach($name in $ServiceGroupDic.keys | Sort-Object) {
            Write-Block2Cells $table.Cell($i_row,2) {
                $name
                ($ServiceGroupDic[$name].Member.keys | Sort-Object) -join "`n"
            }
            $i_row += 1
        }
    }
}

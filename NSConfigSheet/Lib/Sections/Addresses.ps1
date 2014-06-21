Set-Variable -Scope Script -Option Constant -Name SectionAddresses -Value{
    [Hashtable]$AddressObjectDicForEachZone = @{}
    [Hashtable]$AddressGroupDicForEachZone = @{}
    foreach($address_object in $AddressObjectDic.values) {
        $zone = $address_object.Zone
        if(-not $AddressObjectDicForEachZone.Contains($zone)) {
            [HashTable]$AddressObjectDicForEachZone[$zone] = @{}
            [HashTable]$AddressGroupDicForEachZone[$zone] = @{}
        }
        $AddressObjectDicForEachZone[$zone][$address_object.Name] = $address_object
    }
    foreach($address_group in $AddressGroupDic.values) {
        $zone = $address_group.Zone
        $AddressGroupDicForEachZone[$zone][$address_group.Name] = $address_group
    }


    foreach($zone in $AddressObjectDicForEachZone.keys | Sort-Object) {
        ########## == $zone
        $range = Insert-TextAtLast $STYLE_HEADING2 "Addresses in $zone`n"

        ########## === Address Object
        Write-Section $STYLE_HEADING3 "Address Objects in $zone" -skip:($AddressObjectDicForEachZone[$zone].Count -lt 1) {
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows $AddressObjectDicForEachZone[$zone].Count -Cols 4 `
              -Title @('#','name','value','memo') `
              -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$STYLE_CODE,$Null)

            $i_row = 2
            foreach($name in $AddressObjectDicForEachZone[$zone].keys | Sort-Object) {
                $address_object = $AddressObjectDicForEachZone[$zone][$name]
                Write-Block2Cells $table.Cell($i_row,2) {
                    $name
                    if($address_object.IPAddr -ne '') {
                        "$($address_object.IPAddr)/$($address_object.NetworkMask)"
                    } else {
                        $address_object.FQDN
                    }
                }
                $i_row += 1
            }
        }

        ########## === Address Group
        Write-Section $STYLE_HEADING3 "Address Groups in $zone" -skip:($AddressGroupDicForEachZone[$zone].Count -lt 1) {
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows $AddressGroupDicForEachZone[$zone].Count -Cols 4 `
              -Title @('#','name','member','memo') `
              -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$STYLE_CODE,$Null)

            $i_row = 2
            foreach($name in $AddressGroupDicForEachZone[$zone].keys | Sort-Object) {
                Write-Block2Cells $table.Cell($i_row,2) {
                    $name
                    ($AddressGroupDicForEachZone[$zone][$name].Member.keys | Sort-Object) -join "`n"
                }
                $i_row += 1
            }
        }
    }
}

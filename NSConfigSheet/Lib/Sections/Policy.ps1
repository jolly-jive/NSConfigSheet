Set-Variable -Scope Script -Option Constant -Name SectionPolicy -Value {
    [Hashtable]$PolicyListForEachZonePair = @{}
    foreach($policy in $PolicyList) {
        [string]$zone_pair = "From $($policy.FromZone) to $($policy.ToZone)"
        if(-not $PolicyListForEachZonePair.Contains($zone_pair)) {
            [Policy[]]$PolicyListForEachZonePair[$zone_pair] = @()
        }
        $PolicyListForEachZonePair[$zone_pair] += $policy
    }

    ########## == {ZONE PAIR}
    foreach($zone_pair in $PolicyListForEachZonePair.keys | Sort-Object) {
        $range = Insert-TextAtLast $STYLE_HEADING2 "Policy $zone_pair`n"
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows $PolicyListForEachZonePair[$zone_pair].Count -Cols 8 `
          -Title @('ID','Name','Source','Destination','Service','Action','Options','memo') `
          -Style @($Null,$Null,$STYLE_CODE,$STYLE_CODE,$STYLE_CODE,$Null,$Null,$Null) `
          -DontRenumber

        $i_row = 2
        foreach($policy in $PolicyListForEachZonePair[$zone_pair]) {
            Write-Block2Cells $table.Cell($i_row,1) {
                $policy.Id
                $policy.Name
                $policy.SrcAddrList -join "`n"
                $policy.DstAddrList -join "`n"
                $policy.SvcList -join "`n"
                @(
                    if($policy.Nat -ne $Null) {
                        if($policy.Nat.Src) {
                            if($policy.Nat.DIPID -ne '') {
                                "NAT-src ID $($policy.Nat.DIPID)"
                            } else {
                                'NAT-src using the interface IP'
                            }
                        }
                        if($policy.Nat.DSTIPAddr1 -ne '') {
                            if($policy.Nat.DSTIPAddr2 -ne '') {
                                "NAT-dst $($policy.Nat.DSTIPAddr1)-$($policy.Nat.DSTIPAddr2)"
                            } elseif($policy.Nat.DstPort -ne $Null) {
                                "NAT-dst $($policy.Nat.DSTIPAddr1):($policy.Nat.Port)"
                            } else {
                                "NAT-dst $($policy.Nat.DSTIPAddr1)"
                            }
                        }
                    }
                    $policy.Action
                ) -join "`n"
                @(
                    if($policy.Logging) { 'logging' }
                    if($policy.Count) { 'count' }
                    if($policy.Disabled) { 'disable' }
                ) -join "`n"
            }
            $i_row += 1
        }
    }

    ########## == DIP
    Write-Section $STYLE_HEADING2 'DIP' -keyword 'dip' -skip:($DIPDic.Count -lt 1) {
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows $DIPDic.Count -Cols 3 `
          -Title @('DIP ID','Members','memo') `
          -Style @($STYLE_CODE,$STYLE_CODE,$Null) `
          -DontRenumber

        $i_row = 2
        foreach($dip_id in $DipDic.keys | Sort-Object) {
            $dip_members = $DIPDic[$dip_id]
            Write-Block2Cells $table.Cell($i_row,1) {
                $dip_id
                $DIPDic[$dip_id].keys -join "`n"
            }
            $i_row += 1
        }
    }
}

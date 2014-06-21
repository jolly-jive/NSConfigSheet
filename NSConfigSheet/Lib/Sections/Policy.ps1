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
                $(
                    if($policy.Nat -eq 'source') { 'NAT-Src' }
                    $policy.Action
                ) -join "`n"
                $(
                    if($policy.Logging) { 'logging' }
                    if($policy.Count) { 'count' }
                    if($policy.Disabled) { 'disable' }
                ) -join "`n"
            }
            $i_row += 1
        }
    }
}

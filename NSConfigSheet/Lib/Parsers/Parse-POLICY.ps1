Function Parse-ROOT-Set-Policy
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    $state = 'BEGIN'
    $script:policy_id = 0
    [string]$name = ''
    [Policy]$policy = $Null
    while($params.Count -gt 0) {
        switch($state) {
            'BEGIN' {
                if(PhraseMatch $params 'name',$RE_QUOTED_NAME -prefix) {
                    $policy.Name = $last_mathces[0]['QUOTED_NAME']
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'id',$RE_INTEGER -prefix) {
                    $script:policy_id = [int]$params[1]
                    $params = @(ncdr $params 2)
                    $state = 'ID READ'
                } else {
                    $state = 'ERROR'
                }
            }
            'ID READ' {
                if(PhraseMatch $params 'disable' -prefix) {
                    if(-not $PolicyDic.Contains($policy_id)) {
                        throw "Policy $policy_id does not exist @ $($myinvocation.mycommand.name): $line"
                    }
                    $params = @(ncdr $params 1)
                    $PolicyDic[$policy_id].Disabled = $True
                    $state = 'DISABLED READ'
                } elseif(PhraseMatch $params 'from',$RE_QUOTED_NAME -prefix) {
                    $policy = New-Object Policy
                    $PolicyDic[$policy_id] = $policy
                    $Script:PolicyList += $policy

                    $policy.Id = $policy_id
                    $policy.Name = $name

                    $policy.FromZone = $last_matches[0]['QUOTED_NAME']
                    $params = @(ncdr $params 2)
                    $state = 'FROM READ'
                } else {
                    $state = 'ERROR'
                }
            }
            'FROM READ' {
                if(PhraseMatch $params 'to',$RE_QUOTED_NAME -prefix) {
                    $policy.ToZone = $last_matches[0]['QUOTED_NAME']
                    $params = @(ncdr $params 2)
                    $state = 'TO READ'
                } else {
                    $state = 'ERROR'
                }
            }
            'TO READ' {
                if(PhraseMatch $params $RE_QUOTED_NAME -prefix) {
                    $policy.SrcAddrList += $last_matches[0]['QUOTED_NAME']
                    $params = @(ncdr $params 1)
                    $state = 'SRC READ'
                } else {
                    $state = 'ERROR'
                }
            }
            'SRC READ' {
                if(PhraseMatch $params $RE_QUOTED_NAME -prefix) {
                    $policy.DstAddrList += $last_matches[0]['QUOTED_NAME']
                    $params = @(ncdr $params 1)
                    $state = 'DST READ'
                } else {
                    $state = 'ERROR'
                }
            }
            'DST READ' {
                if(PhraseMatch $params $RE_QUOTED_NAME -prefix) {
                    $policy.SvcList += $last_matches[0]['QUOTED_NAME']
                    $params = @(ncdr $params 1)
                    $state = 'SVC READ'
                } else {
                    $state = 'ERROR'
                }
            }
            'SVC READ' {
                if(PhraseMatch $params 'nat','src' -prefix) {
                    $policy.Nat = 'source'
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params $RE_POLICY_ACTION -prefix) {
                    $policy.Action = $params[0]
                    $params = @(ncdr $params 1)
                    $state = 'ACTION READ'
                } else {
                    $state = 'ERROR'
                }
            }
            'ACTION READ' {
                if(PhraseMatch $params 'log' -prefix) {
                    $policy.Logging = $True
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params 'count' -prefix) {
                    $policy.Count = $True
                    $params = @(ncdr $params 1)
                } else {
                    $state = 'ERROR'
                }
            }
            'ERROR' {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
            default {
                $state = 'ERROR'
            }
        }
    }
    if($state -eq 'ID READ') {
        $context.Push('POLICY')
    }
}

Function Parse-ROOT-Unset-Policy
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'id',$RE_INTEGER) {
        $script:policy_id = [int]$params[1]
        $params = @(ncdr $params 2)
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-POLICY-Body
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params,

        [Bool]
        [parameter(Mandatory=$true)]
        $isSet
    )

    if(-not $PolicyDic.Contains($policy_id)) {
        throw "Policy Id $policy_id does not exists @ $($myinvocation.mycommand.name): $line"
    }
    if(PhraseMatch $params 'src-address',$RE_QUOTED_NAME) {
        $PolicyDic[$policy_id].SrcAddrList += $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'dst-address',$RE_QUOTED_NAME) {
        $PolicyDic[$policy_id].DstAddrList += $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'service',$RE_QUOTED_NAME) {
        $PolicyDic[$policy_id].SvcList += $last_matches[0]['QUOTED_NAME']
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }

}

Function Parse-POLICY
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'set' -prefix) {
        Parse-POLICY-Body @(ncdr $params 1) $True
    } elseif(PhraseMatch $params 'unset' -prefix) {
        Parse-POLICY-Body @(ncdr $params 1) $False
    } elseif(PhraseMatch $params 'exit') {
        if($context.Count -gt 0) {
            $prev_context = $context.Pop()
        } else {
            throw "Illegal exit: $line"
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

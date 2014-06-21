Function Parse-ROOT-Set-SNMP
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($SNMPProfile -eq $Null) {
        $script:SNMPProfile = New-Object SNMPProfile
    }

    $state = 'BEGIN'
    [string]$community_string = $Null
    [SNMPCommunity]$community_instance = $Null
    [SNMPManagementHost]$management_host_instance = $Null
    [string]$mib_filter_name = $Null
    while($params.Count -gt 0) {
        switch($state) {
            'BEGIN' {
                if(PhraseMatch $params 'auth-trap','enable') {
                    $SNMPProfile.SNMPCommunity.AuthenticationFailTrap = $True
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'community',$RE_QUOTED_NAME -prefix) {
                    $community_string = $last_matches[0]['QUOTED_NAME']
                    if(-not $SNMPProfile.SNMPCommunity.Contains($community_string)) {
                        $community_instance = New-Object SNMPCommunity
                        $community_instance.Name = $community_string
                        $SNMPProfile.SNMPCommunity[$community_string] = $community_instance
                    } else {
                        $community_instance = $SNMPProfile.SNMPCommunity[$community_string]
                    }
                    $params = @(ncdr $params 2)
                    $state = 'COMMUNITY STRING READ'
                } elseif(PhraseMatch $params 'contact',$Null) {
                    $SNMPProfile.SNMPCommunity[$community_string].SystemContact = $params[1]
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'host',$RE_QUOTED_NAME -prefix) {
                    $community_string = $last_matches[0]['QUOTED_NAME']
                    if(-not $SNMPProfile.SNMPCommunity.Contains($community_string)) {
                        $community_instance = New-Object SNMPCommunity
                        $community_instance.Name = $community_string
                        $SNMPProfile.SNMPCommunity[$community_string] = $community_instance
                    } else {
                        $community_instance = $SNMPProfile.SNMPCommunity[$community_string]
                    }
                    $management_host_instance = New-Object SNMPManagementHost
                    $community_instance.SNMPManagementHost += $management_host_instance
                    $params = @(ncdr $params 2)
                    $state = 'HOST STRING READ'
                } elseif(PhraseMatch $params 'location',$Null) {
                    $SNMPProfile.Location = $params[1]
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'mib-filter','name',$RE_QUOTED_NAME -prefix) {
                    $mib_filter_name = $last_matches[0]['QUOTED_NAME']
                    $params = @(ncdr $params 3)
                    $state = 'MIB-FILTER READ'
                } elseif(PhraseMatch $params 'name',$RE_QUOTED_NAME) {
                    $SNMPProfile.SystemName = $last_matches[0]['QUOTED_NAME']
                    $params = @(ncdr $params 2)
                    $state = 'HOST STRING READ'
                } elseif(PhraseMatch $params 'port','listen',$RE_INTEGER) {
                    $SNMPProfile.ListenPort = [int]$params[2]
                    $params = @(ncdr $params 3)
                } elseif(PhraseMatch $params 'port','trap',$RE_INTEGER) {
                    $SNMPProfile.TrapPort = [int]$params[2]
                    $params = @(ncdr $params 3)
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'COMMUNITY STRING READ' {
                if(PhraseMatch $params 'read-only' -prefix) {
                    $community_instance.Write = $False
                    $params = @(ncdr $params 1)
                    $state = 'READ-* READ'
                } elseif(PhraseMatch $params 'read-write' -prefix) {
                    $community_instance.Write = $True
                    $params = @(ncdr $params 1)
                    $state = 'READ-* READ'
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'READ-* READ' {
                if(PhraseMatch $params 'mib-filter',$RE_QUOTED_NAME) {
                    Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'trap-off') {
                    $community_instance.Trap = $False
                    $community_instance.Traffic = $False
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params 'traffic' -prefix) {
                    $community_instance.Traffic = $True
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params 'trap-on' -prefix) {
                    $community_instance.Trap = $True
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params 'version',$RE_SNMP_VERSION) {
                    $community_instance.SNMPVersion = [SNMPVersion]$params[1]
                    $params = @(ncdr $params 2)
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'HOST STRING READ' {
                if(PhraseMatch $params $RE_IPV4_ADDRESS_WITH_MASK -prefix) {
                    $management_host_instance.IPAddr = $last_matches[0]['IPV4_ADDRESS_WITH_MASK']
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params $RE_IPV4_HOST_ADDRESS -prefix) {
                    [string]$addr = $last_matches[0]['IPV4_HOST_ADDRESS']
                    if($management_host_instance.IPAddr -eq '') {
                        $management_host_instance.IPAddr = $addr
                    } else {
                        $management_host_instance.IPAddr += "/$addr"
                    }
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params 'src-interface',$RE_INTERFACE_NAME -prefix) {
                    $management_host_instance.SourceInterface = $last_matches[0]['INTERFACE_NAME']
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'trap',$RE_SNMP_TRAP_VERSION) {
                    $management_host_instance.SNMPTrapVersion = [SNMPTrapVersion]$params[1]
                    $params = @(ncdr $params 2)
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'MIB-FILTER READ' {
                Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
                break
            }
            'ERROR' {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
            default {
                $state = 'ERROR'
            }
        }
    }
}

Function Parse-ROOT-Unset-SNMP
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($SNMPProfile -eq $Null) {
        $script:SNMPProfile = New-Object SNMPProfile
    }

    $state = 'BEGIN'
    [string]$community_string = $Null
    [string]$ip_addr = $Null
    [bool]$delete_source_interface = $False
    while($params.Count -gt 0) {
        switch($state) {
            'BEGIN' {
                if(PhraseMatch $params 'auth-trap','enable') {
                    $SNMPProfile.SNMPCommunity.AuthenticationFailTrap = $False
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'community',$RE_QUOTED_NAME) {
                    $community_string = $last_matches[0]['QUOTED_NAME']
                    if(-not $SNMPProfile.SNMPCommunity.Contains($community_string)) {
                        throw "SNMP Community $community_string does not exist @ $($myinvocation.mycommand.name): $line"
                    }
                    $SNMPProfile.SNMPCommunity.Remove($community_string)
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'contact') {
                    $SNMPProfile.SNMPCommunity[$community_string].SystemContact = ''
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params 'host',$RE_QUOTED_NAME -prefix) {
                    $community_string = $last_matches[0]['QUOTED_NAME']
                    if(-not $SNMPProfile.SNMPCommunity.Contains($community_string)) {
                        throw "SNMP Community $community_string does not exist @ $($myinvocation.mycommand.name): $line"
                    }
                    $params = @(ncdr $params 2)
                    $state = 'HOST STRING READ'
                } elseif(PhraseMatch $params 'location') {
                    $SNMPProfile.Location = ''
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params 'mib-filter','name',$RE_QUOTED_NAME) {
                    $params = @(ncdr $params 3)
                    Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
                } elseif(PhraseMatch $params 'name') {
                    $SNMPProfile.SystemName = ''
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'port','listen') {
                    $SNMPProfile.ListenPort = $Null
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'port','trap') {
                    $SNMPProfile.TrapPort = $Null
                    $params = @(ncdr $params 2)
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'HOST STRING READ' {
                if(PhraseMatch $params $RE_IPV4_ADDRESS_WITH_MASK -prefix) {
                    $ip_addr = $last_matches[0]['IPV4_ADDRESS_WITH_MASK']
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params $RE_IPV4_HOST_ADDRESS -prefix) {
                    [string]$addr = $last_matches[0]['IPV4_HOST_ADDRESS']
                    if($ip_addr -eq '') {
                        $management_host_instance.IPAddr = $addr
                    } else {
                        $management_host_instance.IPAddr += "/$addr"
                    }
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params 'src-interface') {
                    $delete_source_interface = $True
                    $params = @(ncdr $params 1)
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'MIB-FILTER READ' {
                Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
                break
            }
            'ERROR' {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
            default {
                $state = 'ERROR'
            }
        }
    }

    if($community_string -ne '') {
        if($ip_addr -ne '') {
            if($delete_source_interface) {
                [SNMPManagementHost]$management_host_instance = $Null
                foreach($management_host_instance in $SNMPProfile.SNMPCommunity[$community_string].SNMPManagementHost) {
                    if($management_host_instance.IPAddr -eq $ip_addr) {
                        $management_host_instance.SourceInterface = ''
                        break
                    }
                }
            } else {
                # Delete the SNMP management host
                Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
            }
        } else {
            # do nothing; SNMP community was deleted.
        }
    }
}

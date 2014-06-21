Function Parse-ROOT-Set-Firewall
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($FirewallLogSelfProfile -eq $Null) {
        $script:FirewallLogSelfProfile = New-Object FirewallLogSelfProfile
    }

    $state = 'BEGIN'
    $traffic_type_list = @()
    while($params.Count -gt 0) {
        switch($state) {
            'BEGIN' {
                if(PhraseMatch  $params 'log-self' -prefix) {
                    $params = @(ncdr $params 1)
                    $state = 'LOG-SELF READ'
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'LOG-SELF READ' {
                if(PhraseMatch $params 'exclude' -prefix) {
                    $params = @(ncdr $params 1)
                    $state = 'EXCLUDE READ'
                } elseif(PhraseMatch $params $RE_FIREWALL_TRAFFIC_TYPE -prefix) {
                    $traffic_type_list += $params[0]
                    $params = @(ncdr $params 1)
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'EXCLUDE READ' {
                if(PhraseMatch $params $RE_FIREWALL_TRAFFIC_TYPE -prefix) {
                    $traffic_type_list += $params[0]
                    $params = @(ncdr $params 1)
                } else {
                    $state = 'ERROR'
                }
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

    switch($state) {
        'LOG-SELF READ' {
            if($traffic_type_list.Count -lt 1) {
                $FirewallLogSelfProfile.Enabled = $True
            } else {
                $traffic_type_list | foreach {
                    switch($_) {
                        'icmp' { $FirewallLogSelfProfile.ICMP = $True }
                        'ike' { $FirewallLogSelfProfile.IKE = $True }
                        'multicast' { $FirewallLogSelfProfile.Multicast = $True }
                        'snmp' { $FirewallLogSelfProfile.SNMP = $True }
                        'telnet' { $FirewallLogSelfProfile.Telnet = $True }
                        'ssh' { $FirewallLogSelfProfile.SSH = $True }
                        'web' { $FirewallLogSelfProfile.Web = $True }
                        'nsm' { $FirewallLogSelfProfile.NSM = $True }
                    }
                }
            }
        }
        'EXCLUDE READ' {
            if($traffic_type_list.Count -lt 0) {
                $FirewallLogSelfProfile.ICMP = $False
                $FirewallLogSelfProfile.IKE = $False
                $FirewallLogSelfProfile.Multicast = $False
                $FirewallLogSelfProfile.SNMP = $False
            } else {
                $FirewallLogSelfProfile.ICMP = $True
                $FirewallLogSelfProfile.IKE = $True
                $FirewallLogSelfProfile.Multicast = $True
                $FirewallLogSelfProfile.SNMP = $True
                $traffic_type_list | foreach {
                    switch($_) {
                        'icmp' { $FirewallLogSelfProfile.ICMP = $False }
                        'ike' { $FirewallLogSelfProfile.IKE = $False }
                        'multicast' { $FirewallLogSelfProfile.Multicast = $False }
                        'snmp' { $FirewallLogSelfProfile.SNMP = $False }
                        default {
                            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
                        }
                    }
                }
            }
        }
        default {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    }
}

Function Parse-ROOT-Unset-Firewall
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($FirewallLogSelfProfile -eq $Null) {
        $script:FirewallLogSelfProfile = New-Object FirewallLogSelfProfile
    }

    $state = 'BEGIN'
    $traffic_type_list = @()
    while($params.Count -gt 0) {
        switch($state) {
            'BEGIN' {
                if(PhraseMatch  $params 'log-self' -prefix) {
                    $params = @(ncdr $params 1)
                    $state = 'LOG-SELF READ'
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'LOG-SELF READ' {
                if(PhraseMatch $params 'exclude' -prefix) {
                    $params = @(ncdr $params 1)
                    $state = 'EXCLUDE READ'
                } elseif(PhraseMatch $params $RE_FIREWALL_TRAFFIC_TYPE -prefix) {
                    $traffic_type_list += $params[0]
                    $params = @(ncdr $params 1)
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'EXCLUDE READ' {
                if(PhraseMatch $params $RE_FIREWALL_TRAFFIC_TYPE -prefix) {
                    $traffic_type_list += $params[0]
                    $params = @(ncdr $params 1)
                } else {
                    $state = 'ERROR'
                }
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

    switch($state) {
        'LOG-SELF READ' {
            if($traffic_type_list.Count -lt 1) {
                $FirewallLogSelfProfile.Enabled = $False
            } else {
                $traffic_type_list | foreach {
                    switch($_) {
                        'icmp' { $FirewallLogSelfProfile.ICMP = $False }
                        'ike' { $FirewallLogSelfProfile.IKE = $False }
                        'multicast' { $FirewallLogSelfProfile.Multicast = $False }
                        'snmp' { $FirewallLogSelfProfile.SNMP = $False }
                        'telnet' { $FirewallLogSelfProfile.Telnet = $False }
                        'ssh' { $FirewallLogSelfProfile.SSH = $False }
                        'web' { $FirewallLogSelfProfile.Web = $False }
                        'nsm' { $FirewallLogSelfProfile.NSM = $False }
                    }
                }
            }
        }
        'EXCLUDE READ' {
            if($traffic_type_list.Count -lt 0) {
                $FirewallLogSelfProfile.ICMP = $True
                $FirewallLogSelfProfile.IKE = $True
                $FirewallLogSelfProfile.Multicast = $True
                $FirewallLogSelfProfile.SNMP = $True
            } else {
                $FirewallLogSelfProfile.ICMP = $False
                $FirewallLogSelfProfile.IKE = $False
                $FirewallLogSelfProfile.Multicast = $False
                $FirewallLogSelfProfile.SNMP = $False
                $traffic_type_list | foreach {
                    switch($_) {
                        'icmp' { $FirewallLogSelfProfile.ICMP = $True }
                        'ike' { $FirewallLogSelfProfile.IKE = $True }
                        'multicast' { $FirewallLogSelfProfile.Multicast = $True }
                        'snmp' { $FirewallLogSelfProfile.SNMP = $True }
                        default {
                            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
                        }
                    }
                }
            }
        }
        default {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    }
}

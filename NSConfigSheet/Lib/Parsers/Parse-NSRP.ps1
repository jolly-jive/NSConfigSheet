Function Parse-ROOT-Set-NSRP
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($NSRPProfile -eq $Null) {
        $script:NSRPProfile = New-Object NSRPProfile
    }

    if(PhraseMatch $params 'auth','password' -prefix) {
        $NSRPProfile.AuthenticationPassword = $params[2]
    } elseif(PhraseMatch $params 'cluster' -prefix) {
        if(PhraseMatch $params 'id',$RE_INTEGER -offset 1) {
            $NSRPProfile.ID = [int]$params[2]
        } elseif(PhraseMatch $params 'name',$Null -offset 1) {
            $NSRPProfile.Name = $params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'encrypt','password' -prefix) {
        $NSRPProfile.EncryptionPassword = $params[2]
    } elseif(PhraseMatch $params 'rto-mirror' -prefix) {
        if(PhraseMatch $params 'sync' -offset 1) {
            New-ObjectUnlessDefined ([ref]$NSRPProfile) RTOSynchronization
        } elseif(PhraseMatch $params 'hb-interval',$RE_INTEGER -offset 1) {
            $NSRPProfile.RTOSynchronization.Interval = [int]$params[3]
        } elseif(PhraseMatch $params 'hb-threshold',$RE_INTEGER -offset 1) {
            $NSRPProfile.RTOSynchronization.Threshold = [int]$params[3]
        } elseif(PhraseMatch $params 'id',$RE_INTEGER -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'route',$RE_INTEGER -offset 1 -prefix) {
            New-ObjectUnlessDefined ([ref]$NSRPProfile) RouteSynchronization
            if($params.Count -eq 3) {
                # do nothing
            } elseif(PhraseMatch $paams 'threshold',$RE_INTEGER -offset 3) {
                $NSRPProfile.RouteSynchronization.Threshold = [int]$params[5]
            } else {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
        } elseif(PhraseMatch $params 'session' -offset 1 -prefix) {
            if(PhraseMatch $params 'ageout-ack' -offset 2) {
                $NSRPProfile.RTOSynchronization.BackupSessionTimeoutAcknowledge = $True
            } elseif(PhraseMatch $params 'non-vsi' -offset 2) {
                $NSRPProfile.RTOSynchronization.NonVSISessionSynchronization = $True
            } elseif(PhraseMatch $params 'off' -offset 2) {
                Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
            } else {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'vsd-group' -prefix) {
        if(PhraseMatch $params 'master-always-exist' -offset 1 -prefix) {
            $NSRPProfile.VSDMasterAlwaysExist = $True
        } elseif(PhraseMatch $params 'hb-interval' -offset 1) {
            $NSRPProfile.VSDInitialStateHoldDownTime = [int]$params[2]
        } elseif(PhraseMatch $params 'hb-threshold' -offset 1 -prefix) {
            $NSRPProfile.VSDLostHeartbeatThreshold = [int]$params[2]
        } elseif(PhraseMatch $params 'init-hold' -offset 1 -prefix) {
            $NSRPProfile.VSDInitialStateHoldDownTime = [int]$params[2]
        } elseif(PhraseMatch $params 'id',$RE_INTEGER -offset 1 -prefix) {
            $id = [int]$params[2]
            if(-not $NSRPProfile.VSDGroup.Contains($id)) {
                $NSRPProfile.VSDGroup[$id] = New-Object VSDGroup($id)
            }
            if(PhraseMatch $params 'preempt' -offset 3) {
                $NSRPProfile.VSDGroup[$id].Preempt = $True
                if(PhraseMatch $params 'hold-down',$RE_INTEGER -prefix 4) {
                    $NSRPProfile.VSDGroup[$id].PreemptHoldDownTime = [int]$params[5]
                }
            } elseif(PhraseMatch $params 'mode','ineligible' -offset 3) {
                $NSRPProfile.VSDGroup[$id].Mode = 'Ineligible'
            } elseif(PhraseMatch $params 'priority',$RE_INTEGER -offset 3) {
                $NSRPProfile.VSDGroup[$id].Priority = [int]$params[4]
            }
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'secondary-path',$RE_INTERFACE_NAME) {
        $NSRPProfile.SecondaryLink = $last_matches[0]['INTERFACE_NAME']
    } elseif(PhraseMatch $params 'monitor','interface',$RE_INTERFACE_NAME -prefix) {
        $interface_name = $last_matches[0]['INTERFACE_NAME']
        if(-not $NSRPProfile.MonitorInterface.Contains($interface_name)) {
            $NSRPProfile.MonitorInterface[$interface_name] = New-Object MonitorElement
            $NSRPProfile.MonitorInterface[$interface_name].Name = $interface_name
        }
        if(PhraseMatch $params 'weight',$RE_INTEGER -offset 3) {
            $NSRPProfile.MonitorInterface[$interface_name].Weight = [int]$params[4]
        }
    } elseif(PhraseMatch $params 'monitor','zone',$RE_QUOTED_NAME -prefix) {
        $zone_name = $last_matches[0]['QUOTED_NAME']
        if(-not $NSRPProfile.MonitorZone.Contains($zone_name)) {
            $NSRPProfile.MonitorZone[$zone_name] = New-Object MonitorElement
            $NSRPProfile.MonitorZone[$zone_name].Name = $zone_name
        }
        if(PhraseMatch $params 'weight',$RE_INTEGER -offset 3) {
            $NSRPProfile.MonitorZone[$zone_name].Weight = [int]$params[4]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'monitor','track-ip' -prefix) {
        if(PhraseMatch $params 'ip' -offset 2 -prefix) {
            if($params.Count -eq 3) {
                $NSRPProfile.MonitorTrackIPEnabled = $True
            } elseif(PhraseMatch $params $RE_IPV4_HOST_ADDRESS -offset 3 -prefix) {
                $ip_addr = $last_matches[0]['IPV4_HOST_ADDRESS']
                if(-not $NSRPProfile.MonitorTrackIP.Contains($ip_addr)) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr] = New-Object MonitorTrackIP
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Name = $ip_addr
                }

                if(PhraseMatch $params 'interface',$RE_INTERFACE_NAME -offset 4) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Interface = $last_matches[0]['INTERFACE_NAME']
                } elseif(PhraseMatch $params 'interval',$RE_INTEGER -offset 4) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Interval = [int]$params[5]
                } elseif(PhraseMatch $params 'method',$RE_NSRP_METHOD -offset 4) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Method = $params[5]
                } elseif(PhraseMatch $params 'threshold',$RE_INTEGER -offset 4) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Threshold = [int]$params[5]
                } elseif(PhraseMatch $params 'weight',$RE_INTEGER -offset 4) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Weight = [int]$params[5]
                } else {
                    throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
                }
            } else {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
        } elseif(PhraseMatch $params 'threshold',$RE_INTEGER -offset 2) {
            $NSRPProfile.MonitorTrackThreshold = [int]$params[3]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-NSRP
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($NSRPProfile -eq $Null) {
        $script:NSRPProfile = New-Object NSRPProfile
    }

    if(PhraseMatch $params 'auth','password') {
        $NSRPProfile.AuthenticationPassword = $Null
    } elseif(PhraseMatch $params 'cluster','id',$RE_INTEGER) {
        $NSRPProfile.ID = $null
    } elseif(PhraseMatch $params 'encrypt','password') {
        $NSRPProfile.EncryptionPassword = $Null
    } elseif(PhraseMatch $params 'rto-mirror' -prefix) {
        if(PhraseMatch $params 'sync' -offset 1) {
            $NSRPProfile.RTOSynchronization -eq $Null
        } elseif(PhraseMatch $params 'hb-interval' -offset 1) {
            $NSRPProfile.RTOSynchronization.Interval = $Null
        } elseif(PhraseMatch $params 'hb-threshold' -offset 1) {
            $NSRPProfile.RTOSynchronization.Threshold = $Null
        } elseif(PhraseMatch $params 'id',$RE_INTEGER -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'route' -offset 1 -prefix) {
            $NSRPProfile.RouteSynchronization = $Null
        } elseif(PhraseMatch $params 'session','ageout-ack' -offset 1) {
            $NSRPProfile.RTOSynchronization.BackupSessionTimeoutAcknowledge = $False
        } elseif(PhraseMatch $params 'session','non-vsi' -offset 1) {
            $NSRPProfile.RTOSynchronization.NonVSISessionSynchronization = $False
        } elseif(PhraseMatch $params 'session','off' -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'vsd-group' -prefix) {
        if(PhraseMatch $params 'master-always-exist' -offset 1 -prefix) {
            $NSRPProfile.VSDMasterAlwaysExist = $False
        } elseif(PhraseMatch $params 'hb-interval' -offset 1) {
            $NSRPProfile.VSDInitialStateHoldDownTime = $Null
        } elseif(PhraseMatch $params 'hb-threshold' -offset 1) {
            $NSRPProfile.VSDLostHeartbeatThreshold = $Null
        } elseif(PhraseMatch $params 'init-hold' -offset 1) {
            $NSRPProfile.VSDInitialStateHoldDownTime = $Null
        } elseif(PhraseMatch $params 'id',$RE_INTEGER -offset 1 -prefix) {
            $id = [int]$params[2]
            if($NSRPProfile.VSDGroup.Contains($id)) {
                if(PhraseMatch $params 'preempt' -offset 3) {
                    $NSRPProfile.VSDGroup[$id].Preempt = $False
                    $NSRPProfile.VSDGroup[$id].PreemptHoldDownTime = $null
                } elseif(PhraseMatch $params 'mode','ineligible' -offset 3) {
                    $NSRPProfile.VSDGroup[$id].Mode = $Null
                } else {
                    throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
                }
            } else {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'secondary-path') {
        $NSRPProfile.SecondaryLink = $Null
    } elseif(PhraseMatch $params 'monitor','interface',$RE_INTERFACE_NAME) {
        $interface_name = $last_matches[0]['INTERFACE_NAME']
        if($NSRPProfile.MonitorInterface.Contains($interface_name)) {
            $NSRPProfile.MonitorInterface.Remove($interface_name)
        } else {
            throw "NSRP Monitor Interface $interface_name does not exist @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'monitor','zone',$RE_QUOTED_NAME) {
        $zone_name = $last_matches[0]['QUOTED_NAME']
        if(-not $NSRPProfile.MonitorZone.Contains($zone_name)) {
            $NSRPProfile.MonitorZone.Remove($zone_name)
        } else {
            throw "NSRP Monitor zone $zone_name does not exist @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'monitor','track-ip' -prefix) {
        if(PhraseMatch $params 'ip' -offset 2 -prefix) {
            if($params.Count -eq 3) {
                $NSRPProfile.MonitorTrackIPEnabled = $False
            } elseif(PhraseMatch $params $RE_IPV4_HOST_ADDRESS -offset 3 -prefix) {
                $ip_addr = $last_matches[0]['IPV4_HOST_ADDRESS']
                if(-not $NSRPProfile.MonitorTrackIP.Contains($ip_addr)) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr] = New-Object MonitorTrackIP
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Name = $ip_addr
                }

                if(PhraseMatch $params 'interface' -offset 4) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Interface = $Null
                } elseif(PhraseMatch $params 'interval' -offset 4) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Interval = $Null
                } elseif(PhraseMatch $params 'method' -offset 4) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Method = $Null
                } elseif(PhraseMatch $params 'threshold' -offset 4) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Threshold = $Null
                } elseif(PhraseMatch $params 'weight' -offset 4) {
                    $NSRPProfile.MonitorTrackIP[$ip_addr].Weight = $Null
                } else {
                    throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
                }
            } else {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
        } elseif(PhraseMatch $params 'threshold' -offset 2) {
            $NSRPProfile.MonitorTrackThreshold = $Null
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Set-Screen
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $zone_name
    )

    [ScreeningProfile]$screening_profile = $Null
    if(-not $ScreeningDic.Contains($zone_name)) {
        $screening_profile = New-Object ScreeningProfile
        [ScreeningProfile]$ScreeningDic[$zone_name] = $screening_profile
        $screening_profile.Zone = $zone_name
    } else {
        $screening_profile = $ScreeningDic[$zone_name]
    }

    if(PhraseMatch $params 'alarm-without-drop') {
        $screening_profile.AlarmWithoutDrop = $True

    } elseif(PhraseMatch $params 'block-frag') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.BlockFragmentTraffic = $True

    } elseif(PhraseMatch $params 'component-block' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) BlockHTTPComponents
        if(PhraseMatch $params 'activex' -offset 1) {
            $screening_profile.BlockHTTPComponents.ActiveX = $True
        } elseif(PhraseMatch $params 'java' -offset 1) {
            $screening_profile.BlockHTTPComponents.Java = $True
        } elseif(PhraseMatch $params 'zip' -offset 1) {
            $screening_profile.BlockHTTPComponents.ZIP = $True
        } elseif(PhraseMatch $params 'exe' -offset 1) {
            $screening_profile.BlockHTTPComponents.EXE = $True
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'fin-no-ack') {
        New-ObjectUnlessDefined ([ref]$screening_profile) TCPIPAnomalies
        $screening_profile.TCPIPAnomalies.FINwithNoACK = $True

    } elseif(PhraseMatch $params 'icmp-flood' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) FloodDefense
        if($screening_profile.FloodDefense.ICMPFlood -eq $Null) {
            $screening_profile.FloodDefense.ICMPFlood = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $screening_profile.FloodDefense.ICMPFlood.Enabled = $True
        } elseif(PhraseMatch $params 'threshold',$RE_INTEGER -offset 1) {
            $screening_profile.FloodDefense.ICMPFlood.Threshold = [int]$params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'icmp-fragment') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.ICMPFragment = $True

    } elseif(PhraseMatch $params 'icmp-large') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.LargeSizeICMPPacket = $True

    } elseif(PhraseMatch $params 'ip-bad-option') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.BadIP = $True

    } elseif(PhraseMatch $params 'ip-filter-src') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPFilterSrc = $True

    } elseif(PhraseMatch $params 'ip-loose-src-route') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPLooseSource = $True

    } elseif(PhraseMatch $params 'ip-record-route') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPRecordRoute = $True

    } elseif(PhraseMatch $params 'ip-security-opt') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPSecurity = $True

    } elseif(PhraseMatch $params 'ip-spoofing' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) ScanSpoofSweepDefense
        if($screening_profile.ScanSpoofSweepDefense.IPSpoofProtection -eq $Null) {
            $screening_profile.ScanSpoofSweepDefense.IPSpoofProtection = New-Object IPSpoofProtection($Null,$Null,$Null)
        }

        if($params.Count -eq 1) {
            $screening_profile.ScanSpoofSweepDefense.IPSpoofProtection.Enabled = $True
        } elseif(PhraseMatch $params 'drop-no-rpf-route' -offset 1) {
            $screening_profile.ScanSpoofSweepDefense.IPSpoofProtection.DropIfNoReversePathRouteFound = $True
        } elseif(PhraseMatch $params 'zone-based' -offset 1) {
            $screening_profile.ScanSpoofSweepDefense.IPSpoofProtection.BasedOnZone =  $True
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'ip-stream-opt') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPStream = $True

    } elseif(PhraseMatch $params 'ip-strict-src-route') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPStrictSourceRoute = $True

    } elseif(PhraseMatch $params 'ip-sweep' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) ScanSpoofSweepDefense
        if($screening_profile.ScanSpoofSweepDefense.IPAddressSweep -eq $Null) {
            $screening_profile.ScanSpoofSweepDefense.IPAddressSweep = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $screening_profile.ScanSpoofSweepDefense.IPAddressSweep.Enabled = $True
        } elseif(PhraseMatch $params 'threshold',$RE_INTEGER -offset 1) {
            $screening_profile.ScanSpoofSweepDefense.IPAddressSweep.Threshold = [int]$params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'ip-timestamp-opt') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPTimestamp = $True

    } elseif(PhraseMatch $params 'land') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.Land = $True

    } elseif(PhraseMatch $params 'limit-session' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        if(PhraseMatch $params 'source-ip-based' -offset 1 -prefix) {
            if($screening_profile.DenialOfServiceDefense.SourceIPBasedSessionLimit -eq $null) {
                $screening_profile.DenialOfServiceDefense.SourceIPBasedSessionLimit = New-Object ScreeningElementWithThreshold($Null,$Null)
            }

            if($params.Count -eq 2) {
                $screening_profile.DenialOfServiceDefense.SourceIPBasedSessionLimit.Enabled = $True
            } elseif(PhraseMatch $params $RE_INTEGER -offset 2) {
                $screening_profile.DenialOfServiceDefense.SourceIPBasedSessionLimit.Threshold = [int]$params[2]
            } else {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }

        } elseif(PhraseMatch $params 'destination-ip-based' -offset 1 -prefix) {
            if($screening_profile.DenialOfServiceDefense.DestinationIPBasedSessionLimit -eq $null) {
                $screening_profile.DenialOfServiceDefense.DestinationIPBasedSessionLimit = New-Object ScreeningElementWithThreshold($Null,$Null)
            }

            if($params.Count -eq 2) {
                $screening_profile.DenialOfServiceDefense.DestinationIPBasedSessionLimit.Enabled = $True
            } elseif(PhraseMatch $params $RE_INTEGER -offset 2) {
                $screening_profile.DenialOfServiceDefense.DestinationIPBasedSessionLimit.Threshold = [int]$params[2]
            } else {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }

        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }


    } elseif(PhraseMatch $params 'mal-url' -prefix) {
        if(PhraseMatch $params 'code-red' -offset 1 -prefix) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params $RE_INTEGER -offset 3) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'on-tunnel') {
        if($screening_profile.OnTunnel -eq $Null) {
            $screening_profile.OnTunnel = New-Object ScreeningElement($True)
        }
        $screening_profile.OnTunnel.Enabled = $True

    } elseif(PhraseMatch $params 'ping-death') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.PingDeath = $True

    } elseif(PhraseMatch $params 'port-scan' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) ScanSpoofSweepDefense
        if($screening_profile.ScanSpoofSweepDefense.PortScan -eq $Null) {
            $screening_profile.ScanSpoofSweepDefense.PortScan = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $screening_profile.ScanSpoofSweepDefense.PortScan.Enabled = $True
        } elseif(PhraseMatch $params 'threshold',$RE_INTEGER -offset 1) {
            $screening_profile.ScanSpoofSweepDefense.PortScan.Threshold = [int]$params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'syn-ack-ack-proxy' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) FloodDefense
        if($screening_profile.FloodDefense.SYNACKACKProxy -eq $Null) {
            $screening_profile.FloodDefense.SYNACKACKProxy = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $screening_profile.FloodDefense.SYNACKACKProxy.Enabled = $True
        } elseif(PhraseMatch $params 'threshold',$RE_INTEGER -offset 1) {
            $screening_profile.FloodDefense.SYNACKACKProxy.Threshold = [int]$params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'syn-fin') {
        New-ObjectUnlessDefined ([ref]$screening_profile) TCPIPAnomalies
        $screening_profile.TCPIPAnomalies.SYNandFINSet = $True

    } elseif(PhraseMatch $params 'syn-flood' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) FloodDefense
        if($screening_profile.FloodDefense.SYNFlood -eq $Null) {
            $screening_profile.FloodDefense.SYNFlood = New-Object SYNFlood($True)
        }

        if($params.Count -eq 1) {
            $screening_profile.FloodDefense.SYNFlood.Enabled = $True
        } elseif(PhraseMatch  $params 'alarm-threshold',$RE_INTEGER -offset 1) {
            $screening_profile.FloodDefense.SYNFlood.AlarmThreshold = [int]$params[2]
        } elseif(PhraseMatch $params 'attack-threshold',$RE_INTEGER -offset 1 -prefix) {
            $screening_profile.FloodDefense.SYNFlood.AttackThreshold = [int]$params[2]
        } elseif(PhraseMatch $params 'destination-threshold',$RE_INTEGER -offset 1 -prefix) {
            $screening_profile.FloodDefense.SYNFlood.DestinationThreshold = [int]$params[2]
        } elseif(PhraseMatch $params 'drop-unknown-mac' -offset 1) {
            $screening_profile.FloodDefense.SYNFlood.DropUnknownMAC = $True
        } elseif(PhraseMatch $params 'queue-size',$RE_INTEGER -offset 1) {
            $screening_profile.FloodDefense.SYNFlood.QueueSize = [int]$params[2]
        } elseif(PhraseMatch $params 'source-threshold',$RE_INTEGER -offset 1 -prefix) {
            $screening_profile.FloodDefense.SYNFlood.SourceThreshold = [int]$params[2]
        } elseif(PhraseMatch  $params 'timeout',$RE_INTEGER -offset 1) {
            $screening_profile.FloodDefense.SYNFlood.Timeout = [int]$params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'syn-frag') {
        New-ObjectUnlessDefined ([ref]$screening_profile) TCPIPAnomalies
        $screening_profile.TCPIPAnomalies.SYNFragment = $True

    } elseif(PhraseMatch $params 'tcp-no-flag') {
        New-ObjectUnlessDefined ([ref]$screening_profile) TCPIPAnomalies
        $screening_profile.TCPIPAnomalies.TCPPacketWithoutFlag = $True

    } elseif(PhraseMatch $params 'tcp-sweep' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) ScanSpoofSweepDefense
        if($screening_profile.ScanSpoofSweepDefense.TCPSweep -eq $Null) {
            $screening_profile.ScanSpoofSweepDefense.TCPSweep = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $screening_profile.ScanSpoofSweepDefense.TCPSweep.Enabled = $True
        } elseif(PhraseMatch $params 'threshold',$RE_INTEGER -offset 1) {
            $screening_profile.ScanSpoofSweepDefense.TCPSweep.Threshold = [int]$params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'tear-drop') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.TearDrop = $True

    } elseif(PhraseMatch $params 'udp-flood' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) FloodDefense
        if($screening_profile.FloodDefense.UDPFlood -eq $Null) {
            $screening_profile.FloodDefense.UDPFlood = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $screening_profile.FloodDefense.UDPFlood.Enabled = $True
        } elseif(PhraseMatch $params 'dst-ip',$RE_IPV4_HOST_ADDRESS -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'threshold',$RE_INTEGER -offset 1) {
            $screening_profile.FloodDefense.UDPFlood.Threshold = [int]$params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'udp-sweep' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) ScanSpoofSweepDefense
        if($screening_profile.ScanSpoofSweepDefense.UDPSweep -eq $Null) {
            $screening_profile.ScanSpoofSweepDefense.UDPSweep = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $screening_profile.ScanSpoofSweepDefense.UDPSweep.Enabled = $True
        } elseif(PhraseMatch $params 'threshold',$RE_INTEGER -offset 1) {
            $screening_profile.ScanSpoofSweepDefense.UDPSweep.Threshold = [int]$params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'unknown-protocol') {
        New-ObjectUnlessDefined ([ref]$screening_profile) TCPIPAnomalies
        $screening_profile.TCPIPAnomalies.UnknownProtocol = $True

    } elseif(PhraseMatch $params 'winnuke') {
        New-ObjectUnlessDefined ([ref]$screening_profile) MSWindowsDefense
        $screening_profile.MSWindowsDefense.WinNuke = $True

    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-Screen
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $zone_name
    )

    if($params.Count -eq 0 -and $ScreeningDic.Contains($zone_name)) {
        $ScreeningDic.Remove($zone_name)
        return
    }

    [ScreeningProfile]$screening_profile = $Null
    if(-not $ScreeningDic.Contains($zone_name)) {
        $screening_profile = New-Object ScreeningProfile
        [ScreeningProfile]$ScreeningDic[$zone_name] = $screening_profile
        $screening_profile.Zone = $zone_name
    } else {
        $screening_profile = $ScreeningDic[$zone_name]
    }

    if(PhraseMatch $params 'alarm-without-drop') {
        $screening_profile.AlarmWithoutDrop = $False

    } elseif(PhraseMatch $params 'block-frag') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.BlockFragmentTraffic = $False

    } elseif(PhraseMatch $params 'component-block' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) BlockHTTPComponents
        if(PhraseMatch $params 'activex' -offset 1) {
            $screening_profile.BlockHTTPComponents.ActiveX = $False
        } elseif(PhraseMatch $params 'java' -offset 1) {
            $screening_profile.BlockHTTPComponents.Java = $False
        } elseif(PhraseMatch $params 'zip' -offset 1) {
            $screening_profile.BlockHTTPComponents.ZIP = $False
        } elseif(PhraseMatch $params 'exe' -offset 1) {
            $screening_profile.BlockHTTPComponents.EXE = $False
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'fin-no-ack') {
        New-ObjectUnlessDefined ([ref]$screening_profile) TCPIPAnomalies
        $screening_profile.TCPIPAnomalies.FINwithNoACK = $False

    } elseif(PhraseMatch $params 'icmp-flood') {
        New-ObjectUnlessDefined ([ref]$screening_profile) FloodDefense
        if($screening_profile.FloodDefense.ICMPFlood -eq $Null) {
            $screening_profile.FloodDefense.ICMPFlood = New-Object ScreeningElementWithThreshold($False,$Null)
        } else {
            $screening_profile.FloodDefense.ICMPFlood.Enabled = $False
        }

    } elseif(PhraseMatch $params 'icmp-fragment') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.ICMPFragment = $False

    } elseif(PhraseMatch $params 'icmp-large') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.LargeSizeICMPPacke = $False

    } elseif(PhraseMatch $params 'ip-bad-option') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.BadIP = $False

    } elseif(PhraseMatch $params 'ip-filter-src') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPFilterSrc = $False

    } elseif(PhraseMatch $params 'ip-loose-src-route') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPLooseSource = $False

    } elseif(PhraseMatch $params 'ip-record-route') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPRecordRoute = $False

    } elseif(PhraseMatch $params 'ip-security-opt') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPSecurity = $False

    } elseif(PhraseMatch $params 'ip-spoofing' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) ScanSpoofSweepDefense
        if($screening_profile.ScanSpoofSweepDefense.IPSpoofProtection -eq $Null) {
            $screening_profile.ScanSpoofSweepDefense.IPSpoofProtection = New-Object IPSpoofProtection($Null,$Null,$Null)
        }

        if($params.Count -eq 1) {
            $screening_profile.ScanSpoofSweepDefense.IPSpoofProtection.Enabled = $False
        } elseif(PhraseMatch $params 'drop-no-rpf-route' -offset 1) {
            $screening_profile.ScanSpoofSweepDefense.IPSpoofProtection.DropIfNoReversePathRouteFound = $False
        } elseif(PhraseMatch $params 'zone-based' -offset 1) {
            $screening_profile.ScanSpoofSweepDefense.IPSpoofProtection.BasedOnZone =  $False
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'ip-stream-opt') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPStream = $False

    } elseif(PhraseMatch $params 'ip-strict-src-route') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPStrictSourceRoute = $False

    } elseif(PhraseMatch $params 'ip-sweep') {
        New-ObjectUnlessDefined ([ref]$screening_profile) ScanSpoofSweepDefense
        if($screening_profile.ScanSpoofSweepDefense.IPAddressSweep -eq $Null) {
            $screening_profile.ScanSpoofSweepDefense.IPAddressSweep = New-Object ScreeningElementWithThreshold($False,$Null)
        } else {
            $screening_profile.ScanSpoofSweepDefense.IPAddressSweep.Enabled = $False
        }

    } elseif(PhraseMatch $params 'ip-timestamp-opt') {
        New-ObjectUnlessDefined ([ref]$screening_profile) IPOptionAnomalies
        $screening_profile.IPOptionAnomalies.IPTimestamp = $False

    } elseif(PhraseMatch $params 'land') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.Land = $False

    } elseif(PhraseMatch $params 'limit-session' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        if(PhraseMatch $params 'source-ip-based' -offset 1) {
            if($screening_profile.DenialOfServiceDefense.SourceIPBasedSessionLimit -eq $null) {
                $screening_profile.DenialOfServiceDefense.SourceIPBasedSessionLimit = New-Object ScreeningElementWithThreshold($Null,$Null)
            }

            $screening_profile.DenialOfServiceDefense.SourceIPBasedSessionLimit.Enabled = $False

        } elseif(PhraseMatch $params 'destination-ip-based' -offset 1) {
            if($screening_profile.DenialOfServiceDefense.DestinationIPBasedSessionLimit -eq $null) {
                $screening_profile.DenialOfServiceDefense.DestinationIPBasedSessionLimit = New-Object ScreeningElementWithThreshold($Null,$Null)
            }

            $screening_profile.DenialOfServiceDefense.DestinationIPBasedSessionLimit.Enabled = $False

        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'mal-url' -prefix) {
        if(PhraseMatch $params 'code-red' -offset 1 -prefix) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params $RE_INTEGER -offset 3) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'on-tunnel') {
        if($screening_profile.OnTunnel -eq $Null) {
            $screening_profile.OnTunnel = New-Object ScreeningElement($False)
        }
        $screening_profile.OnTunnel.Enabled = $False

    } elseif(PhraseMatch $params 'ping-death') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.PingDeath = $False

    } elseif(PhraseMatch $params 'port-scan') {
        New-ObjectUnlessDefined ([ref]$screening_profile) ScanSpoofSweepDefense
        if($screening_profile.ScanSpoofSweepDefense.PortScan -eq $Null) {
            $screening_profile.ScanSpoofSweepDefense.PortScan = New-Object ScreeningElementWithThreshold($False,$Null)
        } else {
            $screening_profile.ScanSpoofSweepDefense.PortScan.Enabled = $False
        }

    } elseif(PhraseMatch $params 'syn-ack-ack-proxy') {
        New-ObjectUnlessDefined ([ref]$screening_profile) FloodDefense
        if($screening_profile.FloodDefense.SYNACKACKProxy -eq $Null) {
            $screening_profile.FloodDefense.SYNACKACKProxy = New-Object ScreeningElementWithThreshold($False,$Null)
        } else {
            $screening_profile.FloodDefense.SYNACKACKProxy.Enabled = $False
        }

    } elseif(PhraseMatch $params 'syn-fin') {
        New-ObjectUnlessDefined ([ref]$screening_profile) TCPIPAnomalies
        $screening_profile.TCPIPAnomalies.SYNandFINSet = $False

    } elseif(PhraseMatch $params 'syn-flood' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) FloodDefense
        if($screening_profile.FloodDefense.SYNFlood -eq $Null) {
            $screening_profile.FloodDefense.SYNFlood = New-Object SYNFlood($True)
        }
        if($params.Count -eq 1) {
            $screening_profile.FloodDefense.SYNFlood.Enabled = $False
        } elseif(PhraseMatch  $params 'alarm-threshold' -offset 1 -prefix) {
            $screening_profile.FloodDefense.SYNFlood.AlarmThreshold = $Null
        } elseif(PhraseMatch $params 'attack-threshold' -offset 1 -prefix) {
            $screening_profile.FloodDefense.SYNFlood.AttackThreshold = $Null
        } elseif(PhraseMatch $params 'destination-threshold' -offset 1 -prefix) {
            $screening_profile.FloodDefense.DestinationThreshold = $Null
        } elseif(PhraseMatch $params -ieq 'drop-unknown-mac' -offset 1) {
            $screening_profile.FloodDefense.DropUnknownMAC = $False
        } elseif(PhraseMatch $params 'queue-size' -offset 1 -prefix) {
            $screening_profile.FloodDefense.QueueSize = $Null
        } elseif(PhraseMatch $params 'source-threshold' -offset 1 -prefix) {
            $screening_profile.FloodDefense.SourceThreshold = $Null
        } elseif(PhraseMatch  $params 'timeout' -offset 1 -prefix) {
            $screening_profile.FloodDefense.Timeout = $Null
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'syn-frag') {
        New-ObjectUnlessDefined ([ref]$screening_profile) TCPIPAnomalies
        $screening_profile.TCPIPAnomalies.SYNFragment = $False

    } elseif(PhraseMatch $params 'tcp-no-flag') {
        New-ObjectUnlessDefined ([ref]$screening_profile) TCPIPAnomalies
        $screening_profile.TCPIPAnomalies.TCPPacketWithoutFlag = $False

    } elseif(PhraseMatch $params 'tcp-sweep') {
        New-ObjectUnlessDefined ([ref]$screening_profile) ScanSpoofSweepDefense
        if($screening_profile.ScanSpoofSweepDefense.TCPSweep -eq $Null) {
            $screening_profile.ScanSpoofSweepDefense.TCPSweep = New-Object ScreeningElementWithThreshold($False,$Null)
        } else {
            $screening_profile.ScanSpoofSweepDefense.TCPSweep.Enabled = $False
        }

    } elseif(PhraseMatch $params 'tear-drop') {
        New-ObjectUnlessDefined ([ref]$screening_profile) DenialOfServiceDefense
        $screening_profile.DenialOfServiceDefense.TearDrop = $False

    } elseif(PhraseMatch $params 'udp-flood' -prefix) {
        New-ObjectUnlessDefined ([ref]$screening_profile) FloodDefense
        if($screening_profile.FloodDefense.UDPFlood -eq $Null) {
            $screening_profile.FloodDefense.UDPFlood = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $screening_profile.FloodDefense.UDPFlood.Enabled = $False
        } elseif(PhraseMatch $params 'dst-ip',$RE_IPV4_HOST_ADDRESS -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'threshold',$RE_INTEGER -offset 1) {
            $screening_profile.FloodDefense.UDPFlood.Threshold = $Null
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'udp-sweep') {
        New-ObjectUnlessDefined ([ref]$screening_profile) ScanSpoofSweepDefense
        if($screening_profile.ScanSpoofSweepDefense.UDPSweep -eq $Null) {
            $screening_profile.ScanSpoofSweepDefense.UDPSweep = New-Object ScreeningElementWithThreshold($False,$Null)
        } else {
            $screening_profile.ScanSpoofSweepDefense.UDPSweep.Enabled = $False
        }

    } elseif(PhraseMatch $params 'unknown-protocol') {
        New-ObjectUnlessDefined ([ref]$screening_profile) TCPIPAnomalies
        $screening_profile.TCPIPAnomalies.UnknownProtocol = $False

    } elseif(PhraseMatch $params 'winnuke') {
        New-ObjectUnlessDefined ([ref]$screening_profile) MSWindowsDefense
        $screening_profile.MSWindowsDefense.WinNuke = $False

    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Set-Flow
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($FlowProfile -eq $Null) {
        $script:FlowProfile = New-Object FlowProfile
    }

    if(PhraseMatch $params 'aging' -prefix) {
        New-ObjectUnlessDefined ([ref]$FlowProfile) AggressiveAging

        if(PhraseMatch $params 'early-ageout',$RE_INTEGER -offset 1) {
            $FlowProfile.AggressiveAging.EarlyAgeout = $params[2]
        } elseif(PhraseMatch $params 'high-watermark',$RE_INTEGER -offset 1) {
            $FlowProfile.AggressiveAging.HighWatermark = $params[2]
        } elseif(PhraseMatch $params 'low-watermark',$RE_INTEGER -offset 1) {
            $FlowProfile.AggressiveAging.LowWatermark = $params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'allow-dns-reply') {
        $FlowProfile.AllowDNSReply = $True
    } elseif(PhraseMatch $params 'all-tcp-mss' -prefix) {
        if($FlowProfile.AllTCPMSS -eq $Null) {
            $FlowProfile.AllTCPMSS = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $FlowProfile.AllTCPMSS.Enabled = $True
        } elseif(PhraseMatch $params $RE_INTEGER -offset 1) {
            $FlowProfile.AllTCPMSS.Threshold = [int]$params[1]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'check','tcp-rst-sequence') {
        $FlowProfile.CheckTCPRSTSequence = $True
    } elseif(PhraseMatch $params 'force-ip-reassembly') {
        $FlowProfile.ForceIPReassembly = $True
    } elseif(PhraseMatch $params 'gre-in-tcp-mss') {
        if($FlowProfile.GREInTCPMSS -eq $Null) {
            $FlowProfile.GREInTCPMSS = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $FlowProfile.GREInTCPMSS.Enabled = $True
        } elseif(PhraseMatch $params $RE_INTEGER -offset 1) {
            $FlowProfile.GREInTCPMSS.Threshold = [int]$params[1]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'gre-out-tcp-mss') {
        if($FlowProfile.GREOutTCPMSS -eq $Null) {
            $FlowProfile.GREOutTCPMSS = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $FlowProfile.GREOutTCPMSS.Enabled = $True
        } elseif(PhraseMatch $params $RE_INTEGER -offset 1) {
            $FlowProfile.GREOutTCPMSS.Threshold = [int]$params[1]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'hub-n-spoke-mip') {
        $FlowProfile.HubNSpokeMIP = $True
    } elseif(PhraseMatch $params 'initial-timeout',$RE_INTEGER) {
        $FlowProfile.InitialTimeout = [int]$params[1]
    } elseif(PhraseMatch $params 'icmp-ur-msg-filter') {
        $FlowProfile.ICMPURMSGFilter = $True
    } elseif(PhraseMatch $params 'icmp-ur-session-close') {
        $FlowProfile.ICMPURSessionClose = $True
    } elseif(PhraseMatch $params 'mac-cache','mgt') {
        $FlowProfile.MACCacheMGT = $True
    } elseif(PhraseMatch $params 'mac-flooding') {
        $FlowProfile.MACFlooding = $True
    } elseif(PhraseMatch $params 'max-frag-pkt-size',$RE_INTEGER) {
        $FlowProfile.MaxFragPktSize = [int]$params[1]
    } elseif(PhraseMatch $params 'multicast','idp') {
        $FlowProfile.MulticastIDP = $True
    } elseif(PhraseMatch $params 'multicast','install-hw-session') {
        $FlowProfile.MulticastInstallHWSession = $True
    } elseif(PhraseMatch $params 'no-tcp-seq-check') {
        $FlowProfile.NoTCPSeqCheck = $True
    } elseif(PhraseMatch $params 'path-mtu') {
        $FlowProfile.PathMTU = $True
    } elseif(PhraseMatch $params 'reverse-route','clear-text','always') {
        $FlowProfile.ReverseRouteClearText = 'Always'
    } elseif(PhraseMatch $params 'reverse-route','clear-text','prefer') {
        $FlowProfile.ReverseRouteClearText = 'Prefer'
    } elseif(PhraseMatch $params 'reverse-route','tunnel','always') {
        $FlowProfile.ReverseRouteTunnel = 'Always'
    } elseif(PhraseMatch $params 'reverse-route','tunnel','prefer') {
        $FlowProfile.ReverseRouteTunnel = 'Prefer'
    } elseif(PhraseMatch $params 'route-cache') {
        $FlowProfile.RouteCache = $True
    } elseif(PhraseMatch $params 'route-change-timeout',$RE_INTEGER) {
        $FlowProfile.RouteChangeTimeout = [int]$params[1]
    } elseif(PhraseMatch $params 'syn-proxy','syn-cookie') {
        $FlowProfile.TCPSYNProxySYNCookie = $True
    } elseif(PhraseMatch $params 'tcp-mss' -prefix) {
        if($FlowProfile.TCPMSS -eq $Null) {
            $FlowProfile.TCPMSS = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $FlowProfile.TCPMSS.Enabled = $True
        } elseif(PhraseMatch $params $RE_INTEGER -offset 1) {
            $FlowProfile.TCPMSS.Threshold = [int]$params[1]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'tcp-rst-invalid-session') {
        $FlowProfile.TCPRSTInvalidSession = $True
    } elseif(PhraseMatch $params 'tcp-syn-bit-check') {
        $FlowProfile.TCPSYNBitCheck = $True
    } elseif((PhraseMatch $params 'tcp-syn-check','strict') -or (PhraseMatch $params 'tcp-syn-check')) {
        $FlowProfile.TCPSYNCheck = $True
    } elseif(PhraseMatch $params 'tcp-syn-check-in-tunnel') {
        $FlowProfile.TCPSYNCheckInTunnel = $True
    } elseif(PhraseMatch $params 'vpn-tcp-mss' -prefix) {
        if($FlowProfile.VPNTCPMSS -eq $Null) {
            $FlowProfile.VPNTCPMSS = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        if($params.Count -eq 1) {
            $FlowProfile.VPNTCPMSS.Enabled = $True
        } elseif(PhraseMatch $params $RE_INTEGER -offset 1) {
            $FlowProfile.VPNTCPMSS.Threshold = [int]$params[1]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-Flow
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($FlowProfile -eq $Null) {
        $script:FlowProfile = New-Object FlowProfile
    }

    if(PhraseMatch $params 'aging' -prefix) {
        New-ObjectUnlessDefined ([ref]$FlowProfile) AggressiveAging

        if(PhraseMatch $params 'early-ageout') {
            $FlowProfile.AggressiveAging.EarlyAgeout = $Null
        } elseif(PhraseMatch $params 'high-watermark') {
            $FlowProfile.AggressiveAging.HighWatermark = $Null
        } elseif(PhraseMatch $params 'low-watermark') {
            $FlowProfile.AggressiveAging.LowWatermark = $Null
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'allow-dns-reply') {
        $FlowProfile.AllowDNSReply = $False
    } elseif(PhraseMatch $params 'all-tcp-mss') {
        if($FlowProfile.AllTCPMSS -eq $Null) {
            $FlowProfile.AllTCPMSS = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        $FlowProfile.AllTCPMSS.Enabled = $False
    } elseif(PhraseMatch $params 'check','tcp-rst-sequence') {
        $FlowProfile.CheckTCPRSTSequence = $False
    } elseif(PhraseMatch $params 'force-ip-reassembly') {
        $FlowProfile.ForceIPReassembly = $False
    } elseif(PhraseMatch $params 'gre-in-tcp-mss') {
        if($FlowProfile.GREInTCPMSS -eq $Null) {
            $FlowProfile.GREInTCPMSS = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        $FlowProfile.GREInTCPMSS.Enabled = $False
    } elseif(PhraseMatch $params 'gre-out-tcp-mss') {
        if($FlowProfile.GREOutTCPMSS -eq $Null) {
            $FlowProfile.GREOutTCPMSS = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        $FlowProfile.GREOutTCPMSS.Enabled = $False
    } elseif(PhraseMatch $params 'hub-n-spoke-mip') {
        $FlowProfile.HubNSpokeMIP = $False
    } elseif(PhraseMatch $params 'initial-timeout') {
        $FlowProfile.InitialTimeout = $Null
    } elseif(PhraseMatch $params 'icmp-ur-msg-filter') {
        $FlowProfile.ICMPURMSGFilter = $False
    } elseif(PhraseMatch $params 'icmp-ur-session-close') {
        $FlowProfile.ICMPURSessionClose = $False
    } elseif(PhraseMatch $params 'mac-cache','mgt') {
        $FlowProfile.MACCacheMGT = $False
    } elseif(PhraseMatch $params 'mac-flooding') {
        $FlowProfile.MACFlooding = $False
    } elseif(PhraseMatch $params 'max-frag-pkt-size',$RE_INTEGER) {
        $FlowProfile.MaxFragPktSize = $Null
    } elseif(PhraseMatch $params 'multicast','idp') {
        $FlowProfile.MulticastIDP = $False
    } elseif(PhraseMatch $params 'multicast','install-hw-session') {
        $FlowProfile.MulticastInstallHWSession = $False
    } elseif(PhraseMatch $params 'no-tcp-seq-check') {
        $FlowProfile.NoTCPSeqCheck = $False
    } elseif(PhraseMatch $params 'path-mtu') {
        $FlowProfile.PathMTU = $False
    } elseif(PhraseMatch $params 'reverse-route','clear-text') {
        $FlowProfile.ReverseRouteClearText = 'None'
    } elseif(PhraseMatch $params 'reverse-route','tunnel') {
        $FlowProfile.ReverseRouteTunnel = 'None'
    } elseif(PhraseMatch $params 'route-cache') {
        $FlowProfile.RouteCache = $False
    } elseif(PhraseMatch $params 'route-change-timeout') {
        $FlowProfile.RouteChangeTimeout = $Null
    } elseif(PhraseMatch $params 'syn-proxy','syn-cookie') {
        $FlowProfile.TCPSYNProxySYNCookie = $False
    } elseif(PhraseMatch $params 'tcp-mss' -prefix) {
        if($FlowProfile.TCPMSS -eq $Null) {
            $FlowProfile.TCPMSS = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        $FlowProfile.TCPMSS.Enabled = $False
    } elseif(PhraseMatch $params 'tcp-rst-invalid-session') {
        $FlowProfile.TCPRSTInvalidSession = $False
    } elseif(PhraseMatch $params 'tcp-syn-bit-check') {
        $FlowProfile.TCPSYNBitCheck = $False
    } elseif(PhraseMatch $params 'tcp-syn-check') {
        $FlowProfile.TCPSYNCheck = $False
    } elseif(PhraseMatch $params 'tcp-syn-check-in-tunnel') {
        $FlowProfile.TCPSYNCheckInTunnel = $False
    } elseif(PhraseMatch $params 'vpn-tcp-mss') {
        if($FlowProfile.VPNTCPMSS -eq $Null) {
            $FlowProfile.VPNTCPMSS = New-Object ScreeningElementWithThreshold($Null,$Null)
        }

        $FlowProfile.VPNTCPMSS.Enabled = $False
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

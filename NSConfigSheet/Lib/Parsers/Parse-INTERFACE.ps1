Function Parse-ROOT-Set-Interface
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $interface_name
    )

    [InterfaceProfile]$interface_instance = $Null
    if(-not $InterfaceDic.Contains($interface_name)) {
        $interface_instance = switch -regex ($interface_name) {
            '^bgroup' {
                New-Object BridgeGroupInterfaceProfile
                break;
            }
            default {
                New-Object InterfaceProfile
            }
        }
        $interface_instance.Name = $interface_name
        [InterfaceProfile]$InterfaceDic[$interface_name] = $interface_instance
    } else {
        $interface_instance = $InterfaceDic[$interface_name]
    }

    if(PhraseMatch $params 'bandwidth' -prefix) {
        New-ObjectUnlessDefined ([ref]$Interface_instance) Bandwidth InterfaceTrafficBandwidth
        if(PhraseMatch $params 'egress','mbw',$RE_INTEGER -prefix 1) {
            $Interface_instance.Bandwidth.Egress = [int]$params[3]
        } elseif(PhraseMatch $params 'ingress','mbw',$RE_INTEGER -prefix 1) {
            $Interface_instance.Bandwidth.Ingress = [int]$params[3]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'bypass-non-ip') {
        $Interface_instance.BypassNonIP = $True
    } elseif(PhraseMatch $params 'bypass-non-ip-all') {
        $Interface_instance.BypassNonIPAll = $True
    } elseif(PhraseMatch $params 'bypass-others-ipsec') {
        $Interface_instance.BypassOthersIPSec = $True
    } elseif(PhraseMatch $params 'dot1x' -prefix) {
        if($params.Count -eq 2) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'max-user',$RE_INTEGER -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'auth-server',$RE_QUOTED_NAME -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'g-arp') {
        $Interface_instance.GARP = $True
    } elseif(PhraseMatch $params 'ip' -prefix) {
        if($Interface_instance.IPAddressSetting -isnot [SetStaticIP] ) {
            $Interface_instance.IPAddressSetting = New-Object SetStaticIP
        }

        if(PhraseMatch $params $RE_IPV4_ADDRESS_WITH_MASK -offset 1) {
            $Interface_instance.IPAddressSetting.IPAddr = $last_matches[0]['IPV4_ADDRESS_WITH_MASK']
        } elseif(PhraseMatch $params $RE_IPV4_ADDRESS_WITH_MASK,'secondary' -offset 1) {
            $Interface_instance.IPAddressSetting.SecondaryIPAddr += $last_matches[0]['IPV4_ADDRESS_WITH_MASK']
        } elseif(PhraseMatch $params 'manageable' -offset 1) {
            $Interface_instance.IPAddressSetting.IPManagable = $True
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'manage',$RE_MANAGEMENT_SERVICE) {
        $Interface_instance.ManagementService.Set($params[1])
    } elseif(PhraseMatch $params 'manage-ip',$RE_IPV4_HOST_ADDRESS) {
        New-ObjectUnlessDefined ([ref]$interface_instance) IPAddressSetting SetStaticIP

        $interface_instance.IPAddressSetting.ManageIPAddr = $last_matches[0]['IPV4_HOST_ADDRESS']
    } elseif(PhraseMatch $params 'mip',$RE_IPV4_HOST_ADDRESS,'host',$RE_IPV4_HOST_ADDRESS,'netmask',$RE_IPV4_HOST_ADDRESS,'vr',$RE_QUOTED_NAME) {
        $mapped_ip = New-Object MappedIP
        $Interface_instance.MappedIP += $mapped_ip
        $mapped_ip.MIP = $last_matches[0]['IPV4_HOST_ADDRESS']
        $mapped_ip.HostIP = $last_matches[1]['IPV4_HOST_ADDRESS']
        $mapped_ip.Netmask = $last_matches[2]['IPV4_HOST_ADDRESS']
        $mapped_ip.VRouter = $last_matches[3]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'nat') {
        $Interface_instance.Mode = 'nat'
    } elseif(PhraseMatch $params 'phy','auto') {
        $Interface_instance.Phy.Speed = 'auto'
        $Interface_instance.Phy.Duplex = 'auto'
    } elseif(PhraseMatch $params 'port',$RE_INTERFACE_NAME) {
        $Interface_instance.Port += $last_matches[0]['INTERFACE_NAME']
    } elseif(PhraseMatch $params 'phy',$RE_INTERFACE_DUPLEX,$RE_INTERFACE_SPEED) {
        $Interface_instance.Phy.Speed = $params[1]
        $Interface_instance.Phy.Duplex = $params[2]
    } elseif(PhraseMatch $params 'route') {
        $Interface_instance.Mode = 'route'
    } elseif(PhraseMatch $params 'tag',$RE_INTEGER,'zone',$RE_QUOTED_NAME) {
        $Interface_instance.Zone = $last_matches[1]['QUOTED_NAME']
        $Interface_instance.Tag = [int]$params[1]
    } elseif(PhraseMatch $params 'vip' -prefix) {
        $params = (ncdr $params 1)

        $virtual_ip_addr = ''
        if(PhraseMatch $params 'interface-ip' -prefix) {
            $virtual_ip_addr = '<interface-ip>'
        } elseif(PhraseMatch $params $RE_IPV4_HOST_ADDRESS -prefix) {
            $virtual_ip_addr = $last_matches[0]['IPV4_HOST_ADDRESS']
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
        $params = (ncdr $params 1)

        if(-not $interface_instance.VirtualIP.ContainsKey($virtual_ip_addr)) {
            $interface_instance.VirtualIP[$virtual_ip_addr] = New-Object VirtualIP
            $interface_instance.VirtualIP[$virtual_ip_addr].VirtualIPAddr = $virtual_ip_addr
        }
        $virtual_ip = $Interface_instance.VirtualIP[$virtual_ip_addr]

        if(PhraseMatch $params '+' -prefix) {
            $params = (ncdr $params 1)
        }

        $virtual_service = New-Object VirtualService
        if(PhraseMatch $params $RE_INTEGER,$RE_QUOTED_OR_NOT_QUOTED_NAME,$RE_IPV4_HOST_ADDRESS -prefix) {
            $virtual_service.VirtualPort = [int]$params[0]
            $virtual_service.MapToService = $last_matches[1]['QUOTED_OR_NOT_QUOTED_NAME']
            $virtual_service.MapToIPAddr = $last_matches[2]['IPV4_HOST_ADDRESS']
            $virtual_ip.VirtualService += $virtual_service
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
        $params = (ncdr $params 3)

        if($params -eq $Null) {
            # nothing to be done
        } elseif(PhraseMatch $params 'manual') {
            $virtual_service.ServerAutoDetection = $False
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

    } elseif(PhraseMatch $params 'webauth' -prefix) {
        New-ObjectUnlessDefined ([ref]$Interface_instance) WebAuth InterfaceWebAuth

        if(PhraseMatch $params.Count 'ssl-only' -offset 1) {
            $Interface_instance.WebAuth.SSLOnly = $True
        }
    } elseif(PhraseMatch $params 'webauth-ip',$RE_IPV4_HOST_ADDRESS) {
        New-ObjectUnlessDefined ([ref]$Interface_instance) WebAuth InterfaceWebAuth
        $Interface_instance.WebAuth.IPAddr = $last_matches[0]['IPV4_HOST_ADDRESS']
    } elseif(PhraseMatch $params 'zone',$RE_QUOTED_NAME) {
        $Interface_instance.Zone = $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'loopback-group',$RE_LOOPBACK_NAME -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'dip',$RE_INTEGER -prefix) {
        $dip_id = [int]$params[1]
        $params = @(ncdr $params 2)
        if(PhraseMatch $params 'ipv6' -prefix) {
            #Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'shift-from',$RE_IPV4_HOST_ADDRESS) {
            $dip_shift = New-Object DynamicIPShift
            $dip_shift.DIPID = $dip_id
            $dip_shift.IPAddr = $last_matches[0]['IPV4_HOST_ADDRESS']
            $Interface_instance.DynamicIP[$dip_id] = $dip_shift
        } else {
            $dip_ipv4 = New-Object DynamicIPv4
            $dip_ipv4.DIPID = $dip_id
            $interface_instance.DynamicIP[$dip_id] = $dip_ipv4
            $state = 'INIT'
            while($params.Count -gt 0) {
                switch($state) {
                    'INIT' {
                        if(PhraseMatch $params $RE_IPV4_HOST_ADDRESS,$RE_IPV4_HOST_ADDRESS -prefix) {
                            $dip_ipv4.IPAddr1 = $last_matches[0]['IPV4_HOST_ADDRESS']
                            $dip_ipv4.IPAddr2 = $last_matches[1]['IPV4_HOST_ADDRESS']
                            $params = @(ncdr $params 2)
                            $state = 'ADDRESS READ'
                        } elseif(PhraseMatch $params $RE_IPV4_HOST_ADDRESS -prefix) {
                            $dip_ipv4.IPAddr1 = $last_matches[0]['IPV4_HOST_ADDRESS']
                            $params = @(ncdr $params 1)
                            $state = 'ADDRESS READ'
                        } else {
                            $state = 'ERROR'
                        }
                    }
                    'ADDRESS READ' {
                        if(PhraseMatch $params 'scale-size',$RE_INTEGER -prefix) {
                            $dip_ipv4.ScaleSize = [int]$params[1]
                            $params = @(ncdr $params 2)
                        } elseif(PhraseMatch $params 'random-port' -prefix) {
                            $dip_ipv4.randomPort = $true
                            $params = @(ncdr $params 1)
                        } else {
                            $state = 'ERROR'
                        }
                    }
                    'ERROR' {
                        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
                    }
                }
            }
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-Interface
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $interface_name
    )

    [InterfaceProfile]$interface_instance = $Null
    if(-not $InterfaceDic.Contains($interface_name)) {
        $interface_instance = switch -regex ($interface_name) {
            '^brgroup' {
                New-Object BridgeGroupInterfaceProfile
                break;
            }
            default {
                New-Object InterfaceProfile
            }
        }
        $interface_instance.Name = $interface_name
        [InterfaceProfile]$InterfaceDic[$interface_name] = $interface_instance
    } else {
        $interface_instance = $InterfaceDic[$interface_name]
    }

    if(PhraseMatch $params 'bandwidth' -prefix) {
        $interface_instance.Bandwidth = $Null
    } elseif(PhraseMatch $params 'bypass-non-ip') {
        $interface_instance.BypassNonIP = $False
    } elseif(PhraseMatch $params 'bypass-non-ip-all') {
        $interface_instance.BypassNonIPAll = $False
    } elseif(PhraseMatch $params 'bypass-others-ipsec') {
        $interface_instance.BypassOthersIPSec = $False
    } elseif(PhraseMatch $params 'g-arp') {
        $interface_instance.GARP = $False
    } elseif(PhraseMatch $params 'ip' -prefix) {
        if($params.Count -eq 1) {
            $interface_instance.IPAddressSetting = $Null
        } elseif(PhraseMatch $params 'manageable' -offset 1) {
            if($interface_instance -is [SetStaticIP]) {
                $interface_instance.IPAddressSetting.IPManagable = $False
            }
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'manage',$RE_MANAGEMENT_SERVICE) {
        $interface_instance.ManagementService.Unset($params[1])
    } elseif(PhraseMatch $params 'manage-ip') {
        if($interface_instance.IPAddressSetting -is [SetStaticIP]) {
            $interface_instance.IPAddressSetting.ManageIPAddr = ''
        } else {
            throw "Interface $($interface_instance.Name) is not static IP @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'mip' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'nat') {
        $interface_instance.Mode = $Null
    } elseif(PhraseMatch $params 'route') {
        $interface_instance.Mode = $Null
    } elseif(PhraseMatch $params 'tag') {
        $Interface_instance.Zone = $Null
        $Interface_instance.Tag = $Null
    } elseif(PhraseMatch $params 'webauth' -prefix) {
        if((PhraseMatch $params 'ssl-only') -and $interface_instance.WebAuth -ne $Null) {
            $interface_instance.WebAuth.SSLOnly = $False
        } else {
            $interface_instance.WebAuth = $Null
        }
    } elseif(PhraseMatch $params 'webauth-ip' -prefix) {
        if($params.Count -eq 1) {
            if($interface_instance.WebAuth -ne $Null) {
                $interface_instance.WebAuth.IPAddr = ''
            }
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'zone') {
        $interface_instance.Zone = $Null
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

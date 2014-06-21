function Parse-ROOT-Set-Clock
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($ClockProfile -eq $Null) {
        $script:ClockProfile = New-Object ClockProfile
    }

    if(PhraseMatch $params 'dst-off') {
        $ClockProfile.DST = $Null
    } elseif(PhraseMatch $params 'ntp') {
        $ClockProfile.NTP = New-Object NTPProfile
    } elseif(PhraseMatch $params 'timezone',$RE_INTEGER) {
        $ClockProfile.Timezone = [decimal]$params[1]
    } else {
        throw "SYNTAX ERROR: $line"
    }
}

function Parse-ROOT-Unset-Clock
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($ClockProfile -eq $Null) {
        $script:ClockProfile = New-Object ClockProfile
    }

    if(PhraseMatch $params 'dst-off') {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'ntp') {
        $ClockProfile.NTP = $Null
    } elseif(PhraseMatch $params 'timezone') {
        $ClockProfile.Timezone = 0
    } else {
        throw "SYNTAX ERROR: $line"
    }
}


Function Parse-ROOT-Set-Service
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params $RE_QUOTED_NAME,$RE_SERVICE_3RD_WORD,$RE_IP_PROTOCOL,'src-port',$RE_PORT_RANGE,'dst-port',$RE_PORT_RANGE) {
        $service_name = $last_matches[0]['QUOTED_NAME']
        if(-not $ServiceObjecteDic.Contains($service_name)) {
            $ServiceObjecteDic[$service_name] = New-Object ServiceObject
            $ServiceObjecteDic[$service_name].Name = $service_name
        }
        $sl = [int]$params[4].split('-')[0]
        $su = [int]$params[4].split('-')[1]
        $dl = [int]$params[6].split('-')[0]
        $du = [int]$params[6].split('-')[1]
        $ServiceObjecteDic[$service_name].List += New-Object ServiceRange($params[2],$sl,$su,$dl,$du)
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-Service
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params $RE_QUOTED_NAME) {
        $service_name = $last_matches[0]['QUOTED_NAME']
        if($ServiceObjecteDic.Contains($service_name)) {
            $ServiceObjecteDic.Remove($service_name)
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-ROOT-Set-Auth
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'banner',$RE_BANNER_APPLICATION,$RE_BANNER_PHASE,$RE_QUOTED_NAME) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'default','auth','server',$RE_QUOTED_NAME) {
        $script:DefaultAuthServerName = $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'radius','accounting','action','cleanup-session') {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'radius','accounting','port',$RE_INTEGER) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-Auth
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'banner',$RE_BANNER_APPLICATION,$RE_BANNER_PHASE) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'default','auth','server') {
        $script:DefaultAuthServerName = $Null
    } elseif(PhraseMatch $params 'radius','accounting','action','cleanup-session') {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'radius','accounting','port',$RE_INTEGER) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Set-Admin
{
    [CmdletBinding()]
    param(
        [string[]]
        $params
    )

    if($AdminProfile -eq $Null) {
        $script:AdminProfile = New-Object AdminProfile
    }

    if(PhraseMatch $params 'auth','timeout',$RE_INTEGER) {
        $AdminProfile.AdminAuthTimeout = [int]$params[2]
    } elseif(PhraseMatch $params 'auth','web','timeout',$RE_INTEGER) {
        $AdminProfile.AdminAuthTimeout = [int]$params[3]
    } elseif(PhraseMatch $params 'auth','server',$RE_QUOTED_NAME) {
        $AdminProfile.AdminAuthServer = $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'format',$RE_FILE_FORMAT) {
        $AdminProfile.ConfigFileFormat = [ConfigFileFormat]$params[1]
    } elseif(PhraseMatch $params 'http','redirect') {
        $AdminProfile.HttpRecirect = $true
    } elseif(PhraseMatch $params 'manager-ip',$RE_IPV4_HOST_ADDRESS,$RE_IPV4_HOST_ADDRESS) {
        $AdminProfile.PermittedIP += "$($params[1])/$($params[2])"
    } elseif(PhraseMatch $params 'name',$RE_QUOTED_NAME) {
        $script:administrator_name = $last_matches[0]['QUOTED_NAME']
        $AdminProfile.LocalDB[$administrator_name] = New-Object AdministratorEntry
        $AdminProfile.LocalDB[$administrator_name].Privilege = [AdministratorPrivilege]::Root
    } elseif(PhraseMatch $params 'user',$RE_QUOTED_NAME -prefix) {
        $username = $last_matches[0]['QUOTED_NAME']
        if(PhraseMatch $params 'password',$RE_QUOTED_NAME -prefix -offset 2) {
            $password = $last_matches[0]['QUOTED_NAME']
            Write-Warning "Password is not written to the document @ $($myinvocation.mycommand.name): $line"
            if(PhraseMatch $params 'privilege',$RE_QUOTED_NAME -offset 4) {
                $privilege = switch($last_matches[0]['QUOTED_NAME']) {
                    'read-only' { [AdministratorPrivilege]::ReadOnly }
                    'read-write' { [AdministratorPrivilege]::All }
                    'root' { [AdministratorPrivilege]::Root }
                }
                $AdminProfile.LocalDB[$username] = New-Object AdministratorEntry
                $AdminProfile.LocalDB[$username].Privilege = $privilege
                $AdminProfile.LocalDB[$username].EncryptedPassword = $password
            } else {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'password',$RE_QUOTED_NAME) {
        $AdminProfile.LocalDB[$administrator_name].EncryptedPassword = $last_matches[0]['QUOTED_NAME']
        Write-Warning "Password is not written to the document @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'telnet','port',$RE_INTEGER) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-Admin
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($AdminProfile -eq $Null) {
        $script:AdminProfile = New-Object AdminProfile
    }

    if(PhraseMatch $params 'auth','timeout') {
        $AdminProfile.AdminAuthTimeout = $Null
    } elseif(PhraseMatch $params 'auth','web','timeout') {
        $AdminProfile.AdminAuthTimeout = $Null
    } elseif(PhraseMatch $params 'auth','server') {
        $AdminProfile.AdminAuthServer = $Null
    } elseif(PhraseMatch $params 'format',$RE_FILE_FORMAT) {
        $AdminProfile.ConfigFileFormat = $Null
    } elseif(PhraseMatch $params 'http','redirect') {
        $AdminProfile.HttpRecirect = $false
    } elseif(PhraseMatch $params 'manager-ip') {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'name',$RE_QUOTED_NAME) {
        $script:administrator_name = $last_matches[0]['QUOTED_NAME']
        if($AdminProfile.LocalDB.Contains($administrator_name)) {
            $AdminProfile.LocalDB.Remove($administrator_name)
        }
    } elseif(PhraseMatch $params 'password') {
        $AdminProfile.LocalDB[$administrator_name].EncryptedPassword = ''
        Write-Warning "Password is not written to the document @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'telnet','port',$RE_INTERFACE) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-ROOT-Set-Address
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $zone_name,

        [string]
        [parameter(Mandatory=$true)]
        $address_name
    )

    [AddressObject]$address_instance = New-Object AddressObject
    $address_instance.Zone = $zone_name
    $address_instance.Name = $address_name
    $AddressObjectDic[$address_name] = $address_instance
    if(PhraseMatch $params $RE_IPV4_HOST_ADDRESS,$RE_IPV4_HOST_ADDRESS) {
        $address_instance.IPAddr = $params[0]
        $address_instance.NetworkMask = $params[1]
    } elseif(PhraseMatch $params $RE_IPV4_ADDRESS_WITH_MASK) {
        [string[]]$ip_addr = ($last_matches[0]['IPV4_ADDRESS_WITH_MASK'] -split '/')
        $address_instance.IPAddr = $ip_addr[0]
        $address_instance.NetworkMask = $ip_addr[1]
    } elseif(PhraseMatch $params $RE_QUOTED_NAME) {
        $address_instance.FQDN = $last_matches[0]['QUOTED_NAME']
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-Address
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $zone_name,

        [string]
        [parameter(Mandatory=$true)]
        $address_name
    )

    if($AddressObjectDic.Contains($address_name)) {
        $AddressObjectDic.Remove($address_name)
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-ROOT-Set-GroupAddress
{
    [CmdletBinding()]
    param(
        [string[]]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $zone_name,

        [string]
        [parameter(Mandatory=$true)]
        $group_name
    )

    if(-not $AddressGroupDic.Contains($group_name)) {
        [AddressGroup]$AddressGroupDic[$group_name] = New-Object AddressGroup
        $AddressGroupDic[$group_name].Zone = $zone_name
        $AddressGroupDic[$group_name].Name = $group_name
    }

    if($params.Count -eq 0) {
        # nothing to be done
    } elseif(PhraseMatch $params 'add',$RE_QUOTED_NAME) {
        $address_name = $last_matches[0]['QUOTED_NAME']
        if($AddressGroupDic[$group_name].Member.Contains($address_name)) {
            throw "Member '$address_name' of Address Group '$group_name' already exists @ $($myinvocation.mycommand.name): $line"
        }
        $AddressGroupDic[$group_name].Member[$address_name] = $address_name
    } elseif(PhraseMatch $params 'remove',$RE_QUOTED_NAME) {
        $address_name = $last_matches[0]['QUOTED_NAME']
        if(-not $AddressGroupDic[$group_name].Member.Contains($address_name)) {
            throw "Member '$address_name' of Address Group '$group_name' does not exists @ $($myinvocation.mycommand.name): $line"
        }
        $AddressGroupDic[$group_name].Member.Remove($address_name)
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-GroupAddress
{
    [CmdletBinding()]
    param(
        [string[]]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $zone_name,

        [string]
        [parameter(Mandatory=$true)]
        $group_name
    )

    if($params.Count -eq 0) {
        if($AddressGroupDic.Contains($group_name)) {
            [AddressGroup]$AddressGroupDic.Remove($group_name)
        } else {
            throw "Address Group '$group_name' does not exists @ $($myinvocation.mycommand.name): $line"
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-ROOT-Set-GroupService
{
    [CmdletBinding()]
    param(
        [string[]]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $group_name
    )

    if($params.Count -eq 0) {
        if($ServiceGroupDic.Contains($group_name)) {
            throw "Group '$group_name' already exists @ $($myinvocation.mycommand.name): $line"
        }
        [ServiceGroup]$ServiceGroupDic[$group_name] = New-Object ServiceGroup
        $ServiceGroupDic[$group_name].Name = $group_name
    } elseif(PhraseMatch $params 'add',$RE_QUOTED_NAME) {
        $service_name = $last_matches[0]['QUOTED_NAME']
        if(-not $ServiceGroupDic.Contains($group_name)) {
            [ServiceGroup]$ServiceGroupDic[$group_name] = New-Object ServiceGroup
            $ServiceGroupDic[$group_name].Name = $group_name
        }
        if($ServiceGroupDic[$group_name].Member.Contains($service_name)) {
            throw "Member '$service_name' of Group '$group_name' already exists @ $($myinvocation.mycommand.name): $line"
        }
        $ServiceGroupDic[$group_name].Member[$service_name] = $service_name
    } elseif(PhraseMatch $params 'remove',$RE_QUOTED_NAME) {
        $service_name = $last_matches[0]['QUOTED_NAME']
        if(-not $ServiceGroupDic.Contains($group_name)) {
            throw "Group '$group_name' does not exist @ $($myinvocation.mycommand.name): $line"
        }
        if($ServiceGroupDic[$group_name].Member.Contains($service_name)) {
            $ServiceGroupDic[$group_name].Member.Remove($service_name)
        } else {
            throw "Member '$service_name' of Group '$group_name' does exists @ $($myinvocation.mycommand.name): $line"
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-ROOT-Unset-GroupService
{
    [CmdletBinding()]
    param(
        [string[]]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $group_name
    )

    if($params.Count -eq 0) {
        if(-not $ServiceGroupDic.Contains($group_name)) {
            throw "Group '$group_name' does not exist @ $($myinvocation.mycommand.name): $line"
        }
        $ServiceGroupDic.Remove($group_name)
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-ROOT-IKE
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

    if(PhraseMatch $params 'respond-bad-spi',$RE_INTEGER) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'ikeid-enumeration') {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'dos-protection') {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'ikev2' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-ROOT-IPSec
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

    if(PhraseMatch $params 'access-session' -prefix) {
        if(PhraseMatch $params 'enable' -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'maximum' -offset 1 -prefix) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'upper-threshold' -offset 1 -prefix) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'lower-threshold' -offset 1 -prefix) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'dead-p2-sa-timeout' -offset 1 -prefix) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'log-error' -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'info-exch-connected' -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'use-error-log' -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-ROOT-Url
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

    if(PhraseMatch $params 'protocol' -prefix) {
        $params = @(ncdr $params 1)
        while($params.Count -gt 0) {
            if(PhraseMatch $params 'type' -prefix) {
                # nothing to be done
            } elseif(PhraseMatch  $params 'sc-cpa' -prefix) {
                $context.Push('URL PROTOCOL')
                Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
            } elseif(PhraseMatch $params 'scfp' -prefix) {
                $context.Push('URL PROTOCOL')
                Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
            } elseif(PhraseMatch $params 'websense' -prefix) {
                $context.Push('URL PROTOCOL')
                Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
            } else {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
            $params = @(ncdr $params 1)
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-ROOT-Set-SSH
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($ManagementProfile -eq $Null) {
        $script:ManagementProfile = New-Object ManagementProfile
    }
    New-ObjectUnlessDefined ([ref]$ManagementProfile) SSHProfile

    if(PhraseMatch $params 'enable') {
        $ManagementProfile.SSHProfile.Enable = $True
    } elseif(PhraseMatch $params 'version' -prefix) {
        if(PhraseMatch $params 'v1' -offset 1) {
            $ManagementProfile.SSHProfile = New-Object SSHV1Profile
        } elseif(PhraseMatch $params 'v2' -offset 1) {
            $ManagementProfile.SSHProfile = New-Object SSHV2Profile
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'host-identity' -prefix) {
        if($params.Count -eq 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'cert-dsa',$RE_INTEGER -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'pka-dsa' -prefix) {
        if(PhraseMatch $params 'cert-id',$RE_INTEGER -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'key',$Null -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'user-name' -offset 1) {
            if(PhraseMatch $params 'cert-id',$RE_INTEGER -offset 2) {
                Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
            } elseif(PhraseMatch $params 'key',$Null -offset 2) {
                Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
            }
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-SSH
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($ManagementProfile -eq $Null) {
        $script:ManagementProfile = New-Object ManagementProfile
    }
    New-ObjectUnlessDefined ([ref]$ManagementProfile) SSHProfile

    if(PhraseMatch $params 'enable') {
        $ManagementProfile.SSHProfile.Enable = $False
    } elseif(PhraseMatch $params 'host-identity' -prefix) {
        if($params.Count -eq 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'cert-dsa',$RE_INTEGER -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'pka-dsa' -prefix) {
        if(PhraseMatch $params 'cert-id',$RE_INTEGER -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'key' -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'user-name' -offset 1) {
            if(PhraseMatch $params 'cert-id',$RE_INTEGER -offset 2) {
                Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
            } elseif(PhraseMatch $params 'key' -offset 2) {
                Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
            }
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-ROOT-Set-NTP
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'enable') {
        $ClockProfile.NTP.Enabled = $True
    } elseif(PhraseMatch $params 'server','backup1',$RE_QUOTED_NAME) {
        $ClockProfile.NTP.List[1] = New-Object NTPProfileElement
        $ClockProfile.NTP.List[1].Server = $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'server','backup2',$RE_QUOTED_NAME) {
        $ClockProfile.NTP.List[2] = New-Object NTPProfileElement
        $ClockProfile.NTP.List[2].Server = $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'server',$RE_QUOTED_NAME) {
        $ClockProfile.NTP.List[0] = New-Object NTPProfileElement
        $ClockProfile.NTP.List[0].Server = $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'max-adjustment',$RE_INTEGER) {
        $ClockProfile.NTP.MaximumTimeAdjustmentSecond = [int]$params[1]
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-NTP
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'enable') {
        $ClockProfile.NTP.Enabled = $False
    } elseif(PhraseMatch $params 'server','backup1') {
        $ClockProfile.NTP.List[1] = $Null
    } elseif(PhraseMatch $params 'server','backup2',$RE_QUOTED_NAME) {
        $ClockProfile.NTP.List[2] = $Null
    } elseif(PhraseMatch $params 'server',$RE_QUOTED_NAME) {
        $ClockProfile.NTP.List[0] = $Null
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Set-VLAN
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'group' -prefix) {
        if(PhraseMatch $params 'name',$RE_QUOTED_NAME -offset 1) {
            $name = $last_matches[0]['QUOTED_NAME']
            if(-not $VLANGroupDic.Contains($name)) {
                $VLANGroupDic[$name] = New-Object VLANGroup
                $VLANGroupDic[$name].Name = $name
            }
        } elseif(PhraseMatch $params $RE_QUOTED_NAME -prefix -offset 1) {
            $name = $last_matches[0]['QUOTED_NAME']
            if(-not $VLANGroupDic.Contains($name)) {
                $VLANGroupDic[$name] = New-Object VLANGroup
                $VLANGroupDic[$name].Name = $name
            }
            if($params.Count -eq 2) {
                # nothing to be done
            } elseif(PhraseMatch $params 'vsd-group','id',$RE_INTEGER -offset 2) {
                $VLANGroupDic[$name].VSDGroupId = [int]$params[4]
            } elseif(PhraseMatch $params $RE_INTEGER,$RE_INTEGER -offset 2) {
                $VLANGroupDic[$name].VLANLow = [int]$params[2]
                $VLANGroupDic[$name].VLANHigh = [int]$params[3]
            } elseif(PhraseMatch $params $RE_INTEGER -offset 2) {
                $VLANGroupDic[$name].VLANLow = [int]$params[2]
                $VLANGroupDic[$name].VLANHigh = [int]$params[2]
            } else {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'port',$RE_INTERFACE_NAME -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'retag' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-VLAN
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'group' -prefix) {
        if(PhraseMatch $params 'name',$RE_QUOTED_NAME -offset 1) {
            $name = $last_matches[0]['QUOTED_NAME']
            if($VLANGroupDic.Contains($name)) {
                $VLANGroupDic.Remove($name)
            }
        } elseif(PhraseMatch $params $RE_QUOTED_NAME -prefix -offset 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'port',$RE_INTERFACE_NAME -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'retag' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Set-Body
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'clock' -prefix) {
        Parse-ROOT-Set-Clock @(ncdr $params 1)
    } elseif(PhraseMatch $params 'vrouter' -prefix) {
        Parse-ROOT-Set-VRouter @(ncdr $params 1)
    } elseif(PhraseMatch $params 'service' -prefix) {
        Parse-ROOT-Set-Service @(ncdr $params 1)
    } elseif(PhraseMatch $params 'auth-server',$RE_QUOTED_NAME -prefix) {
        Parse-ROOT-Set-Auth-Server @(ncdr $params 2) $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'auth' -prefix) {
        Parse-ROOT-Set-Auth @(ncdr $params 1)
    } elseif(PhraseMatch $params 'admin' -prefix) {
        Parse-ROOT-Set-Admin @(ncdr $params 1)
    } elseif(PhraseMatch $params 'zone' -prefix) {
        Parse-ROOT-Set-Zone @(ncdr $params 1)
    } elseif(PhraseMatch $params 'interface',$RE_INTERFACE_NAME -prefix) {
        Parse-ROOT-Set-Interface @(ncdr $params 2) $last_matches[0]['INTERFACE_NAME']
    } elseif(PhraseMatch $params 'flow' -prefix) {
        Parse-ROOT-Set-flow @(ncdr $params 1)
    } elseif(PhraseMatch $params 'console','page',$RE_INTEGER) {
        $AdminProfile.ConsolePage = [int]$params[2]
    } elseif(PhraseMatch $params 'hostname',$Null) {
        $script:device_name = $params[1]
    } elseif(PhraseMatch $params 'pki' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'address',$RE_QUOTED_NAME,$RE_QUOTED_NAME -prefix) {
        $zone_name = $last_matches[0]['QUOTED_NAME']
        $address_name = $last_matches[1]['QUOTED_NAME']
        Parse-ROOT-Set-Address @(ncdr $params 3) $zone_name $address_name
    } elseif(PhraseMatch $params 'group','address',$RE_QUOTED_NAME,$RE_QUOTED_NAME -prefix) {
        $zone_name = $last_matches[0]['QUOTED_NAME']
        $group_name = $last_matches[1]['QUOTED_NAME']
        Parse-ROOT-Set-GroupAddress @(ncdr $params 4) $zone_name $group_name
    } elseif(PhraseMatch $params 'group','service',$RE_QUOTED_NAME -prefix) {
        $group_name = $last_matches[0]['QUOTED_NAME']
        Parse-ROOT-Set-GroupService @(ncdr $params 3) $group_name
    } elseif(PhraseMatch $params 'vlan' -prefix) {
        Parse-ROOT-Set-VLAN @(ncdr $params 1)
    } elseif(PhraseMatch $params 'ike' -prefix) {
        Parse-ROOT-IKE @(ncdr $params 1) $True
    } elseif(PhraseMatch $params 'ipsec' -prefix) {
        Parse-ROOT-IPSec @(ncdr $params 1) $True
    } elseif(PhraseMatch $params 'nsrp' -prefix) {
        Parse-ROOT-Set-NSRP @(ncdr $params 1)
    } elseif(PhraseMatch $params 'policy' -prefix) {
        Parse-ROOT-Set-Policy @(ncdr $params 1)
    } elseif(PhraseMatch $params 'url' -prefix) {
        Parse-ROOT-Url @(ncdr $params 1) $True
    } elseif(PhraseMatch $params 'syslog' -prefix) {
        Parse-ROOT-Set-Syslog @(ncdr $params 1)
    } elseif(PhraseMatch $params 'firewall' -prefix) {
        Parse-ROOT-Set-Firewall @(ncdr $params 1)
    } elseif(PhraseMatch $params 'nsmgmt','bulkcli','reboot-timeout',$RE_INTEGER) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'ssh' -prefix) {
        Parse-ROOT-Set-SSH @(ncdr $params 1)
    } elseif(PhraseMatch $params 'config','lock','timeout',$RE_INTEGER) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'dl-buf','size',$RE_INTEGER) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'ntp' -prefix) {
        Parse-ROOT-Set-NTP @(ncdr $params 1)
    } elseif(PhraseMatch $params 'snmp' -prefix) {
        Parse-ROOT-Set-SNMP @(ncdr $params 1)
    } elseif(PhraseMatch $params 'webtrends','enable') {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'webtrends','host-name',$RE_QUOTED_NAME) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'key' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'alg' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'crypto-policy') {
        $context.Push('CRYPTO-POLICY')
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'license-key' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'telnet' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'snmpv3' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-Body
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'clock' -prefix) {
        Parse-ROOT-Unset-Clock @(ncdr $params 1)
    } elseif(PhraseMatch $params 'vrouter' -prefix) {
        Parse-ROOT-Unset-VRouter @(ncdr $params 1)
    } elseif(PhraseMatch $params 'service' -prefix) {
        Parse-ROOT-Unset-Service @(ncdr $params 1)
    } elseif(PhraseMatch $params 'auth-server',$RE_QUOTED_NAME -prefix) {
        Parse-ROOT-Set-Auth-Server @(ncdr $params 1) $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'auth' -prefix) {
        Parse-ROOT-Unset-Auth @(ncdr $params 1)
    } elseif(PhraseMatch $params 'admin' -prefix) {
        Parse-ROOT-Unset-Admin @(ncdr $params 1)
    } elseif(PhraseMatch $params 'zone' -prefix) {
        Parse-ROOT-Unset-Zone @(ncdr $params 1)
    } elseif(PhraseMatch $params 'interface',$RE_INTERFACE_NAME -prefix) {
        Parse-ROOT-Unset-Interface @(ncdr $params 2) $last_matches[0]['INTERFACE_NAME']
    } elseif(PhraseMatch $params 'flow' -prefix) {
        Parse-ROOT-Unset-flow @(ncdr $params 1)
    } elseif(PhraseMatch $params 'console','page') {
        $AdminProfile.ConsolePage = $Null
    } elseif(PhraseMatch $params 'hostname') {
        $script:device_name = $Null
    } elseif(PhraseMatch $params 'pki' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'address',$RE_QUOTED_NAME,$RE_QUOTED_NAME -prefix) {
        $zone_name = $last_matches[0]['QUOTED_NAME']
        $address_name = $last_matches[1]['QUOTED_NAME']
        Parse-ROOT-Unset-Address @(ncdr $params 3) $zone_name $address_name
    } elseif(PhraseMatch $params 'group','address',$RE_QUOTED_NAME,$RE_QUOTED_NAME -prefix) {
        $zone_name = $last_matches[0]['QUOTED_NAME']
        $group_name = $last_matches[1]['QUOTED_NAME']
        Parse-ROOT-Unset-GroupAddress @(ncdr $params 4) $zone_name $group_name
    } elseif(PhraseMatch $params 'group','service',$RE_QUOTED_NAME -prefix) {
        $group_name = $last_matches[0]['QUOTED_NAME']
        Parse-ROOT-Unset-GroupService @(ncdr $params 3) $group_name
    } elseif(PhraseMatch $params 'vlan' -prefix) {
        Parse-ROOT-Unset-VLAN @(ncdr $params 1)
    } elseif(PhraseMatch $params 'ike' -prefix) {
        Parse-ROOT-IKE @(ncdr $params 1) $False
    } elseif(PhraseMatch $params 'ipsec' -prefix) {
        Parse-ROOT-IPSec @(ncdr $params 1) $False
    } elseif(PhraseMatch $params 'nsrp' -prefix) {
        Parse-ROOT-Unset-NSRP @(ncdr $params 1)
    } elseif(PhraseMatch $params 'policy' -prefix) {
        Parse-ROOT-Unset-Policy @(ncdr $params 1)
    } elseif(PhraseMatch $params 'url' -prefix) {
        Parse-ROOT-Url @(ncdr $params 1) $False
    } elseif(PhraseMatch $params 'syslog' -prefix) {
        Parse-ROOT-Unset-Syslog @(ncdr $params 1)
    } elseif(PhraseMatch $params 'firewall' -prefix) {
        Parse-ROOT-Unset-Firewall @(ncdr $params 1)
    } elseif(PhraseMatch $params 'nsmgmt','bulkcli','reboot-timeout',$RE_INTEGER) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'ssh' -prefix) {
        Parse-ROOT-Unset-SSH @(ncdr $params 1)
    } elseif(PhraseMatch $params 'config','lock','timeout',$RE_INTEGER) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'dl-buf','size',$RE_INTEGER) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'ntp' -prefix) {
        Parse-ROOT-Unset-NTP @(ncdr $params 1)
    } elseif(PhraseMatch $params 'snmp' -prefix) {
        Parse-ROOT-Unset-SNMP @(ncdr $params 1)
    } elseif(PhraseMatch $params 'webtrends','enable') {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'webtrends','host-name',$RE_QUOTED_NAME) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'key' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'alg' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'crypto-policy') {
        $context.Push('CRYPTO-POLICY')
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'license-key' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } elseif(PhraseMatch $params 'telnet' -prefix) {
        Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}


Function Parse-ROOT
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if(PhraseMatch $params 'set' -prefix) {
        Parse-ROOT-Set-Body @(ncdr $params 1)
    } elseif(PhraseMatch $params 'unset' -prefix) {
        Parse-ROOT-Unset-Body @(ncdr $params 1)
    } elseif(PhraseMatch $params 'exit' -prefix) {
        if($context.Count -gt 0) {
            $prev_context = $context.Pop()
        } else {
            throw "Illegal exit: $line"
        }
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

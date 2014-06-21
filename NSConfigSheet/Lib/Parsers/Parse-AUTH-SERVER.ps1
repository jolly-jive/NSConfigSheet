Function Parse-ROOT-Set-Auth-Server
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $auth_server_name
    )

    $auth_server_instance = $Null

    if(-not $AuthServerDic.Contains($auth_server_name)) {
        $auth_server_instance = New-Object AuthServerProfile
        $auth_server_instance.Name = $auth_server_name
        $AuthServerDic[$auth_server_name] = $auth_server_instance
    } else {
        $auth_server_instance = $AuthServerDic[$auth_server_name]
    }

    if(PhraseMatch $params 'account-type' -prefix) {
        New-ObjectUnlessDefined ([ref]$auth_server_instance) AccountType AuthServerAccountType

        foreach($account_type in $params[1..($params.Count - 1)]) {
            $auth_server_instance.AccountType.Set($account_type)
        }
    } elseif(PhraseMatch $params 'backup1',$RE_QUOTED_NAME) {
        $auth_server_instance.Backup1 = $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'backup1',$$RE_IPV4_HOST_ADDRESS) {
        $auth_server_instance.Backup1 = $last_matches[0]['IPV4_HOST_ADDRESS']
    } elseif(PhraseMatch $params 'backup2',$RE_QUOTED_NAME) {
        $auth_server_instance.Backup2 = $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'backup2',$RE_IPV4_HOST_ADDRESS) {
        $auth_server_instance.Backup2 = $last_matches[0]['IPV4_HOST_ADDRESS']
    } elseif(PhraseMatch $params 'fail-over','revert-interval',$RE_INTEGER) {
        $auth_server_instance.FailOverRevertInterval = [int]$params[2]
    } elseif(PhraseMatch $params 'forced-timeout',$RE_INTEGER) {
        $auth_server_instance.ForcedTimeout = [int]$params[1]
    } elseif(PhraseMatch $params 'id',$RE_INTEGER) {
        $auth_server_instance.Id = [int]$params[1]
    } elseif(PhraseMatch $params 'ldap' -prefix) {
        if($auth_server_instance -isnot [LDAPAuthServerProfile]) {
            $auth_server_instance = New-Object LDAPAuthServerProfile($auth_server_instance)
            $AuthServerDic[$auth_server_name] = $auth_server_instance
        }

        if(PhraseMatch $params 'cn',$RE_QUOTED_NAME -offset 1) {
            $auth_server_instance.CN = $last_matches[0]['QUOTED_NAME']
        } elseif(PhraseMatch $params 'dn',$RE_QUOTED_NAME -offset 1) {
            $auth_server_instance.DN = $last_matches[0]['QUOTED_NAME']
        } elseif(PhraseMatch $params 'port',$RE_INTEGER -offset 1) {
            $auth_server_instance.PortNumber = [int]$params[2]
        } elseif(PhraseMatch $params 'server-name',$RE_QUOTED_NAME -offset 1) {
            $auth_server_instance.ServerName = $last_matches[0]['QUOTED_NAME']
        } elseif(PhraseMatch $params 'server-name',$RE_IPV4_HOST_ADDRESS -offset 1) {
            $auth_server_instance.ServerName = $last_matches[0]['IPV4_HOST_ADDRESS']
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'radius' -prefix) {
        if($auth_server_instance -isnot [RadiusAuthServerProfile]) {
            $auth_server_instance = New-Object RadiusAuthServerProfile($auth_server_instance)
            $AuthServerDic[$auth_server_name] = $auth_server_instance
        }

        if(PhraseMatch $params 'accounting-port',$RE_INTEGER -offset 1) {
            $auth_server_instance.AccountingPortNumber = [int]$params[2]
        } elseif(PhraseMatch $params 'attribute','acct-session-id','length',$RE_INTEGER -offset 1) {
            $auth_server_instance.AccountSessionIdLength = [int]$params[4]
        } elseif(PhraseMatch $params 'attribute','calling-station-id',$RE_INTEGER -offset 1) {
            $auth_server_instance.CallingStationId = [int]$params[3]
        } elseif(PhraseMatch $params 'compatibility','rfc-2138' -offset 1) {
            $auth_server_instance.CompatibeWithRFC2138 = $True
        } elseif(PhraseMatch $params 'port',$RE_INTEGER -offset 1) {
            $auth_server_instance.PortNumber = [int]$params[2]
        } elseif(PhraseMatch $params 'retries',$RE_INTEGER -offset 1) {
            $auth_server_instance.ClientRetries = [int]$params[2]
        } elseif(PhraseMatch $params 'secret',$RE_QUOTED_NAME -offset 1) {
            $auth_server_instance.SharedSecret = $last_matches[0]['QUOTED_NAME']
        } elseif(PhraseMatch $params 'timeout',$RE_INTEGER -offset 1) {
            $auth_server_instance.ClientTimeout = [int]$params[2]
        } elseif(PhraseMatch $params 'zone-verification' -offset 1) {
            $auth_server_instance.ZoneVerification = $True
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'securid' -prefix) {
        if($auth_server_instance -isnot [SecuIDAuthServerProfile]) {
            $auth_server_instance = New-Object SecuIDAuthServerProfile($auth_server_instance)
            $AuthServerDic[$auth_server_name] = $auth_server_instance
        }

        if(PhraseMatch $params 'auth-port',$RE_INTEGER -offset 1) {
            $auth_server_instance.AuthPortNumber = [int]$params[2]
        } elseif(PhraseMatch $params 'duress',$RE_INTEGER -offset 1) {
            $auth_server_instance.DuressMode = [int]$params[2]
        } elseif(PhraseMatch $params 'encr',$RE_INTEGER -offset 1) {
            $auth_server_instance.EncryptionMode = [int]$params[2]
        } elseif(PhraseMatch $params 'retries',$RE_INTEGER -offset 1) {
            $auth_server_instance.ClientRetries = [int]$params[2]
        } elseif(PhraseMatch $params 'timeout',$RE_INTEGER -offset 1) {
            $auth_server_instance.ClientTimeout = [int]$params[2]
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'server-name',$RE_QUOTED_NAME) {
        $auth_server_instance.ServerName = $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'server-name',$RE_IPV4_HOST_ADDRESS) {
        $auth_server_instance.ServerName = $last_matches[0]['IPV4_HOST_ADDRESS']
    } elseif(PhraseMatch $params 'src-interface',$RE_INTERFACE_NAME) {
        $auth_server_instance.SourceInterface = $last_matches[0]['INTERFACE_NAME']
    } elseif(PhraseMatch $params 'tacacs' -prefix) {
        if($auth_server_instance -isnot [TACACSAuthServerProfile]) {
            $auth_server_instance = New-Object TACACSAuthServerProfile($auth_server_instance)
            $AuthServerDic[$auth_server_name] = $auth_server_instance
        }

        if(PhraseMatch $params 'port',$RE_INTEGER -offset 1) {
            $auth_server_instance.PortNumber = [int]$params[2]
        } elseif(PhraseMatch $params 'secret',$RE_QUOTED_NAME -offset 1) {
            $auth_server_instance.SharedSecret = $last_matches[0]['QUOTED_NAME']
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'timeout',$RE_INTEGER) {
        $auth_server_instance.Timeout = [int]$params[1]
    } elseif(PhraseMatch $params 'type',$RE_AUTH_SERVER_TYPE) {
        switch($params[1]) {
            'ldap' {
                if($auth_server_instance -isnot [LDAPAuthServerProfile]) {
                    $auth_server_instance = New-Object LDAPAuthServerProfile($auth_server_instance)
                    $AuthServerDic[$auth_server_name] = $auth_server_instance
                }
            }
            'radius' {
                if($auth_server_instance -isnot [RadiusAuthServerProfile]) {
                    $auth_server_instance = New-Object RadiusAuthServerProfile($auth_server_instance)
                    $AuthServerDic[$auth_server_name] = $auth_server_instance
                }
            }
            'securid' {
                if($auth_server_instance -isnot [SecuIDAuthServerProfile]) {
                    $auth_server_instance = New-Object SecuIDAuthServerProfile($auth_server_instance)
                    $AuthServerDic[$auth_server_name] = $auth_server_instance
                }
            }
            'tacacs' {
                if($auth_server_instance -isnot [TACACSAuthServerProfile]) {
                    $auth_server_instance = New-Object TACACSAuthServerProfile($auth_server_instance)
                    $AuthServerDic[$auth_server_name] = $auth_server_instance
                }
            }
        }
    } elseif(PhraseMatch $params 'username','domain',$RE_QUOTED_NAME) {
        $auth_server_instance.DomainName = $last_matches[0]['QUOTED_NAME']
    } elseif(PhraseMatch $params 'username','separator',$RE_QUOTED_NAME,'number',$RE_INTEGER) {
        $auth_server_instance.Separator = $last_matches[0]['QUOTED_NAME']
        $auth_server_instance.Portions = [int]$params[4]
    } elseif(PhraseMatch $params 'zone-verification') {
        $auth_server_instance.ZoneVerification = $True
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Function Parse-ROOT-Unset-Auth-Server
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params,

        [string]
        [parameter(Mandatory=$true)]
        $auth_server_name
    )

    $auth_server_instance = $Null

    if(-not $AuthServerDic.Contains($auth_server_name)) {
        $auth_server_instance = New-Object AuthServerProfile
        $auth_server_instance.Name = $auth_server_name
        $AuthServerDic[$auth_server_name] = $auth_server_instance
    } elseif($params.Count -lt 1) {
        $AuthServerDic.Remove($auth_server_name)
        return
    } else {
        $auth_server_instance = $AuthServerDic[$auth_server_name]
    }

    if(PhraseMatch $params 'account-type' -prefix) {
        New-ObjectUnlessDefined ([ref]$auth_server_instance) AccountType AuthServerAccountType

        foreach($account_type in $params[1..($params.Count - 1)]) {
            $auth_server_instance.AccountType.Unset($account_type)
        }
    } elseif(PhraseMatch $params 'backup1') {
        $auth_server_instance.Backup1 = $Null
    } elseif(PhraseMatch $params 'backup2') {
        $auth_server_instance.Backup2 = $Null
    } elseif(PhraseMatch $params 'fail-over','revert-interval') {
        $auth_server_instance.FailOverRevertInterval = $Null
    } elseif(PhraseMatch $params 'forced-timeout') {
        $auth_server_instance.ForcedTimeout = $Null
    } elseif(PhraseMatch $params 'id') {
        $auth_server_instance.Id = $Null
    } elseif(PhraseMatch $params 'ldap' -prefix) {
        if($params.Count -eq 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'cn' -offset 1) {
            $auth_server_instance.CN = $Null
        } elseif(PhraseMatch $params 'dn' -offset 1) {
            $auth_server_instance.DN = $Null
        } elseif(PhraseMatch $params 'port',$RE_INTEGER -offset 1) {
            $auth_server_instance.PortNumber = $Null
        } elseif(PhraseMatch $params 'server-name' -offset 1) {
            $auth_server_instance.ServerName = $Null
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'radius' -prefix) {
        if($params.Count -eq 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'accounting-port' -offset 1) {
            $auth_server_instance.AccountingPortNumber = $Null
        } elseif(PhraseMatch $params 'attribute','acct-session-id','length' -offset 1) {
            $auth_server_instance.AccountSessionIdLength = $Null
        } elseif(PhraseMatch $params 'attribute','calling-station-id' -offset 1) {
            $auth_server_instance.CallingStationId = $Null
        } elseif(PhraseMatch $params 'compatibility','rfc-2138' -offset 1) {
            $auth_server_instance.CompatibeWithRFC2138 = $False
        } elseif(PhraseMatch $params 'port' -offset 1) {
            $auth_server_instance.PortNumber = $Null
        } elseif(PhraseMatch $params 'retries' -offset 1) {
            $auth_server_instance.ClientRetries = $Null
        } elseif(PhraseMatch $params 'secret' -offset 1) {
            $auth_server_instance.SharedSecret = $Null
        } elseif(PhraseMatch $params 'timeout' -offset 1) {
            $auth_server_instance.ClientTimeout = $Null
        } elseif(PhraseMatch $params 'zone-verification' -offset 1) {
            $auth_server_instance.ZoneVerification = $False
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'securid' -prefix) {
        if($params.Count -eq 1) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'auth-port' -offset 1) {
            $auth_server_instance.AuthPortNumber = $Null
        } elseif(PhraseMatch $params 'duress' -offset 1) {
            $auth_server_instance.DuressMode = $Null
        } elseif(PhraseMatch $params 'encr' -offset 1) {
            $auth_server_instance.EncryptionMode = $Null
        } elseif(PhraseMatch $params 'retries' -offset 1) {
            $auth_server_instance.ClientRetries = $Null
        } elseif(PhraseMatch $params 'timeout' -offset 1) {
            $auth_server_instance.ClientTimeout = $Null
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'server-name') {
        $auth_server_instance.ServerName = $Null
    } elseif(PhraseMatch $params 'src-interface') {
        $auth_server_instance.SourceInterface = $Null
    } elseif(PhraseMatch $params 'tacacs' -prefix) {
        if($params.Count -eq 0) {
            Write-Warning "Not implemented @ $($myinvocation.mycommand.name): $line"
        } elseif(PhraseMatch $params 'port' -offset 1) {
            $auth_server_instance.PortNumber = $Null
        } elseif(PhraseMatch $params 'secret' -offset 1) {
            $auth_server_instance.SharedSecret = $Null
        } else {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }
    } elseif(PhraseMatch $params 'timeout') {
        $auth_server_instance.Timeout = $Null
    } elseif(PhraseMatch $params 'type') {
        # Accouding to the manual, the unset command sets type to radius.
        if($auth_server_instance -isnot [SecuIDAuthServerProfile]) {
            $auth_server_instance = New-Object SecuIDAuthServerProfile($auth_server_instance)
            $AuthServerDic[$auth_server_name] = $auth_server_instance
        }
    } elseif(PhraseMatch $params 'username','domain') {
        $auth_server_instance.DomainName = $Null
    } elseif(PhraseMatch $params 'username','separator') {
        $auth_server_instance.Separator = $Null
        $auth_server_instance.Portions = $Null
    } elseif(PhraseMatch $params 'zone-verification') {
        $auth_server_instance.ZoneVerification = $False
    } else {
        throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
    }
}

Set-Variable -Scope Script -Option Constant -Name SectionConfiguration -Value {
    ########## == Date/Time
    Write-Section $STYLE_HEADING2 'Date/Time' -keyword 'clock' -skip:($ClockProfile -eq $Null) {
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
          -Title @('#','Attribute','Value','memo') `
          -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

        $col_list_style_code = @()
        $script:current_row = $table.Rows.Last

        Write-AVRow 'Set Time Zone' $ClockProfile.Timezone '{0} hours from GMT'
        if($ClockProfile.DST -eq $Null) {
            Write-AVRow 'Automatically adjust clock for daylight saving changes(DST)' $False
        } else {
            Write-AVRow 'Automatically adjust clock for daylight saving changes(DST)' $True

            #
        }

        if($ClockProfile.NTP -eq $Null) {
            Write-AVRow 'Automatically synchronize with an Internet Time Server(NTP)' $False
        } else {
            Write-AVRow 'Automatically synchronize with an Internet Time Server(NTP)' $True
            Write-AVRow '  Update system clock every' $ClockProfile.NTP.UpdateIntervalMinute
            Write-AVRow '  Maximum time adjustment' $ClockProfile.NTP.MaximumTimeAdjustmentSecond
            Write-AVRow '  Authentication mode' $ClockProfile.NTP.NTPAuthMode

            foreach($element in $ClockProfile.NTP.List) {
                if($element -is [NTPProfileElement]) {
                    Write-AVRow '  NTP Server' $element.Server
                    $col_list_style_code += $table.Rows.Last.Index

                    if($element.Interface -ne '') {
                        Write-AVRow '    Source interface' $element.Interface
                        $col_list_style_code += $table.Rows.Last.Index
                    }

                    if($element.KeyID -ne '') {
                        Write-AVRow '    Key ID' $element.KeyID
                        $col_list_style_code += $table.Rows.Last.Index
                    }

                    if($element.PresharedKey -ne '') {
                        Write-AVRow '    Preshared Key' $element.PresharedKey
                        $col_list_style_code += $table.Rows.Last.Index
                    }
                }
            }
        }

        $col_list_style_code | foreach { $script:table.Cell($_,3).Range.Style = $STYLE_CODE }
    }


    ########## == Admin
    Write-Section $STYLE_HEADING2 'Admin' -skip:($AdminProfile -eq $Null) {

        Write-Section $STYLE_HEADING3 'Administrators' -keyword 'administrator' {

            ########## ==== External Database Admin Settings
            $range = Insert-TextAtLast $STYLE_HEADING4 "External Database Admin Settings`n"
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
              -Title @('#','Attribute','Value','memo') `
              -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

            $col_list_style_code = @()
            $script:current_row = $table.Rows.Last

            Write-AVRow 'Admin Privileges' $(switch($AdminProfile.PrivilegeMode) {
						 'ReadOnly' { 'External admin has read-only privilege' }
						 'GetExternal' { 'Get privilege from RADIUS server' }
						 'ReadWrite' { 'External admin has read-write privilege' }
					     })
            Write-AVRow 'Admin Auth Server' $AdminProfile.AdminAuthServer
            $col_list_style_code += $table.Rows.Last.Index

            $col_list_style_code | foreach { $script:table.Cell($_,3).Range.Style = $STYLE_CODE }

            ########## ==== Remote Server Settings
            $range = Insert-TextAtLast $STYLE_HEADING4 "Remote Server Settings`n"
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
              -Title @('#','Attribute','Value','memo') `
              -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

            $script:current_row = $table.Rows.Last
            Write-AVRow 'The remote Auth server will have priority' $AdminProfile.RemoteServerSetting.Primary
            Write-AVRow 'Fallback' ''
            Write-AVRow '  Permit Root' $AdminProfile.RemoteServerSetting.FallbackPermitRoot
            Write-AVRow '  Permit non-root' $AdminProfile.RemoteServerSetting.FallbackPermitNonRoot
            Write-AVRow 'Accept remotely authenticated ROOT privileged admins' $AdminProfile.RemoteServerSetting.Root
            Write-AVRow 'Enable Web Management Idle Timeout (0: Disable)' $AdminProfile.AdminAuthTimeout

            ########## ==== Local Administrator Database
            $range = Insert-TextAtLast $STYLE_HEADING4 "Local Administrator Database`n"
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows $AdminProfile.LocalDB.Count  -Cols 6 `
              -Title @('#','Administrator Name','Privileges','Role','SSH Password Auth.','memo') `
              -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$Null,$Null,$Null,$Null)

            $i_row = 2
            foreach($administrator_name in $AdminProfile.LocalDB.keys | Sort-Object) {
                $administrator_entry = $AdminProfile.LocalDB[$administrator_name]
                Write-Block2Cells $table.Cell($i_row,2) {
                    $administrator_name
                    switch($administrator_entry.Privilege) {
                        'Root' { 'Root' }
                        'All' { 'All' }
                        'ReadOnly' { 'Read-Only' }
                        default { throw "Unknown Admin Privilege Mode $($administrator_entry.Privilege)." }
                    }
                    switch($administrator_entry.Role) {
                        'Non' { '-' }
                        'Audit' { 'Audit' }
                        'Cryptographic' { 'Cryptographic' }
                        'Security' { 'Security' }
                        default { throw "Unknown Admin Privilege Mode $($administrator_entry.Role)." }
                    }
                    EnabledOrDisabled $administrator_entry.SSHPasswordAuthEnabled
                }
                $i_row += 1
            }


            ########## ==== Miscellaneous
            $range = Insert-TextAtLast $STYLE_HEADING4 "Miscellaneous`n"
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
              -Title @('#','Attribute','Value','memo') `
              -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

            $script:current_row = $table.Rows.Last
            Write-AVRow 'Number of Lines for a Console Page' $AdminProfile.ConsolePage
            Write-AVRow 'Configuration File Format' $AdminProfile.ConfigFileFormat
            Write-AVRow 'Http Redirect' $AdminProfile.HttpRecirect
        }
    }

    ########## === Permitted IPs
    Write-Section $STYLE_HEADING3 'Permitted IPs' -keyword 'permittedIP' -skip:($AdminProfile -eq $Null -or $AdminProfile.PermittedIP.Count -lt 1) {
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows $AdminProfile.PermittedIP.Count -Cols 3 `
          -Title @('#','IP Address/Mask','memo') `
          -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$Null)

        $i_row = 2
        foreach($permitted_ip in $AdminProfile.PermittedIP) {
            Write-Block2Cells $table.Cell($i_row,2) {
                $permitted_ip
            }
            $i_row += 1
        }
    }

    ########## === Management
    Write-Section $STYLE_HEADING3 'Management' -keyword 'management' -skip:($ManagementProfile -eq $Null) {
        $range = Insert-TextAtLast $STYLE_BODYTEXT

        $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
          -Title @('#','Attribute','Value','memo') `
          -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

        $col_list_style_code = @()
        $script:current_row = $table.Rows.Last

        if($ManagementProfile.SSHProfile -ne $Null) {
            Write-AVRow 'SSH' ''
            Write-AVRow '  SSH Version' $(if($ManagementProfile.SSHProfile -is [SSHV1Profile]) {
					      'Version 1'
					  } elseif($ManagementProfile.SSHProfile -is [SSHV2Profile]) {
					      'Version 2'
					  } else {
					      $Null
					  })
            Write-AVRow '  SSH' $ManagementProfile.SSHProfile.Enable
            Write-AVRow '  Port Number' $ManagementProfile.SSHProfile.PortNumber
            Write-AVRow '  SCP ' $ManagementProfile.SSHProfile.SCP
        }

        $col_list_style_code | foreach { $script:table.Cell($_,3).Range.Style = $STYLE_CODE }
    }

    ########## === NSM
    ########## === Banners
    ########## === Audit Setting
    ########## ==== Exclude Rules

    ########## == Authentication
    Write-Section $STYLE_HEADING2 'Authentication' {
	########## === WebAuth
	########## === Firewall
	########## === Auth Servers
        Write-Section $STYLE_HEADING3 'Auth Servers' -keyword 'auth_server' -skip:($AuthServerDic.Count -lt 1) {
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows $AuthServerDic.Count -Cols 6 `
              -Title @('ID','Name','Server IP/Name','Type','Acct Type','memo') `
              -Style @($Null,$STYLE_CODE,$STYLE_CODE,$Null,$Null,$Null) `
              -DontRenumber

            [string]$auth_server_name = $Null
            [AuthServerProfile]$auth_server_instance = $Null
            [int]$i_row = 2
            foreach($auth_server_name in $AuthServerDic.keys | Sort-Object) {
                $auth_server_instance = $AuthServerDic[$auth_server_name]
                Write-Block2Cells $table.Cell($i_row,1) {
                    $auth_server_instance.Id
                    $auth_server_instance.Name
                    $auth_server_instance.ServerName
                    if($auth_server_instance.AccountType -eq $Null) {
                        '(default)'
                    } else {
                        $auth_server_instance.AccountType.GetTypeNames() -join ', '
                    }
                }
                $i_row++
            }
        }

        foreach($auth_server_name in $AuthServerDic.keys | Sort-Object) {
            $auth_server_instance = $AuthServerDic[$auth_server_name]

            ########## ==== $auth_server_name
            Write-Section $STYLE_HEADING4 $auth_server_name {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
                  -Title @('#','Attribute','Value','memo') `
                  -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

                $col_list_style_code = @()
                $script:current_row = $table.Rows.Last

                Write-AVRow 'ID' $auth_server_instance.Id
                Write-AVRow 'Name' $auth_server_name
                $col_list_style_code += $table.Rows.Last.Index
                if($auth_server_name -eq $DefaultAuthServerName) {
                    Write-AVRow 'Default Authentication Server' 'True'
                }
                if($auth_server_instance.ServerName -ne '') {
                    Write-AVRow 'Server IP/Name' $auth_server_instance.ServerName
                    $col_list_style_code += $table.Rows.Last.Index
                }
                Write-AVRow 'Type of Authentication Server' (Get-AuthServerType $auth_server_instance)
                if($auth_server_instance.AccountType -ne $Null) {
                    Write-AVRow 'Types of users authenticated by the server' ($auth_server_instance.AccountType.GetTypeNames() -join ', ')
                }
                if($auth_server_instance.Backup1 -ne '') {
                    Write-AVRow 'Primary Backup Authentication Server' $auth_server_instance.Backup1
                    $col_list_style_code += $table.Rows.Last.Index
                }
                if($auth_server_instance -is [AuthServerWithDoubleBackupProfile] -and $auth_server_instance.Backup2 -ne '') {
                    Write-AVRow 'Secondary Backup Authentication Server' $auth_server_instance.Backup2
                    $col_list_style_code += $table.Rows.Last.Index
                }
                Write-AVRow 'Fail-over Revert-interval Time in second' $auth_server_instance.FailOverRevertInterval
                Write-AVRow 'Forced Timeout in minutes' $auth_server_instance.ForcedTimeout
                if($auth_server_instance.SourceInterface -ne '') {
                    Write-AVRow 'Source Interface' $auth_server_instance.SourceInterface
                    $col_list_style_code += $table.Rows.Last.Index
                }
                Write-AVRow 'Timeout' $auth_server_instance.Timeout
                if($auth_server_instance.Separator -ne '') {
                    Write-AVRow 'Separator' $auth_server_instance.Separator
                    $col_list_style_code += $table.Rows.Last.Index
                }
                Write-AVRow 'Portions' $auth_server_instance.Portions
                if($auth_server_instance.DomainName -ne '') {
                    Write-AVRow 'Domain Name' $auth_server_instance.DomainName
                    $col_list_style_code += $table.Rows.Last.Index
                }

                switch($auth_server_instance.GetType()) {
                    [LDAPAuthServerProfile] {
                        Write-AVRow 'Port Number ' $auth_server_instance.PortNumber
                        if($auth_server_instance.CN -ne '') {
                            Write-AVRow 'Common Name (CN)' $auth_server_instance.CN
                            $col_list_style_code += $table.Rows.Last.Index
                        }
                        if($auth_server_instance.DN -ne '') {
                            Write-AVRow 'Distinguished Name (DN)' $auth_server_instance.DN
                            $col_list_style_code += $table.Rows.Last.Index
                        }
                        break
                    }
                    [RadiusAuthServerProfile] {
                        Write-AVRow 'Port Number ' $auth_server_instance.PortNumber
                        Write-AVRow 'Client Retries' $auth_server_instance.ClientRetries
                        Write-AVRow 'Client Timeout' $auth_server_instance.ClientTimeout
                        Write-AVRow 'Shared Secret' $(if($auth_server_instance.SharedSecret -ne $Null) { '(omit)' })
                        Write-AVRow 'Zone Verification' (EnabledOrDisabled $auth_server_instance.ZoneVerification)
                        Write-AVRow 'Accounting Port Number' $auth_server_instance.AccountingPortNumber
                        Write-AVRow 'Account SessionId Length' $auth_server_instance.AccountSessionIdLength
                        Write-AVRow 'Calling Station Id' $auth_server_instance.CallingStationId
                        Write-AVRow 'Compatibe with RFC2138' (EnabledOrDisabled $auth_server_instance.CompatibeWithRFC2138)
                        break
                    }
                    [SecuIDAuthServerProfile] {
                        Write-AVRow 'Port Number ' $auth_server_instance.PortNumber
                        Write-AVRow 'Client Retries' $auth_server_instance.ClientRetries
                        Write-AVRow 'Client Timeout' $auth_server_instance.ClientTimeout
                        Write-AVRow 'Authentication Port Number' $auth_server_instance.PortNumber
                        Write-AVRow 'SecuID Duress Mode' $auth_server_instance.SecuIDDuressMode
                        Write-AVRow 'SecuID Encryption Mode' $auth_server_instance.SecuIDEncryptionMode
                        break
                    }
                    [TACACSAuthServerProfile] {
                        Write-AVRow 'Port Number ' $auth_server_instance.PortNumber
                        Write-AVRow 'Shared Secret' $(if($auth_server_instance.SharedSecret -ne $Null) { '(omit)' })
                        break
                    }
                }

                $col_list_style_code | foreach { $script:table.Cell($_,3).Range.Style = $STYLE_CODE }
            }
        }
    }


    ########## == Infranet Auth
    ########## === Controllers
    ########## === General Settings
    ########## === Auth Table

    ########## == Report Settings
    Write-Section $STYLE_HEADING2 'Report Settings' {
        ########## === Self log
        Write-Section $STYLE_HEADING3 'Self log' -keyword 'log-self' -skip:($FirewallLogSelfProfile -eq $Null){
            $range = Insert-TextAtLast $STYLE_BODYTEXT

            $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
              -Title @('#','Attribute','Value','memo') `
              -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

            $script:current_row = $table.Rows.Last

            Write-AVRow 'Log Packets Terminated to Self' (ConcreteValueOrDefault $FirewallLogSelfProfile.Enabled)
            Write-AVRow '  ICMP' $FirewallLogSelfProfile.ICMP
            Write-AVRow '  IKE' $FirewallLogSelfProfile.IKE
            Write-AVRow '  Multicast' $FirewallLogSelfProfile.Multicalst
            Write-AVRow '  SNMP' $FirewallLogSelfProfile.SNMP
            Write-AVRow '  Telnet' $FirewallLogSelfProfile.Telnet
            Write-AVRow '  SSH' $FirewallLogSelfProfile.SSH
            Write-AVRow '  Web' $FirewallLogSelfProfile.Web
            Write-AVRow '  NSM' $FirewallLogSelfProfile.NSM
        }

        ########## === Log Settings
        ########## === Email
        ########## === SNMP
        Write-Section $STYLE_HEADING3 'SNMP' -keyword 'snmp' -skip:($SNMPProfile -eq $Null) {

            ########## ==== SNMP Report Settings
            Write-Section $STYLE_HEADING4 'SNMP Report Settings' {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
                  -Title @('#','Attribute','Value','memo') `
                  -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

                $col_list_style_code = @()
                $script:current_row = $table.Rows.Last

                Write-AVRow 'System Name' (OmitEmptyString $SNMPProfile.SystemName)
                Write-AVRow 'System Contact' (OmitEmptyString $SNMPProfile.SystemContact)
                Write-AVRow 'Location' (OmitEmptyString $SNMPProfile.Location)
                Write-AVRow 'Listen Port' $SNMPProfile.ListenPort
                Write-AVRow 'Trap Port' $SNMPProfile.TrapPort
                Write-AVRow 'Enable Authentication Fail Trap' $SNMPProfile.AuthenticationFailTrap

                $col_list_style_code | foreach { $script:table.Cell($_,3).Range.Style = $STYLE_CODE }
            }

            ########## ==== Communities
            Write-Section $STYLE_HEADING4 'Communities' -skip:($SNMPProfile.SNMPCommunity.Count -lt 1) {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows $SNMPProfile.SNMPCommunity.Count -Cols 7 `
                  -Title @('#','Name','Write','Trap','Traffic','Hosts','memo') `
                  -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$Null,$Null,$Null,$STYLE_CODE,$Null)

                $i_row = 2
                [SNMPCommunity]$community_instance = $Null
                [SNMPManagementHost]$management_host_instance = $Null
                foreach($community_name in $SNMPProfile.SNMPCommunity.keys | Sort-Object) {
                    $community_instance = $SNMPProfile.SNMPCommunity[$community_name]
                    Write-Block2Cells $table.Cell($i_row,2) {
                        $community_instance.Name
                        switch($community_instance.Write) {
                            $Null { $Null; break }
                            $True { 'Read/Write'; break }
                            $false { 'Read only'; break }
                        }
                        EnabledOrDisabled $community_instance.Trap
                        EnabledOrDisabled $community_instance.Traffic
                        $(
                            foreach($management_host_instance in $community_instance.SNMPManagementHost | Sort-Object) {
                                $(
                                    $management_host_instance.IPAddr
                                    if($management_host_instance.SourceInterface -ne '') {
                                        $management_host_instance.SourceInterface
                                    }
                                    if($management_host_instance.SNMPTrapVersion -ne $Null) {
                                        $management_host_instance.SNMPTrapVersion
                                    }
                                ) -join ', '
                            }
                        ) -join "`n"
                    }
                    $i_row++
                }
            }

            ########## ==== MIB Filters
            Write-Section $STYLE_HEADING4 'MIB Filters' {
                $range = Insert-TextAtLast $STYLE_BODYTEXT
            }
        }

        ########## === Syslog
        Write-Section $STYLE_HEADING3 'Syslog' -keyword 'syslog' {

            ########## ==== Basic
            Write-Section $STYLE_HEADING4 'Basic' -skip:($SyslogProfile -eq $Null) {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows 1 -Cols 4 `
                  -Title @('#','Attribute','Value','memo') `
                  -Style @($STYLE_LISTNUMBER,$Null,$Null,$Null)

                $col_list_style_code = @()
                $script:current_row = $table.Rows.Last

                Write-AVRow 'Enable syslog messages' $SyslogProfile.Enabled
                Write-AVRow 'Enable Backup' $SyslogProfile.Backup
                if($SyslogProfile.SourceInterface -ne '') {
                    Write-AVRow 'Source Interface' $SyslogProfile.SourceInterface
                    $col_list_style_code += $table.Rows.Last.Index
                }
                $col_list_style_code | foreach { $script:table.Cell($_,3).Range.Style = $STYLE_CODE }
            }

            ########## ==== Syslog servers
            Write-Section $STYLE_HEADING4 'Syslog servers' -skip:($SyslogProfile -eq $Null -or $SyslogProfile.SyslogServer -eq $Null) {
                $range = Insert-TextAtLast $STYLE_BODYTEXT

                $script:table = Add-TableToDoc -Range $range -Rows $SyslogProfile.SyslogServer.Count -Cols 9 `
                  -Title @('#','IP/Hostname','Port','Facility',$Null,'Log',$Null,'TCP','memo') `
                  -Style @($STYLE_LISTNUMBER,$STYLE_CODE,$Null,$Null,$Null,$Null,$Null,$Null,$Null)

                (Select-CellRange $table  1 4  1 7).Cells.Split(2,1)

                Write-Block2Cells $table.Cell(2,4) {
                    'Security'
                    'Regular'
                    'Event'
                    'Traffic'
                }

                (Select-CellRange $table  1 6  1 7).Cells.Merge()
                (Select-CellRange $table  1 4  1 5).Cells.Merge()

                $i_row = 3
                foreach($syslog_server_name in $SyslogProfile.SyslogServer.keys | Sort-Object) {
                    $syslog_server_instance = $SyslogProfile.SyslogServer[$syslog_server_name]
                    Write-Block2Cells $table.Cell($i_row,2) {
                        $syslog_server_name
                        ConcreteValueOrDefault $syslog_server_instance.PortNumber
                        $syslog_server_instance.SecurityFacility
                        $syslog_server_instance.RegularFacility
                        EnabledOrDisabled $syslog_server_instance.EventLog
                        EnabledOrDisabled $syslog_server_instance.TrafficLog
                        EnabledOrDisabled $syslog_server_instance.TCP
                    }
                    $i_row++
                }
            }
        }

        ########## === WebTrends
    }
}

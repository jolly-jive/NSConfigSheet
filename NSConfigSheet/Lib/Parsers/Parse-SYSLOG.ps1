Function Parse-ROOT-Set-Syslog
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($SyslogProfile -eq $Null) {
        $script:SyslogProfile = New-Object SyslogProfile
    }

    [SyslogServer]$syslog_server_instance = $Null
    $state = 'BEGIN'
    while($params.Count -gt 0) {
        switch($state) {
            'BEGIN' {
                if(PhraseMatch $params 'enable') {
                    $SyslogProfile.Enabled = $True
                    $params = @(ncdr $params 1)
                    $state = 'ENABLE READ'
                } elseif(PhraseMatch $params 'config',$RE_QUOTED_NAME -prefix) {
                    $syslog_server_name = $last_matches[0]['QUOTED_NAME']
                    if(-not $SyslogProfile.SyslogServer.Contains($syslog_server_name)) {
                        $syslog_server_instance = New-Object SyslogServer
                        $SyslogProfile.SyslogServer[$syslog_server_name] = $syslog_server_instance
                        $SyslogProfile.SyslogServer[$syslog_server_name].Name = $syslog_server_name
                    } else {
                        $syslog_server_instance = $SyslogProfile.SyslogServer[$syslog_server_name]
                    }
                    $params = @(ncdr $params 2)
                    $state = 'HOST READ'
                } elseif(PhraseMatch $params 'backup','enable') {
                    $SyslogProfile.Backup = $True
                    $params = @(ncdr $params 2)
                    $state = 'BACKUP READ'
                } elseif(PhraseMatch $params 'src-interface',$RE_INTERFACE_NAME -prefix) {
                    $SyslogProfile.SourceInterface = $last_matches[0]['INTERFACE_NAME']
                    $state = 'SRC-INTERFACE READ'
                    $params = @(ncdr $params 2)
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'HOST READ' {
                if(PhraseMatch $params 'facilities',$RE_SYSLOG_FACILITY,$RE_SYSLOG_FACILITY -prefix) {
                    $syslog_server_instance.SecurityFacility = [SyslogFacility]$params[1]
                    $syslog_server_instance.RegularFacility = [SyslogFacility]$params[2]
                    $params = @(ncdr $params 3)
                } elseif(PhraseMatch $params 'log','all' -prefix) {
                    $syslog_server_instance.EventLog = $True
                    $syslog_server_instance.TrafficLog = $True
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'log','event' -prefix) {
                    $syslog_server_instance.EventLog = $True
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'log','traffic' -prefix) {
                    $syslog_server_instance.TrafficLog = $True
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'port',$RE_INTEGER -prefix) {
                    $syslog_server_instance.PortNumber = [int]$params[1]
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params 'src-interface',$RE_INTERFACE_NAME) {
                    $syslog_server_instance.SourceInterface = $last_matches[0]['INTERFACE_NAME']
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'transport','tcp' -prefix) {
                    $syslog_server_instance.TCP = $True
                    $params = @(ncdr $params 2)
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'ERROR' {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
            default {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
        }
    }
}

Function Parse-ROOT-Unset-Syslog
{
    [CmdletBinding()]
    param(
        [string[]]
        [parameter(Mandatory=$true)]
        $params
    )

    if($SyslogProfile -eq $Null) {
        $script:SyslogProfile = New-Object SyslogProfile
    }

    [SyslogServer]$syslog_server_instance = $Null
    $state = 'BEGIN'
    while($params.Count -gt 0) {
        switch($state) {
            'BEGIN' {
                if(PhraseMatch $params 'enable') {
                    $SyslogProfile.Enabled = $False
                    $params = @(ncdr $params 1)
                    $state = 'ENABLE READ'
                } elseif(PhraseMatch $params 'config',$RE_QUOTED_NAME -prefix) {
                    $syslog_server_name = $last_matches[0]['QUOTED_NAME']
                    if($params.Count -eq 2) {
                        if($SyslogProfile.SyslogServer.Contains($syslog_server_name)) {
                            $SyslogProfile.SyslogServer.Remove($syslog_server_name)
                        } else {
                            $syslog_server_instance = $SyslogProfile.SyslogServer[$syslog_server_name]
                        }
                    }
                    $params = @(ncdr $params 2)
                    $state = 'HOST READ'
                } elseif(PhraseMatch $params 'backup','enable') {
                    $SyslogProfile.Backup = $False
                    $params = @(ncdr $params 2)
                    $state = 'BACKUP READ'
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'HOST READ' {
                if(PhraseMatch $params 'log','all') {
                    $syslog_server_instance.EventLog = $False
                    $syslog_server_instance.TrafficLog = $False
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'log','event') {
                    $syslog_server_instance.EventLog = $False
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'log','traffic') {
                    $syslog_server_instance.TrafficLog = $False
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'port') {
                    $syslog_server_instance.PortNumber = $Null
                    $params = @(ncdr $params 1)
                } elseif(PhraseMatch $params 'src-interface') {
                    $syslog_server_instance.SourceInterface = $Null
                    $params = @(ncdr $params 2)
                } elseif(PhraseMatch $params 'transport') {
                    $syslog_server_instance.TCP = $False
                    $params = @(ncdr $params 2)
                } else {
                    $state = 'ERROR'
                }
                break
            }
            'ERROR' {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
            default {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
        }
    }
}

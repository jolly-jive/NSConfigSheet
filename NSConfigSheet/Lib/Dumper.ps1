Function DumpUnlessNull($obj)
{
    if($obj -ne $Null) {
        $obj
    }
}

Function Dump-ConfigVariable
{
    param([string[]]$Dump)

    switch -Regex ($Dump) {
        '^(clock|all)$' {
            DumpUnlessNull $ClockProfile
        }
        '^(admin|all)$' {
            DumpUnlessNull $AdminProfile
        }
        '^(auth_server|all)$' {
            $AuthServerDic.values | Sort-Object -Property Name
        }
        '^(management|all)$' {
            DumpUnlessNull $ManagementProfile
        }
        '^(self_log|all)$' {
            DumpUnlessNull $FirewallLogSelfProfile
        }
        '^(snmp|all)$' {
            DumpUnlessNull $SNMPProfile
        }
        '^(syslog|all)$' {
            DumpUnlessNull $SyslogProfile
        }
        '^(vrouter|all)$' {
            $VRouterDic.keys | Sort-Object | foreach { $VRouterDic[$_] }
        }
        '^(nsrp|all)$' {
            DumpUnlessNull $NSRPProfile
        }
        '^(screening|all)$' {
            $ScreeningDic.values | Sort-Object -Property Zone
        }
        '^(flow|all)$' {
            DumpUnlessNull $FlowProfile
        }
        '^(zone|all)$' {
            $ZoneDic.values | Sort-Object -Property Name
        }
        '^(interface|all)$' {
            $InterfaceDic.values | Sort-Object -Property Name
        }
        '^(service|all)$' {
            $ServiceObjecteDic.keys | Sort-Object | foreach { $ServiceObjecteDic[$_] }
        }
        '^(serviceGroup|all)$' {
            $ServiceGroupDic.keys | Sort-Object | foreach { $ServiceGroupDic[$_] }
        }
        '^(address|all)$' {
            $AddressObjectDic.keys | Sort-Object | foreach { $AddressObjectDic[$_] }
        }
        '^(addressGroup|all)$' {
            $AddressGroupDic.keys | Sort-Object | foreach { $AddressGroupDic[$_] }
        }
        '^(policy|all)$' {
            $PolicyList
        }
        '^(vlanGroup|all)$' {
            $VLANGroupDic.keys | Sort-Object | foreach { $VLANGroupDic[$_] }
        }
        '^(dip|all)$' {
            $DIPDic.keys | Sort-Object | foreach { $DIPDic[$_] }
        }
        '^(mul_url|all)$' {
        }
    }
}
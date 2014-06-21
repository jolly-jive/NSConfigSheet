Set-Variable -Option ReadOnly -Scope script REGEX $([System.Text.RegularExpressions.Regex])
Set-Variable -Option ReadOnly -Scope script REGEX_OPTION $([System.Text.RegularExpressions.RegexOptions])

function Set-REConst
{
    param([string]$Name, [string]$Value = '')

    Set-Variable -Option ReadOnly -Scope script -Name $Name -Value (New-Object $REGEX($Value))
}

Set-REConst RE_IP_PROTOCOL '^tcp|udp|icmp$'
Set-REConst RE_SERVICE_3RD_WORD '^protocol|\+$'
Set-REConst RE_PORT_RANGE '^(?<LOWER>\d+)-(?<UPPER>\d+)$'
Set-REConst RE_IPV4_HOST_ADDRESS '^(?<IPV4_HOST_ADDRESS>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$'
Set-REConst RE_IPV4_ADDRESS_WITH_MASK '^(?<IPV4_ADDRESS_WITH_MASK>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2})$'
Set-REConst RE_INTERFACE_NAME '^(?:"|)(?<INTERFACE_NAME>ethernet[0-9/.]+|vlan\d+|bgroup\d+)(?:"|)$'
Set-REConst RE_QUOTED_NAME '"(?<QUOTED_NAME>.+?)"$'
Set-REConst RE_QUOTED_OR_NOT_QUOTED_NAME '(?:"|)(?<QUOTED_OR_NOT_QUOTED_NAME>.+?)(?:"|)$'
Set-REConst RE_INTEGER '(?<INTEGER>(?:|\+|-)\d+)$'
Set-REConst RE_SYSLOG_FACILITY '^auth|authpriv|cron|daemon|kern|lpr|mail|mark|news|syslog|user|uucp|local[0-7]$'
Set-REConst RE_FILE_FORMAT '^unix|dos$'
Set-REConst RE_SNMP_VERSION '^any|v1|v2c$'
Set-REConst RE_SNMP_TRAP_VERSION '^v1|v2$'
Set-REConst RE_NSRP_METHOD '^arp|ping$'
Set-REConst RE_POLICY_ACTION '^permit|deny|reject$'
Set-REConst RE_FIREWALL_TRAFFIC_TYPE '^icmp|ike|multicast|snmp|telnet|ssh|web|nsm|ike$'
Set-REConst RE_INTERFACE_DUPLEX '^full|half$'
Set-REConst RE_INTERFACE_SPEED '^10mb|100mb|1000mb$'
Set-REConst RE_AUTH_SERVER_TYPE '^ldap|radius|securid|tacacs$'
Set-REConst RE_BANNER_APPLICATION '^(?<BANNER_APPLICATION>telnet|http|telnet)$'
Set-REConst RE_BANNER_PHASE '^(?<BANNER_PHASE>fail|login|success)$'
Set-REConst RE_MANAGEMENT_SERVICE '^(?<MANAGEMENT_SERVICE>web|webui|telnet|ssh|snmp|ssl|ping|mtrace)$'

Set-REConst RE_COMMENT_LINE '^#.*$'
Set-REConst RE_BLANK_LINE '^\s*$'

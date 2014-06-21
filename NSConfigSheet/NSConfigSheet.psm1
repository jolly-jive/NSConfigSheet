# Copyright (C) 2011-2014 Jolly.Jive@gmail.com
# 
# This file is part of NSConfigSheet.
# 
# NSConfigSheet is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# NSConfigSheet is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with NSConfigSheet.  If not, see
# <http://www.gnu.org/licenses/>.

Set-StrictMode -Version Latest

Get-ChildItem -Recurse -Filter *.ps1 -Path $(Join-Path $PSScriptRoot 'Lib') | ForEach-Object {
    . $_.FullName
}

Set-Variable -Scope Global -Name NSConfigSheetTemplate

<#
.SYNOPSIS
Convert a ScreenOS configuration file to a configuration sheet in format of Microsoft Word document.

.DESCRIPTION
The ConvertTo-NSConfigSheet cmdlet converts a ScreenOS configuration file to a configuration sheet in format of Microsoft Word document.

.INPUTS
Nothing.

.OUTPUTS
Parsed objects when Dump parameter is given.

.NOTES
All names of products and services are trademarks or registered trademarks of their respective companies.
#>
function ConvertTo-NSConfigSheet
{
    [CmdletBinding()]
    param(
        # The ScreenOS configuration filename.
        [string]
        [parameter(Mandatory=$true)]
        $ScreenOSConfigFile,

        # The filename of the configuration sheet in format of Microsoft Word document.
        [string]
        $WordFile = '',

        # Dump configuration objects generated from the configuration file.
        [string[]]
        [ValidateSet('clock','admin','auth_server','management','self_log','snmp','syslog','vrouter','nsrp','screening','flow','zone','interface','service','serviceGroup','address','addressGroup','policy','vlanGroup','mul_url','all')]
        $Dump = @(),

        # Sections not to write to the configuration file.
        [string[]]
        [ValidateSet('clock','administrator','permittedIP','management','auth_server','log-self','snmp','syslog','binding','zone','each_zone','interface','each_interface','routing','nsrp','screening','mul_url','flow','service','address','policy','vrouter','vlanGroup')]
        $ExcludeSection = @(),

        # A template name of Microsoft Word which is applied to the configuration sheet.
        # This parameter overrides Variable $NSConfigSheetTemplate.
        [string]
        $Template = '',

        # Display the Word Application. If this switch is present, the application is not terminated automatically.
        [switch]
        $Visible
    )

    $ErrorActionPreference = 'Stop'

    $script:ExcludeSection = $ExcludeSection

    [System.Collections.Stack]$script:context = New-Object System.Collections.Stack
    [string]$script:line = ''

    [string]$script:device_name = ''
    [ClockProfile]$script:ClockProfile = $Null
    [AdminProfile]$script:AdminProfile = $Null
    [Hashtable]$script:AuthServerDic = @{}
    [string]$script:DefaultAuthServerName = ''
    [string]$script:administrator_name = $Null
    [ManagementProfile]$script:ManagementProfile = $Null
    [FirewallLogSelfProfile]$script:FirewallLogSelfProfile = $Null
    [SNMPProfile]$script:SNMPProfile = $Null
    [SyslogProfile]$script:SyslogProfile = $Null
    [Hashtable]$script:VRouterDic = @{}
    [NSRPProfile]$script:NSRPProfile = $Null
    [Hashtable]$script:ScreeningDic = @{}
    [FlowProfile]$script:FlowProfile = $Null
    [Hashtable]$script:ZoneDic = @{}
    [Hashtable]$script:InterfaceDic = @{}
    [Hashtable]$script:ServiceObjecteDic = @{}
    [Hashtable]$script:ServiceGroupDic = @{}
    [Hashtable]$script:AddressObjectDic = @{}
    [Hashtable]$script:AddressGroupDic = @{}
    [Policy[]]$script:PolicyList = @()
    [Hashtable]$script:PolicyDic = @{}
    [Hashtable]$script:VLANGroupDic = @{}

    [int]$script:policy_id = 0

    [Array]$script:last_matches = $Null

    [string]$script:vr_name = ''

    [Microsoft.Office.Interop.Word.Document]$script:doc = $Null
    [Microsoft.Office.Interop.Word.Application]$script:msword = $Null
    $script:table = $Null
    $script:current_row = $Null


    $context.Push('ROOT') # Set the root context.

    foreach( $line in Get-Content $ScreenOSConfigFile -ErrorAction Stop ) {
        if($line -match $RE_BLANK_LINE) {
            continue
        }
        if($line -match $RE_COMMENT_LINE) {
            Write-Verbose "$line"
            continue
        }
        [string[]]$params = @()
        [string]$tail = $line
        while($tail.Length -gt 0) {
            switch -regex ($tail) {
                '^\s+(?<TAIL>.*)$' {
                    # nothing to be done
                }
                '^(?<PARAM>".+?"|\S+)(?<TAIL>.*)$' {
                    $params += $matches['PARAM']
                }
            }
            $tail = $matches['TAIL']
        }
        if($params.Count -lt 1) {
            throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
        }

        switch($context.Peek()) {
            'CRYPTO-POLICY' { Parse-CRYPTO-POLICY $params }
            'ROOT' { Parse-ROOT $params }
            'VROUTER' { Parse-VROUTER $params }
            'POLICY' { Parse-POLICY $params }
            'URL PROTOCOL' { Parse-URL-PROTOCOL $params }
            default {
                throw "SYNTAX ERROR @ $($myinvocation.mycommand.name): $line"
            }
        }
    }


    foreach($vr_name in $VRouterDic.keys) {
        if($VRouterDic[$vr_name].AddDefaultRouteVrouter -ne '') {
            $route = New-Object RouteRecord
            $route.Destination = '0.0.0.0/0'
            $route.Interface = '-'
            $route.Gateway = $VRouterDic[$vr_name].AddDefaultRouteVrouter
            $VRouterDic[$vr_name].Route += $route
        }
    }


    ##################################################
    Dump-ConfigVariable $Dump


    ##################################################
    if($WordFile -eq '') {
        return
    }


    if(-not [System.IO.Path]::IsPathRooted($WordFile)) {
        $WordFile = Join-Path $PWD $WordFile
    }


    ##################################################
    try {
        $script:msword = New-Object -ComObject 'Word.Application'
        $msword.Visible = $Visible

        if($Template -eq '' -and $NSConfigSheetTemplate -is [string]) {
            $Template = $NSConfigSheetTemplate
        }
        $script:doc = $msword.Documents.Add($Template)

        $styles = $doc.Styles

        Set-Variable -Scope Script -Name STYLE_HEADING1 -Value $styles.Item($enumWdStyleHeading1)
        Set-Variable -Scope Script -Name STYLE_HEADING2 -Value $styles.Item($enumWdStyleHeading2)
        Set-Variable -Scope Script -Name STYLE_HEADING3 -Value $styles.Item($enumWdStyleHeading3)
        Set-Variable -Scope Script -Name STYLE_HEADING4 -Value $styles.Item($enumWdStyleHeading4)
        Set-Variable -Scope Script -Name STYLE_HEADING5 -Value $styles.Item($enumWdStyleHeading5)

        Set-Variable -Scope Script -Name STYLE_BODYTEXT -Value $styles.Item($enumWdStyleBodyText)
        Set-Variable -Scope Script -Name STYLE_LISTNUMBER -Value $styles.Item($enumWdStyleListNumber)

        Set-Variable -Scope Script -Name STYLE_CODE -Value $styles.Item($enumWdStyleHtmlSamp)

        ########## Properties / Title
        if($device_name -eq '') {
            $device_name = Split-Path -Leaf $ScreenOSConfigFile
        }
        Write-Verbose "Set Word property"
        #http://blogs.technet.com/b/heyscriptingguy/archive/2009/12/29/hey-scripting-guy-december-29-2009.aspx
        #http://msdn.microsoft.com/ja-jp/library/microsoft.office.interop.word.wdbuiltinproperty%28v=Office.11%29.aspx
        foreach($property in $doc.BuiltInDocumentProperties) {
            $name = $ComObject.InvokeMember('name',$enumGetProperty,$Null,$property,$Null)

            try {
                $value = $ComObject.InvokeMember('value',$enumGetProperty,$Null,$property,$Null)
            } catch [System.Exception] {
                $value = '<NO VALUE>'
            }
            Write-Verbose "$($name): $value"

            switch($name) {
                'Title' {
                    $ComObject.InvokeMember('value',$enumSetProperty,$Null,$property,("Configuration Sheet for $device_name"))
                }
                'Subject' {
                    $ComObject.InvokeMember('value',$enumSetProperty,$Null,$property,'ScreenOS Device')
                }
                'Comments' {
                    $ComObject.InvokeMember('value',$enumSetProperty,$Null,$property,"This document was automatically generated by $($MyInvocation.MyCommand). See $ProjectURL")
                }
            }
        }
        foreach($range in $doc.StoryRanges) {
            $range.Fields.Update() | Out-Null
        }

        Write-Section $STYLE_HEADING1 'Configuration' $SectionConfiguration
        Write-Section $STYLE_HEADING1 'Network' $SectionNetwork
        Write-Section $STYLE_HEADING1 'Security' $SectionSecurity
        Write-Section $STYLE_HEADING1 'Services' -keyword 'service' $SectionServices
        Write-Section $STYLE_HEADING1 'Addresses' -keyword 'address' $SectionAddresses
        Write-Section $STYLE_HEADING1 'Policy' -keyword 'policy' $SectionPolicy

        ########## Save
        $doc.SaveAs([ref]$WordFile)
    } finally {
        if(-not $Visible) {
            if($doc -ne $Null) {
                $doc.Close([ref]$wdDoNotSaveChanges)
            }
            if($msword -ne $Null) {
                $msword.Quit([ref]$wdDoNotSaveChanges)
            }
        }
    }
}

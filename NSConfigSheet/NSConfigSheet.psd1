#
# Module manifest for module 'NSConfigSheet'
#
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
#

@{
RootModule = 'NSConfigSheet.psm1'
ModuleVersion = '0.5'
GUID = '58a03706-27ca-4b80-a7ff-3e77949020ef'
Author = 'Jolly.Jive@gmail.com'
CompanyName = ''
Copyright = 'Copyright (C) 2011-2014 Jolly.Jive@gmail.com'
Description = 'NSConfigSheet is a Microsoft Windows PowerShell moudle to convert a Juniper ScreenOS configuration file into a configuration sheet in format of Microsoft Word document.'
PowerShellVersion = '4.0'
# PowerShellHostName = ''
# DotNetFrameworkVersion = ''
# CLRVersion = ''
# ProcessorArchitecture = ''
# RequiredModules = @()
RequiredAssemblies = @('Microsoft.Office.Interop.Word')
# ScriptsToProcess = @()
# TypesToProcess = @()
# FormatsToProcess = @()
# NestedModules = @()
FunctionsToExport = 'ConvertTo-NSConfigSheet'
#CmdletsToExport = ''
VariablesToExport = '$NSConfigSheetTemplate'
#AliasesToExport = '*'
# ModuleList = @()
# FileList = @()
# PrivateData = ''
# HelpInfoURI = ''
# DefaultCommandPrefix = ''
}


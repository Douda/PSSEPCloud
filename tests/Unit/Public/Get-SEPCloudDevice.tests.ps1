BeforeAll {
    $script:moduleName = 'PSSEPCloud'
    $ProjectPath = "$PSScriptRoot/../../.." | Convert-Path

    # Redirect all streams to $null, except the error stream (stream 2)
    & "$ProjectPath/build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null

    # Not Forcing module import
    # See reasons behind Pester v5 : https://github.com/pester/Pester/discussions/2109
    # Requires to build module prior running Pester
    Import-Module -Name $script:moduleName -ErrorAction 'Stop'
}

AfterAll {
    Remove-Module -Name $script:moduleName
}

Describe Get-SEPCloudDevice {
    BeforeAll {
        # Mock Private functions (requires -ModuleName for Pester v5)
        Mock Test-SEPCloudConnection -ModuleName $script:moduleName -MockWith { $true }

        # Setup mock for Submit-Request that will provide real data
        # Every devices will just have id host and name that are different from each other
        $deviceSample = [PSCustomObject]@{
            id                       = "-abcdefghijklmnop"
            name                     = "DESKTOP-123456"
            host                     = "DESKTOP-123456"
            domain                   = "domain.local"
            created                  = "08/02/2025 14:28:29"
            modified                 = "24/04/2025 23:52:01"
            os                       = @{tz_offset = 0; name = "Windows Server 2019 Datacenter Edition"; type = "WINDOWS_SERVER"; lang = "en"; user = "user01"; sp = "17763"; vol_cap_mb = "179197"; vol_avail_mb = "61393" }
            hw                       = @{bios_ver = "AMAZON - 1 Default System BIOS"; model_vendor = "Unknown"; serial = "abcdefgh-8c02-cb74-ad12-a7082fecdf4e"; cpu_type = "Intel64 Family 6 Model 143 Stepping 8"; phys_cpus = 4; uuid = "C0461730-8704-7489-5911-4D149AE655C0"; cpu_mhz = 2400; mem_mb = 16095 }
            adapters                 = @(@{ipv6_prefix = 64; ipv6Address = "FE80:0000:0000:0000:ABCD:ABCD:ABCD:ABCD"; ipv4_prefix = 18; ipv4Address = "10.0.0.36"; addr = "02:D1:73:2E:76:6F"; mask = "255.255.192.0" }, @{ipv6_prefix = 64; ipv6Address = "FE80:0000:0000:0000:8FBC:9997:770D:E3EC"; ipv4_prefix = 24; ipv4Address = "10.0.0.229"; addr = "02:B8:51:FA:48:07"; mask = "255.255.255.0" })
            is_virtual               = $false
            dns_names                = @("10.0.0.6", "10.0.0.1")
            parent_device_group_id   = "-abcdefghijklmnop"
            parent_device_group_name = "My Server Group"
            device_status            = "AT_RISK"
            device_status_reason     = @(613)
            connection_status        = "ONLINE"
        }

        $servers = 1..5 | ForEach-Object {
            $index = $_
            [PSCustomObject]@{
                id                       = if ($deviceSample.id) { $deviceSample.id -replace '.$', ([char]([int][char]$deviceSample.id[-1] + $index)).ToString() } else { $deviceSample.id }
                name                     = if ($deviceSample.name) { $deviceSample.name -replace '.$', ([char]([int][char]$deviceSample.name[-1] + $index)).ToString() } else { $deviceSample.name }
                host                     = if ($deviceSample.host) { $deviceSample.host -replace '.$', ([char]([int][char]$deviceSample.host[-1] + $index)).ToString() } else { $deviceSample.host }
                domain                   = $deviceSample.domain
                created                  = $deviceSample.created
                modified                 = $deviceSample.modified
                os                       = $deviceSample.os
                hw                       = $deviceSample.hw
                adapters                 = $deviceSample.adapters
                is_virtual               = $deviceSample.is_virtual
                dns_names                = $deviceSample.dns_names
                parent_device_group_id   = $deviceSample.parent_device_group_id
                parent_device_group_name = $deviceSample.parent_device_group_name
                device_status            = $deviceSample.device_status
                device_status_reason     = $deviceSample.device_status_reason
                connection_status        = $deviceSample.connection_status
            }
        }

        # Initialize a variable to capture the parameters
        $script:submitRequestParams = @()

        Mock Submit-Request -ModuleName $script:moduleName -MockWith {
            param ($uri, $header, $method, $body)
            # Capture the parameters
            $script:submitRequestParams += [PSCustomObject]@{
                Uri    = $uri
                Header = $header
                Method = $method
                Body   = $body
            }

            # Return mock data
            return [PSCustomObject]@{
                total   = 10
                devices = $servers
            }
        }
    }
    Context 'return values' {
        It 'returns a list of devices' {
            $return = Get-SEPCloudDevice
            ($return | Measure-Object).Count | Should -Be 10
        }

        It 'Should return correct PSType' {
            $return = Get-SEPCloudDevice
            $return | ForEach-Object { $_.PSobject.TypeNames } | Should -Contain 'SEPCloud.Device'
        }

    }

    Context 'test different parameters' {
        It "constructs the URI correctly with no parameters" {
            Get-SEPCloudDevice
            Assert-MockCalled -CommandName Submit-Request -ModuleName $script:moduleName -Times 1 -ParameterFilter { $uri -like '*/v1/devices?*' }
        }

        It "constructs the URI correctly with multiple parameters" {
            Get-SEPCloudDevice -client_version "14.2.1031.0100" -device_status "AT_RISK"
            Assert-MockCalled -CommandName Submit-Request -ModuleName $script:moduleName -Times 1 -ParameterFilter { $uri -like '*client_version*' -and $uri -like '*device_status*' }
        }
    }

    Context 'Internal logic' {
        BeforeAll {}

        It 'hit pagination' {
            Get-SEPCloudDevice
            Should -Invoke -CommandName Submit-Request -ModuleName $script:moduleName -Times 2
        }

        It 'correct pagination offsetting' {
            # Clear the captured parameters before the test
            $script:submitRequestParams = @()

            Get-SEPCloudDevice

            # Check that Submit-Request was called twice
            $script:submitRequestParams.Count | Should -Be 2

            # Check the offset in the second call
            # Should be 5 as the first call returned 5 devices
            $secondCallUri = $script:submitRequestParams[1].Uri
            $secondCallOffset = [regex]::Match($secondCallUri, 'offset=(\d+)').Groups[1].Value
            $secondCallOffset | Should -Be 5
        }
    }
}

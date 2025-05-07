function Get-SEPCloudAPIData {
    [CmdletBinding()]
    param (
        $endpoint
    )

    process {
        $api = @{
            'Example'                                  = @{
                '1.0' = @{
                    Description = 'Details about the API endpoint'
                    URI         = 'The URI expressed as /api/v#/endpoint'
                    Method      = 'Method to use against the endpoint'
                    Body        = 'Parameters to use in the body'
                    Query       = 'Parameters to use in the URI query'
                    Result      = 'If the result content is stored in a higher level key, express it here to be unwrapped in the return'
                    Success     = 'The expected HTTP status code for a successful call'
                    Function    = 'The PowerShell function to call to process the result'
                    ObjectTName = 'The name of the PSType object to return'
                }
            }
            'Block-SEPCloudFile'                       = @{
                '1.0' = @{
                    Description = 'Quarantine files on the device(s)'
                    URI         = '/v1/commands/files/contain'
                    Method      = 'Post'
                    Body        = @{
                        device_ids = 'device_ids'
                        hash       = 'hash'
                    }
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Block-SEPCloudFile'
                    ObjectTName = 'SEPCloud.block-file'
                }
            }
            'Connect-SEPCloud'                         = @{
                '1.0' = @{
                    Description = 'Generate new bearer token from the from the oAuth credential'
                    URI         = '/v1/oauth2/tokens'
                    Method      = 'Post'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Filter      = ''
                    Success     = '200'
                }
            }
            'Get-SEPCloudComponentType'                = @{
                '1.0' = @{
                    Description = 'lets you retrieve policy component host-groups, network-adapters(adapter), network-services(Connection), network IPS details'
                    URI         = '/v1/policies/components'
                    Method      = 'Get'
                    Body        = ''
                    Query       = @{
                        'offset' = 'offset'
                        'limit'  = 'limit'
                    }
                    Result      = 'data'
                    Success     = ''
                    Function    = 'Get-SEPCloudComponentType'
                    ObjectTName = 'SEPCloud.policyComponentType' # generic PSObject but there could be up to 4 different subtypes
                    # host-group-response
                    # network-services
                    # network-adapter
                    # network_ips_response
                }
            }
            'Get-SEPCloudCommand'                      = @{
                '1.0' = @{
                    Description = 'lets you retrieve a list of all commands'
                    URI         = '/v1/commands'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudCommand'
                    ObjectTName = 'SEPCloud.Command'
                }
            }

            'Get-SEPCloudDevice'                       = @{
                '1.0' = @{
                    Description = 'retrieve the list of devices'
                    URI         = '/v1/devices'
                    Method      = 'Get'
                    Body        = ''
                    Query       = @{
                        offset               = 'offset'
                        client_version       = 'client_version'
                        device_group         = 'device_group' # ID of the parent device group
                        device_status        = 'device_status'
                        device_status_reason = 'device_status_reason'
                        device_type          = 'device_type'
                        edr_enabled          = 'edr_enabled'
                        ipv4_address         = 'ipv4_address'
                        include_details      = 'include_details' # flag to include product and feature details in response. Possible values: true/false
                        is_cloud             = 'is_cloud'
                        is_online            = 'is_online'
                        is_virtual           = 'is_virtual'
                        mac_address          = 'mac_address'
                        name                 = 'name'
                        os                   = 'os' # Possible values: windows, Linux, iOS, Mac, Android
                        os_version           = 'os_version'
                    }
                    Result      = 'devices'
                    Success     = ''
                    Function    = 'Get-SEPCloudDevice'
                    ObjectTName = 'SEPCloud.Device'
                }
            }
            'Get-SEPCloudDeviceDetails'                = @{
                '1.0' = @{
                    Description = 'Details about the SEP client'
                    URI         = '/v1/devices'
                    Method      = 'Get'
                    Body        = ''
                    Query       = @{
                        device_id = 'device_id'
                    }
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudDeviceDetails'
                    ObjectTName = 'SEPCloud.device-details '
                }
            }
            'Get-SEPCloudEDRDumpsList'                 = @{
                '1.0' = @{
                    Description = 'get the list of endpoint search commands'
                    URI         = '/v1/commands/endpoint-search'
                    Method      = 'Post'
                    Body        = @{
                        query = 'query'
                        next  = 'next'
                        limit = 'limit'
                    }
                    Query       = ''
                    Result      = 'commands'
                    Success     = ''
                    Function    = 'Get-SEPCloudEDRDumpsList'
                    ObjectTName = 'SEPCloud.commandsResponse'
                }
            }
            'Get-SEPCloudEvents'                       = @{
                '1.0' = @{
                    Description = 'retrieve up to ten thousand events'
                    URI         = '/v1/event-search'
                    Method      = 'Post'
                    Body        = @{
                        feature_name = 'feature_name'
                        product      = 'product'
                        query        = 'query'
                        start_date   = 'start_date'
                        end_date     = 'end_date'
                        next         = 'next'
                        limit        = 'limit'
                    }
                    Query       = ''
                    Result      = 'events'
                    Success     = ''
                    Function    = 'Get-SEPCloudEvents'
                    ObjectTName = 'SEPCloud.Event'
                }
            }
            'Get-SepCloudFeatureList'                  = @{
                '1.0' = @{
                    Description = 'retrieve up to ten thousand events'
                    URI         = '/v1/devices/enums'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudFeatureList'
                    ObjectTName = 'SEPCloud.FeatureList'
                }
            }
            'Get-SEPCloudFileHashDetails'              = @{
                '1.0' = @{
                    Description = 'retrieve all details of a file based off its hash'
                    URI         = '/v1/threat-intel/protection/file/{id}'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudFileHashDetails'
                    ObjectTName = 'SEPCloud.files-hash'
                }
            }
            'Get-SEPCloudGroup'                        = @{
                '1.0' = @{
                    Description = 'retrieve a list of device groups'
                    URI         = '/v1/device-groups'
                    Method      = 'Get'
                    body        = ''
                    Query       = @{
                        offset = 'offset'
                    }
                    Result      = 'device_groups'
                    Success     = '200'
                    Function    = 'Get-SEPCloudGroupTest'
                    ObjectTName = 'SEPCloud.Device-Group' # root object is 'SEPCloud.Device-Group-List' but children objects only are exposed as 'SEPCloud.Device-Group'
                }
            }
            'Get-SEPCloudGroupPolicies'                = @{
                '1.0' = @{
                    Description = 'retrieve a list of policies that are targeted on a device group'
                    URI         = '/v1/device-groups/{id}/policies'
                    Method      = 'Get'
                    body        = ''
                    Query       = @{
                        group_id = 'group_id'
                    }
                    Result      = 'policies'
                    Success     = '200'
                    Function    = 'Get-SEPCloudGroupPolicies'
                    ObjectTName = 'SEPCloud.targeted-policy'
                }
            }
            'Get-SepCloudIncidents'                    = @{
                '1.0' = @{
                    Description = 'retrieve incidents and incident events'
                    URI         = '/v1/incidents'
                    Method      = 'Post'
                    body        = @{
                        start_date     = 'start_date'
                        end_date       = 'end_date'
                        next           = 'next'
                        limit          = 'limit'
                        include_events = 'include_events'
                        query          = 'query'
                    }
                    Query       = ''
                    Result      = 'incidents'
                    Success     = '200'
                    Function    = 'Get-SepCloudIncidents'
                    ObjectTName = 'SEPCloud.incident-response'
                }
            }
            'Get-SepCloudIncidentDetails'              = @{
                '1.0' = @{
                    Description = 'retrieve details for a specific incident'
                    URI         = '/v1/incidents'
                    Method      = 'Get'
                    body        = ''
                    Query       = @{
                        incident_id = 'incident_id'
                    }
                    Result      = 'incident'
                    Success     = '200'
                    Function    = 'Get-SepCloudIncidentDetails'
                    ObjectTName = 'SEPCloud.incident-details'
                }
            }
            'Get-SEPCloudPolicesSummary'               = @{
                '1.0' = @{
                    Description = 'retrieve a list of your policies (without details)'
                    URI         = '/v1/policies'
                    Method      = 'Get'
                    Body        = ''
                    Query       = @{
                        limit  = 'limit'
                        offset = 'offset'
                        name   = 'name'
                        type   = 'type'
                    }
                    Result      = 'policies'
                    Success     = ''
                    Function    = 'Get-SEPCloudPolicesSummary'
                    ObjectTName = 'SEPCloud.policy'
                }
            }
            'Get-SEPCloudPolicyDetails'                = @{
                '1.0' = @{
                    Description = 'lets you retrieve the details for a policy by using its uid and version.'
                    URI         = '/v1/policies/{id}/versions/{id}'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudPolicyDetails'
                    ObjectTName = 'SEPCloud.policy-by-uid'
                }
            }
            'Get-SepCloudTargetRules'                  = @{
                '1.0' = @{
                    Description = 'retrieve a list of target rules'
                    URI         = '/v1/policies/target-rules'
                    Method      = 'Get'
                    Body        = ''
                    Query       = @{
                        limit  = 'limit'
                        offset = 'offset'
                    }
                    Result      = 'target_rules'
                    Success     = ''
                    Function    = 'Get-SepCloudTargetRules'
                    ObjectTName = 'SEPCloud.target-rule'
                }
            }
            'Get-SEPCloudThreatIntelCveProtection'     = @{
                '1.0' = @{
                    Description = 'returns information whether a given CVE has been blocked by any Symantec technologies'
                    URI         = '/v1/threat-intel/protection/cve'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudThreatIntelCveProtection'
                    ObjectTName = 'SEPCloud.cve-protection'
                }
            }
            'Get-SEPCloudThreatIntelFileInsight'       = @{
                '1.0' = @{
                    Description = 'returns file insight enrichments for given file sha256'
                    URI         = '/v1/threat-intel/insight/file'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudThreatIntelFileInsight'
                    ObjectTName = 'SEPCloud.file-insight'
                }
            }
            'Get-SEPCloudThreatIntelNetworkInsight'    = @{
                '1.0' = @{
                    Description = 'returns network enrichments for given URL, domain or IP'
                    URI         = '/v1/threat-intel/insight/network'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudThreatIntelNetworkInsight'
                    ObjectTName = 'SEPCloud.network-insight'
                }
            }
            'Get-SEPCloudThreatIntelFileProtection'    = @{
                '1.0' = @{
                    Description = 'returns information whether a given file has been blocked by any Symantec technologies'
                    URI         = '/v1/threat-intel/protection/file/{id}'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudThreatIntelFileProtection'
                    ObjectTName = 'SEPCloud.file-protection'
                }
            }
            'Get-SEPCloudThreatIntelFileRelated'       = @{
                '1.0' = @{
                    Description = 'returns information whether a given file has been blocked by any Symantec technologies'
                    URI         = '/v1/threat-intel/related/file/'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudThreatIntelFileRelated'
                    ObjectTName = 'SEPCloud.file-related'
                }
            }
            'Get-SEPCloudThreatIntelNetworkProtection' = @{
                '1.0' = @{
                    Description = 'returns information whether a given file has been blocked by any Symantec technologies'
                    URI         = '/v1/threat-intel/protection/network'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudThreatIntelNetworkProtection'
                    ObjectTName = 'SEPCloud.network-protection'
                }
            }
            'Get-SEPCloudThreatIntelFileProcessChain'  = @{
                '1.0' = @{
                    Description = 'returns topK process lineage enrichment for the provided file sha256'
                    URI         = '/v1/threat-intel/processchain/file'
                    Method      = 'Get'
                    Body        = ''
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Get-SEPCloudThreatIntelFileProcessChain'
                    ObjectTName = 'SEPCloud.file-processchain'
                }
            }
            'Move-SEPCloudDevice'                      = @{
                '1.0' = @{
                    Description = 'lets you transfer multiple devices from one device group to another device group'
                    URI         = '/v1/device-groups/{id}/devices'
                    Method      = 'Put'
                    Body        = @{
                        device_uids = 'device_uids'
                    }
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Move-SEPCloudDevice'
                    ObjectTName = 'SEPCloud.Bulk-Device-List'
                }
            }
            'New-SEPCloudEDRFullDump'                  = @{
                '1.0' = @{
                    Description = 'Send the full dump command on the device'
                    URI         = '/v1/commands/endpoint-search/fulldump'
                    Method      = 'Post'
                    Body        = @{
                        device_id   = 'device_id'
                        description = 'description'
                        from_date   = 'from_date'
                        to_date     = 'to_date'
                    }
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'New-SEPCloudEDRFullDump'
                    ObjectTName = 'SEPCloud.DumpCommandResponse'
                }
            }
            'Remove-SEPCloudPolicy'                    = @{
                '1.0' = @{
                    Description = 'Removes a SEP Cloud policy from a device group'
                    URI         = '/v1/policies/{id}/versions/{id}/device-groups'
                    Method      = 'Delete'
                    Body        = @{
                        target_rules     = 'target_rules'
                        device_group_ids = 'device_group_ids'
                    }
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Remove-SEPCloudPolicy'
                    ObjectTName = 'SEPCloud.remove-policy'
                }
            }
            'Set-SEPCloudPolicy'                       = @{
                '1.0' = @{
                    Description = 'apply a policy to device groups'
                    URI         = '/v1/policies/{id}/versions/{id}/device-groups'
                    Method      = 'Post'
                    Body        = @{
                        target_rules     = 'target_rules'
                        device_group_ids = 'device_group_ids'
                        override         = 'override'
                    }
                    Query       = ''
                    Result      = ''
                    Success     = '204'
                    Function    = 'Set-SEPCloudPolicy'
                    ObjectTName = 'SEPCloud.apply-policy'
                }
            }
            'Start-SEPCloudDefinitionUpdate'           = @{
                '1.0' = @{
                    Description = 'Update security definitions of devices'
                    URI         = '/v1/commands/update_content'
                    Method      = 'Post'
                    Body        = @{
                        device_ids   = 'device_ids'
                        org_unit_ids = 'org_unit_ids'
                        is_recursive = 'is_recursive'
                    }
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Start-SEPCloudDefinitionUpdate'
                    ObjectTName = 'SEPCloud.DeviceCommandResponse'
                }
            }
            'Start-SEPCloudFullScan'                   = @{
                '1.0' = @{
                    Description = 'initiate a full scan on devices managed'
                    URI         = '/v1/commands/scans/full'
                    Method      = 'Post'
                    Body        = @{
                        device_ids   = 'device_ids'
                        org_unit_ids = 'org_unit_ids'
                        is_recursive = 'is_recursive'
                    }
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Start-SEPCloudFullScan'
                    ObjectTName = 'SEPCloud.DeviceCommandResponse'
                }
            }
            'Start-SepCloudQuickScan'                  = @{
                '1.0' = @{
                    Description = 'initiate a quick scan on devices managed'
                    URI         = '/v1/commands/scans/quick'
                    Method      = 'Post'
                    Body        = @{
                        device_ids   = 'device_ids'
                        org_unit_ids = 'org_unit_ids'
                        is_recursive = 'is_recursive'
                    }
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Start-SepCloudQuickScan'
                    ObjectTName = 'SEPCloud.DeviceCommandResponse'
                }
            }
            'Update-AllowListPolicyByFileName'         = @{
                '1.0' = @{
                    Description = 'perform partial update of Allow list policy by filename'
                    URI         = '/v1/policies/allow-list/{id}/versions/{id}'
                    Method      = 'Patch'
                    Body        = @{
                        add = @{
                            windows = @{
                                files = @(
                                    @{
                                        pathvariable = 'pathvariable'
                                        path         = 'path'
                                        scheduled    = 'scheduled'
                                        features     = 'features'
                                    }
                                )
                            }
                        }
                    }
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Update-AllowListPolicyByFileName'
                    ObjectTName = 'SEPCloud.update-policy-response'
                }
            }
        }

        # Use the latest version of the API endpoint
        $version = $api.$endpoint.Keys | Sort-Object | Select-Object -Last 1

        if ($null -eq $version) {
            $ErrorSplat = @{
                Message      = "No matching endpoint found for $Endpoint that corresponds to the current cluster version."
                ErrorAction  = 'Stop'
                TargetObject = $api.$endpoint.keys -join ','
                Category     = 'ObjectNotFound'
            }
            Write-Error @ErrorSplat
        } else {
            Write-Verbose -Message "Selected $version API Data for $endpoint"
            return $api.$endpoint.$version
        }
    }
}

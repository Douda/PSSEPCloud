function New-NestedBodyString {
    <#
    .SYNOPSIS
    Builds a nested body structure from a given hashtable and parameter values.

    .DESCRIPTION
    This function takes a hashtable representing the structure of the body and another hashtable containing parameter values.
    It recursively builds the nested structure by replacing placeholders in the structure with corresponding parameter values.

    .PARAMETER bodyStructure
    A hashtable representing the structure of the body. The keys are the names of the fields, and the values can be either
    strings (placeholders for parameter values), hashtables (nested structures), or arrays.

    .PARAMETER parameterValues
    A hashtable containing the parameter values. The keys are the parameter names, and the values are the corresponding values.

    .EXAMPLE
    $bodyStructure = @{
        "name" = "param1"
        "details" = @{
            "age" = "param2"
            "address" = @{
                "street" = "param3"
                "city" = "param4"
            }
        }
    }
    $parameterValues = @{
        "param1" = "John Doe"
        "param2" = 30
        "param3" = "123 Main St"
        "param4" = "Anytown"
    }
    New-NestedBodyString -bodyStructure $bodyStructure -parameterValues $parameterValues

    .OUTPUTS
    A hashtable representing the nested body structure with placeholders replaced by parameter values.

    .NOTES
    This function uses recursion to handle nested structures and arrays.
    #>

    [cmdletBinding(SupportsShouldProcess = $true)]
    param (
        [hashtable]$bodyStructure,
        [hashtable]$parameterValues
    )

    function BuildBody {
        param (
            [hashtable]$structure,
            [hashtable]$params
        )

        $result = @{}

        foreach ($key in $structure.Keys) {
            $value = $structure[$key]

            if ($value -is [hashtable]) {
                # Recursively build the nested structure
                $result[$key] = BuildBody -structure $value -params $params
            }
            elseif ($value -is [array]) {
                # Handle arrays
                $result[$key] = @()
                foreach ($item in $value) {
                    if ($item -is [hashtable]) {
                        $result[$key] += BuildBody -structure $item -params $params
                    }
                    else {
                        $result[$key] += $item
                    }
                }
            }
            else {
                # Handle individual parameters
                if ($params.ContainsKey($value)) {
                    $result[$key] = $params[$value]
                }
            }
        }

        return $result
    }

    $result = BuildBody -structure $bodyStructure -params $parameterValues
    Write-Verbose -Message "Body is $(ConvertTo-Json -Depth 100 -InputObject $result)"
    return $result
}

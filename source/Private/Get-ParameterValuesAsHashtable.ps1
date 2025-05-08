function Get-ParameterValuesAsHashtable {
    <#
    .SYNOPSIS
    Extracts parameter values from a specified function as a hashtable.

    .DESCRIPTION
    This function dynamically extracts the values of parameters from a specified function and returns them as a hashtable. It is useful for functions that need to dynamically build bodies or other structures based on parameter values.

    .PARAMETER functionName
    The name of the function from which to extract parameter values.

    .EXAMPLE
    function Test-Function {
        param (
            [string]$param1,
            [int]$param2,
            [bool]$param3
        )
        # This function is just for testing purposes
    }

    $param1 = 'value1'
    $param2 = 42
    $param3 = $true

    $result = Get-ParameterValuesAsHashtable -functionName 'Test-Function'
    $result

    This will return a hashtable with the parameter values:
    @{
        param1 = 'value1'
        param2 = 42
        param3 = $true
    }

    .NOTES
    This function uses the Get-Variable cmdlet to retrieve the values of the parameters. It handles parameters that are not set by returning $null for those parameters.
    #>

    param (
        [string]$functionName
    )

    $paramsHash = @{}
    foreach ($param in (Get-Command $functionName).Parameters.Values) {
        $paramsHash[$param.Name] = (Get-Variable -Name $param.Name -ErrorAction 'SilentlyContinue').Value
    }

    return $paramsHash
}

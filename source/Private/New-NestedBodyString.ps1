function New-NestedBodyString {
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

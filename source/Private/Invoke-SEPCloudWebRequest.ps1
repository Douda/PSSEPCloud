function Invoke-SEPCloudWebRequest
{
    <#
    .SYNOPSIS
        Gather WebRequest from a URL or redirect URL.
    .DESCRIPTION
        Gather WebRequest from a URL or redirect URL. Preserves the Authorization header upon redirect.
        This function is a wrapper around the System.Net.WebRequest class.
    .PARAMETER Uri
        URL to gather WebRequest from.
    .PARAMETER Method
        HTTP method to use.
    .PARAMETER Headers
        Headers to include in the request.
        Must be a hashtable as per example below.
    .OUTPUTS
        JSON object
    .EXAMPLE
        $params = @{
            Method  = 'GET'
            Uri     = "https://example.com/v1/endpoint"
            Headers = @{
                Host          = "https://example.com/v1/endpoint"
                Accept        = "application/json"
                Authorization = "Bearer xxxxxxxx"
            }
            queryParameters = @{
                "ComputerName" = "MyComputer01"
            }
        }
        Invoke-SEPCloudWebRequest @params

        This example will :
        - Send a GET request to https://example.com/v1/endpoint
        - With the Authorization header set to "Bearer xxxxxxxx"
        - With the query parameter ComputerName set to "MyComputer01" (https://example.com/v1/endpoint?ComputerName=MyComputer01)
    .EXAMPLE
        $params = @{
            Method  = 'POST'
            Uri     = "https://example.com/v1/endpoint"
            Headers = @{
                Host          = "https://example.com/v1/endpoint"
                Accept        = "application/json"
                Authorization = "Bearer xxxxxxxx"
            }
            body = @{
                "ComputerName" = "MyComputer01"
            }
        }
        Invoke-SEPCloudWebRequest @params

        This example will :
        - Send a POST request to https://example.com/v1/endpoint
        - With the Authorization header set to "Bearer xxxxxxxx"
        - With the body set to JSON format {"ComputerName":"MyComputer01"}
    #>


    [CmdletBinding()]
    param (
        # URL
        [Parameter(Mandatory = $true)]
        [string]$uri,

        # Method
        [Parameter(Mandatory = $true)]
        [string]$method,

        # List of headers
        [Parameter(Mandatory = $true)]
        [hashtable]$headers,

        # Query parameters
        [hashtable]$queryStrings = @{},

        # Body
        [hashtable]$body = @{}
    )

    process
    {
        # Add query parameters
        if ($queryStrings.Count -gt 0)
        {
            # Construct the URI
            $uri = New-QueryURI -BaseURI $uri -QueryStrings $queryStrings
        }

        # Initial request
        $initialRequest = [System.Net.WebRequest]::CreateHttp($uri);
        $initialRequest.Method = $method
        $initialRequest.AllowAutoRedirect = $false

        # Add body
        if ($body.Count -gt 0) {
            $initialRequest.ContentType = "application/json"
            $json = $body | ConvertTo-Json -Depth 100
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
            $initialRequest.ContentLength = $bytes.Length
            $initialRequestStream = $initialRequest.GetRequestStream()
            $initialRequestStream.Write($bytes, 0, $bytes.Length)
            $initialRequestStream.Close()
        }

        # Add headers
        foreach ($header in $Headers.GetEnumerator()) {
            $initialRequest.Headers.Add($header.Key, $header.Value)
        }

        # Send the initial request
        try {
            $inititalResponse = $initialRequest.GetResponse();
            Write-Verbose -Message "URI = $($inititalResponse.GetResponseHeader("Location"))"
            Write-Verbose -Message "Status code : $($inititalResponse.StatusCode)"
        }
        catch {
            throw $_
        }

        # IF HTTP status code is linked to redirected URL
        if ($inititalResponse.StatusCode.value__ -in (301, 302, 303, 307, 308)) {
            Write-Verbose -Message "URI to redirect : $($inititalResponse.GetResponseHeader("Location"))"
            # Create new request with the redirect URL
            $redirectUrl = $inititalResponse.GetResponseHeader("Location")
            $newRequest = [System.Net.WebRequest]::CreateHttp($redirectUrl);
            $newRequest.Method = $Method
            $newRequest.AllowAutoRedirect = $false

            # Add query parameters
            if ($queryStrings.Count -gt 0) {
                # Construct the URI
                $uri = New-QueryURI -BaseURI $uri -QueryStrings $queryStrings
            }

            # Add body
            if ($body.Count -gt 0)
            {
                $newRequest.ContentType = "application/json"
                $json = $body | ConvertTo-Json -Depth 100
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
                $newRequest.ContentLength = $bytes.Length
                $newRequestStream = $newRequest.GetRequestStream()
                $newRequestStream.Write($bytes, 0, $bytes.Length)
                $newRequestStream.Close()
            }

            # Add headers
            # TODO verify why when adding all the headers and not just the Authorization header, the request fails wih 400
            # Reuse all headers from the initial request (including Authorization header)
            foreach ($header in $Headers.GetEnumerator())
            {
                $newRequest.Headers.Add($header.Key, $header.Value)
            }
            # $newRequest.Headers.Add("Authorization", $Headers.Authorization)
            # $newRequest.Headers.Add("Accept", $Headers.Accept)
            # $newRequest.Headers.Add("Host", $Headers.Host)

            # Send the new request
            try
            {
                $newResponse = $newRequest.GetResponse()
                Write-Verbose -Message "Status Code : $($newResponse.StatusCode.value__)"
            }
            catch
            {
                Write-Error "Error in Invoke-SEPCloudWebRequest: $($_.Exception.InnerException.Message)"
            }

            # Parse the response
            $stream = $newResponse.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $content = $reader.ReadToEnd()
        }
        else
        {
            # Get the response from the initial request
            $stream = $inititalResponse.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $content = $reader.ReadToEnd()
        }

        return $content | ConvertFrom-Json -Depth 100
    }
}

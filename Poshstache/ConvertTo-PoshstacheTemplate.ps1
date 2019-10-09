function ConvertTo-PoshstacheTemplate{
    <#
	.SYNOPSIS
		Mustache implementation. Mustache is logic-less templates.
	.DESCRIPTION
        Convert a template plus an input object into an output file.
    .PARAMETER InputString
        A string containing the template
    .PARAMETER InputFile
        The path of the file containing the template
    .PARAMETER ParametersObject
        A JSON String containing mustache parameters
    .EXAMPLE
        ConvertTo-PoshstacheTemplate -InputString "Hi {{name}}!" -ParameterObject @{name:'bob'}
    .EXAMPLE
        ConvertTo-PoshstacheTemplate -InputFile .\myInputFile.txt -ParameterObject @{name:'bob'}
	#>
    param(
        [Parameter(ParameterSetName='String',Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $InputString,
        [Parameter(ParameterSetName='File',Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $InputFile,
        [Parameter(ParameterSetName='File',Mandatory=$true)]
        [Parameter(ParameterSetName='String',Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String] $ParametersObject
    )

    if($PSCmdlet.ParameterSetName -eq "File"){
        if (-not (Test-Path $InputFile)) {
            Throw "Input file doesn't exist"
        }
        $InputString = Get-Content $InputFile -Raw
    }

    #Check if input object is valid
    try {
        $JSonInput = ConvertFrom-Json $ParametersObject | ConvertFrom-PSObjectToHashtable
    }
    catch{
        Throw $_
    }

    if($PSversiontable.psversion.Major -lt 6){
        #Load Nustache dll
        $path = Get-ModulePath "Poshstache"
        [Reflection.Assembly]::LoadFile("$Path\binary\Nustache.Core.dll") | Out-Null
        try{
            return [Nustache.Core.Render]::StringToString($InputString, $JsonInput)
        } catch [Exception] {
            $_.Exception.Message
        }
    }
    else{
        # Load Stubble dll
        $path = Get-ModulePath "Poshstache"
        [Reflection.Assembly]::LoadFile("$Path\binary\Stubble.Core.dll") | Out-Null

        try{
            $builder = [Stubble.Core.Builders.StubbleBuilder]::new().Build()
            return $builder.render($InputString, $JsonInput)
        } catch [Exception] {
            $_.Exception.Message
        }
    }
}
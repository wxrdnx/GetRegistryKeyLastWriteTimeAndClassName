function Get-ChildItem {

    # Pulled HelpUri='http://go.microsoft.com/fwlink/?LinkID=113308' from CmdletBinding so that function
    # works with PSv2
    [CmdletBinding(DefaultParameterSetName='Items', SupportsTransactions=$true)]
    param(
        [Parameter(ParameterSetName='Items', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName='LiteralItems', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string[]]
        ${LiteralPath},

        [Parameter(Position=1)]
        [string]
        ${Filter},

        [string[]]
        ${Include},

        [string[]]
        ${Exclude},

        [Alias('s')]
        [switch]
        ${Recurse},

        [switch]
        ${Force},

        [switch]
        ${Name})


    dynamicparam {

        # We need to find the path to use (if no path is specified, use the current path
        # in the current provider:
        if ($PSBoundParameters.Path) { $GciPath = $PSBoundParameters.Path }
        elseif ($PSBoundParameters.LiteralPath) { $GciPath = $PSBoundParameters.LiteralPath }
        else { $GciPath = "." }

        # Create the dictionary that this scriptblock will return:
        $DynParamDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Get dynamic params that real Cmdlet would have:
        $Parameters = Get-Command -CommandType Cmdlet -Name Get-ChildItem -ArgumentList $GciPath |
            Select-Object -ExpandProperty Parameters

        foreach ($Parameter in ($Parameters.GetEnumerator() | Where-Object { $_.Value.IsDynamic })) {
            $DynamicParameter = New-Object System.Management.Automation.RuntimeDefinedParameter (
                $Parameter.Key,
                $Parameter.Value.ParameterType,
                $Parameter.Value.Attributes
            )
            $DynParamDictionary.Add($Parameter.Key, $DynamicParameter)
        }

        # Return the dynamic parameters
        $DynParamDictionary
    }

    begin
    {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet)

            # We need to find the path to use (if no path is specified, use the current path
            # in the current provider:
            if ($PSBoundParameters.Path) { $GciPath = $PSBoundParameters.Path }
            elseif ($PSBoundParameters.LiteralPath) { $GciPath = $PSBoundParameters.LiteralPath }
            else { $GciPath = "." }

            if ((Resolve-Path $GciPath).Provider.Name -eq "Registry") {
                # Registry provider, so call function to get extra key info:
                $scriptCmd = {& $wrappedCmd @PSBoundParameters | Add-RegKeyMember }
            }
            else {
                # Don't do anything special; just call gci cmdlet:
                $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
    <#

    .ForwardHelpTargetName Get-ChildItem
    .ForwardHelpCategory Cmdlet

    #>
}

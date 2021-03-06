function new-autoVariable
{
    param($name, [ScriptBlock] $getter, [ScriptBlock] $setter)

    Add-Type @”
using System;
using System.Collections.ObjectModel;
using System.Management.Automation;

namespace CodeOwls.PowerShell
{
    public class PSScriptVariable : PSVariable
    {
        public PSScriptVariable(string name,
            ScriptBlock scriptGetter, ScriptBlock scriptSetter)
            : base(name, null, ScopedItemOptions.AllScope)
        {
            getter = scriptGetter;
            setter = scriptSetter;
        }
        private ScriptBlock getter;
        private ScriptBlock setter;

        public override object Value
        {
            get
            {
                if(getter != null)
                {
                    Collection<PSObject> results = getter.Invoke();
                    if(results.Count == 1)
                    {
                        return results[0];
                    }
                    else
                    {
                        PSObject[] returnResults = new PSObject[results.Count];
                        results.CopyTo(returnResults, 0);
                        return returnResults;
                    }
                }
                else { return null; }
            }
            set
            {
                if(setter != null) { setter.Invoke(value); }
            }
        }
    }
}
“@

    if( $name -notmatch '.+:' )
    {
        $name = 'global:' + $name;
    }

    if(Test-Path variable:\$name)
    {
        Remove-Item variable:\$name -Force
    }
    $executioncontext.SessionState.PSVariable.Set(
        (New-Object CodeOwls.PowerShell.PSScriptVariable $name,$getter,$setter))
<# 
   .SYNOPSIS 
    Creates a new automatic variable.
   .DESCRIPTION
    Creates a new automatic (or tied) variable.  The variable value will be calculated when the variable is referenced using the supplied getter scriptblock.
    
    Unless a specific scope is specified, the variable is defined in the global scope.
   .EXAMPLE 
   PS C:\ > new-autovariable -name now -getter { [datetime]::now }
   PS C:\ > $now
   
    Tuesday, March 26, 2013 9:27:38 PM

   
   Creates a new automatic variable named 'now' that returns the current date and time instant.
   .NOTES
    NAME: 
    AUTHOR: beefarino
    LASTEDIT: 03/26/2013 21:25:22 
    KEYWORDS: 
   .Link 
    http://www.codeowls.com 
#> 
}
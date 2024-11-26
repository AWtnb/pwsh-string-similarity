function Use-TempDir {
    <#
    .NOTES
    > Use-TempDir {$pwd.Path}
    Microsoft.PowerShell.Core\FileSystem::C:\Users\~~~~~~ # includes PSProvider
    > Use-TempDir {$pwd.ProviderPath}
    C:\Users\~~~~~~ # literal path without PSProvider
    #>
    param (
        [ScriptBlock]$script
    )
    $tmp = $env:TEMP | Join-Path -ChildPath $([System.Guid]::NewGuid().Guid)
    New-Item -ItemType Directory -Path $tmp | Push-Location
    "working on tempdir: {0}" -f $tmp | Write-Host -ForegroundColor DarkBlue
    $result = $null
    try {
        $result = Invoke-Command -ScriptBlock $script
    }
    catch {
        $_.Exception.ErrorRecord | Write-Error
        $_.ScriptStackTrace | Write-Host
    }
    finally {
        Pop-Location
        $tmp | Remove-Item -Recurse
    }
    return $result
}

function Get-LinesSimilarityWithPython {
    $lines = New-Object System.Collections.ArrayList
    $input | Where-Object {$_.trim().length} | ForEach-Object {$lines.Add($_) > $null}

    $pyCodePath = $PSScriptRoot | Join-Path -ChildPath "python\get_similarity.py"
    Use-TempDir {
        $in = New-Item -Path ".\in.txt"
        $out = New-Item -Path ".\out.txt"
        $lines | Out-File -Encoding utf8NoBOM -FilePath $in.FullName
        Start-Process -Path python.exe -wait -ArgumentList @("-B", $pyCodePath, $in.FullName, $out.FullName) -NoNewWindow
        return Get-Content -Path $out.FullName | ConvertFrom-Json
    }
}
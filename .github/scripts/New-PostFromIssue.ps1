#Requires -Version 7.0
<#
.SYNOPSIS
    Entry point for the "post from issue" workflow.

.DESCRIPTION
    Reads the issue from environment variables (never from ${{ }} interpolation,
    so untrusted issue text can't inject shell commands), writes the post to
    content/posts, and reports the result through $GITHUB_OUTPUT.

    Env: ISSUE_BODY, ISSUE_NUMBER, ISSUE_AUTHOR
#>
[CmdletBinding()]
param(
    [string]$PostsDir = (Join-Path $PSScriptRoot '..' '..' 'content' 'posts')
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'IssuePost.psm1') -Force

$number = [int]$env:ISSUE_NUMBER
$fields = ConvertFrom-IssueForm -Body ($env:ISSUE_BODY ?? '')
$post   = New-PostMarkdown -Fields $fields -IssueNumber $number -IssueAuthor ($env:ISSUE_AUTHOR ?? '')

$path = Join-Path $PostsDir $post.FileName
Set-Content -Path $path -Value $post.Content -Encoding utf8NoBOM -NoNewline
Write-Host "Wrote $path"

if ($env:GITHUB_OUTPUT) {
    "path=content/posts/$($post.FileName)" | Add-Content $env:GITHUB_OUTPUT
    # Title goes through a heredoc delimiter so quotes or newlines can't break the output file.
    $delim = "EOF_$([guid]::NewGuid().ToString('N'))"
    "title<<$delim`n$($post.Title)`n$delim" | Add-Content $env:GITHUB_OUTPUT
}

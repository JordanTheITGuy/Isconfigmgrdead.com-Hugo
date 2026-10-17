#Requires -Version 7.0
<#
.SYNOPSIS
    Turns a "Submit a post" GitHub issue form into a Hugo post.

.DESCRIPTION
    GitHub renders issue forms as markdown: each field becomes a "### <Label>"
    heading followed by its value, and empty optional fields read "_No response_".
    These functions parse that body and build the markdown file for content/posts.
#>

Set-StrictMode -Version Latest

# Form label -> key. Must match the labels in .github/ISSUE_TEMPLATE/new-post.yml.
$script:FieldMap = [ordered]@{
    'Post type'                 = 'PostType'
    'Suggested title'           = 'Title'
    'Date it happened'          = 'Date'
    'Source link'               = 'Source'
    'Who said it (for quotes)'  = 'Speaker'
    'What happened'             = 'Summary'
    'Key quote (optional)'      = 'Quote'
    'Tags (optional)'           = 'Tags'
    'Before you submit'         = 'Checks'
    'Credit (optional)'         = 'Credit'
}

# Dropdown value -> tag added automatically.
$script:TypeTags = @{
    'New release or hotfix'        = 'release'
    'Known issue or workaround'    = 'known-issue'
    'Microsoft statement or quote' = 'microsoft'
    'Community story or win'       = 'community'
}

function ConvertFrom-IssueForm {
    <#
    .SYNOPSIS
        Parses an issue-form body into a hashtable keyed by field name.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Body
    )

    $result = @{}
    foreach ($key in $script:FieldMap.Values) { $result[$key] = '' }

    $normalized = $Body -replace "`r`n", "`n"
    # Split on "### " headings at the start of a line; first chunk is preamble.
    $sections = [regex]::Split($normalized, '(?m)^###[ \t]+')
    foreach ($section in $sections | Select-Object -Skip 1) {
        $newline = $section.IndexOf("`n")
        if ($newline -lt 0) { $label = $section.Trim(); $value = '' }
        else {
            $label = $section.Substring(0, $newline).Trim()
            $value = $section.Substring($newline + 1).Trim()
        }
        if ($value -eq '_No response_') { $value = '' }
        if ($script:FieldMap.Contains($label)) {
            $result[$script:FieldMap[$label]] = $value
        }
    }
    return $result
}

function New-PostSlug {
    <#
    .SYNOPSIS
        Lower-case, hyphenated, filesystem-safe slug (max 60 chars).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)

    $slug = $Text.ToLowerInvariant() -replace '[^a-z0-9]+', '-'
    $slug = $slug.Trim('-')
    if ($slug.Length -gt 60) { $slug = $slug.Substring(0, 60).TrimEnd('-') }
    if (-not $slug) { $slug = 'post' }
    return $slug
}

function ConvertTo-YamlSingleQuoted {
    param([AllowEmptyString()][string]$Value)
    # YAML single-quoted scalar: only ' needs escaping (as ''). Newlines collapsed.
    "'" + (($Value -replace '\s*\r?\n\s*', ' ') -replace "'", "''") + "'"
}

function Get-PostDate {
    <#
    .SYNOPSIS
        Parses YYYY-MM-DD from the form; falls back to $Fallback when invalid.
    #>
    param([AllowEmptyString()][string]$Value, [datetime]$Fallback = (Get-Date))

    $parsed = [datetime]::MinValue
    $ok = [datetime]::TryParseExact($Value.Trim(), 'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture,
        [Globalization.DateTimeStyles]::None, [ref]$parsed)
    if ($ok) { return $parsed.Date } else { return $Fallback.Date }
}

function Test-HttpUrl {
    param([AllowEmptyString()][string]$Value)
    $uri = $null
    [Uri]::TryCreate($Value.Trim(), [UriKind]::Absolute, [ref]$uri) -and
        $uri.Scheme -in @('http', 'https')
}

function New-PostMarkdown {
    <#
    .SYNOPSIS
        Builds the Hugo post (front matter + body) from parsed form fields.
    .OUTPUTS
        PSCustomObject with FileName, Title, Date and Content.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Fields,
        [Parameter(Mandatory)][int]$IssueNumber,
        [string]$IssueAuthor = '',
        [datetime]$Today = (Get-Date)
    )

    $title = $Fields.Title.Trim()
    if (-not $title) { throw "Issue #$IssueNumber has no title." }

    $source = $Fields.Source.Trim()
    if (-not (Test-HttpUrl $source)) { throw "Issue #${IssueNumber}: source link '$source' is not an http(s) URL." }

    $summary = $Fields.Summary.Trim()
    if (-not $summary) { throw "Issue #$IssueNumber has no summary." }

    $date = Get-PostDate -Value $Fields.Date -Fallback $Today

    # Tags: type-derived first, then user tags; lower-case, de-duplicated.
    $tags = [System.Collections.Generic.List[string]]::new()
    if ($script:TypeTags.ContainsKey($Fields.PostType)) { $tags.Add($script:TypeTags[$Fields.PostType]) }
    foreach ($t in ($Fields.Tags -split '[,;]')) {
        $clean = (New-PostSlug $t.Trim())
        if ($t.Trim() -and $clean -ne 'post' -and -not $tags.Contains($clean)) { $tags.Add($clean) }
    }

    $fm = [System.Text.StringBuilder]::new()
    [void]$fm.AppendLine('---')
    [void]$fm.AppendLine("title: $(ConvertTo-YamlSingleQuoted $title)")
    [void]$fm.AppendLine("date: $($date.ToString('yyyy-MM-dd'))T09:00:00-04:00")
    [void]$fm.AppendLine('draft: false')
    if ($tags.Count) {
        [void]$fm.AppendLine("tags: [$(($tags | ForEach-Object { ConvertTo-YamlSingleQuoted $_ }) -join ', ')]")
    }
    [void]$fm.AppendLine('---')

    $body = [System.Text.StringBuilder]::new()
    [void]$body.AppendLine()
    [void]$body.AppendLine($summary)

    $quote = $Fields.Quote.Trim()
    if ($quote) {
        [void]$body.AppendLine()
        foreach ($line in ($quote -split "`n")) { [void]$body.AppendLine("> $($line.TrimEnd())") }
        $speaker = $Fields.Speaker.Trim()
        if ($speaker) { [void]$body.AppendLine('>'); [void]$body.AppendLine("> -- $speaker") }
    }

    [void]$body.AppendLine()
    [void]$body.AppendLine("Source: [$source]($source)")

    $credit = $Fields.Credit.Trim()
    if (-not $credit -and $IssueAuthor) { $credit = "@$IssueAuthor" }
    if ($credit) {
        [void]$body.AppendLine()
        [void]$body.AppendLine("*Submitted by $credit.*")
    }

    [pscustomobject]@{
        FileName = "$($date.ToString('yyyy-MM-dd'))-$(New-PostSlug $title).md"
        Title    = $title
        Date     = $date
        Content  = $fm.ToString() + $body.ToString()
    }
}

Export-ModuleMember -Function ConvertFrom-IssueForm, New-PostSlug, New-PostMarkdown, Get-PostDate, Test-HttpUrl

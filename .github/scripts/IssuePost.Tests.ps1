#Requires -Version 7.0
# Pester 5 tests for IssuePost.psm1. Run: Invoke-Pester ./.github/scripts

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot 'IssuePost.psm1') -Force

    # Mirrors how GitHub renders the new-post.yml issue form.
    $script:FullBody = @'
### Post type

Known issue or workaround

### Suggested title

ODBC 18.7.1.1 breaks "site" SQL

### Date it happened

2026-09-10

### Source link

https://techcommunity.microsoft.com/example

### Who said it (for quotes)

Jane Doe, PM

### What happened

Site server loses SQL connectivity.
Roll back to 18.6.2.1.

### Key quote (optional)

Roll back as an immediate mitigation.

### Tags (optional)

SQL, ODBC Driver, sql

### Before you submit

- [X] The source is publicly available (no NDA or private content).
- [X] I'm OK with this being edited before it's published.

### Credit (optional)

@someone
'@

    $script:MinimalBody = @'
### Post type

Other

### Suggested title

Hello

### Date it happened

not a date

### Source link

https://example.com

### Who said it (for quotes)

_No response_

### What happened

Body text.

### Key quote (optional)

_No response_

### Tags (optional)

_No response_

### Credit (optional)

_No response_
'@
}

Describe 'ConvertFrom-IssueForm' {
    It 'maps every form field' {
        $f = ConvertFrom-IssueForm -Body $script:FullBody
        $f.PostType | Should -Be 'Known issue or workaround'
        $f.Title    | Should -Be 'ODBC 18.7.1.1 breaks "site" SQL'
        $f.Date     | Should -Be '2026-09-10'
        $f.Source   | Should -Be 'https://techcommunity.microsoft.com/example'
        $f.Speaker  | Should -Be 'Jane Doe, PM'
        $f.Summary  | Should -Be "Site server loses SQL connectivity.`nRoll back to 18.6.2.1."
        $f.Credit   | Should -Be '@someone'
    }

    It 'treats _No response_ as empty' {
        $f = ConvertFrom-IssueForm -Body $script:MinimalBody
        $f.Speaker | Should -BeNullOrEmpty
        $f.Quote   | Should -BeNullOrEmpty
        $f.Tags    | Should -BeNullOrEmpty
    }

    It 'handles CRLF line endings' {
        $f = ConvertFrom-IssueForm -Body ($script:MinimalBody -replace "`n", "`r`n")
        $f.Title | Should -Be 'Hello'
    }

    It 'returns empty fields for an empty body' {
        $f = ConvertFrom-IssueForm -Body ''
        $f.Title | Should -BeNullOrEmpty
    }
}

Describe 'New-PostSlug' {
    It 'lower-cases and hyphenates' { New-PostSlug 'ODBC 18.7.1.1 Breaks SQL!' | Should -Be 'odbc-18-7-1-1-breaks-sql' }
    It 'caps length at 60'          { (New-PostSlug ('a b ' * 40)).Length | Should -BeLessOrEqual 60 }
    It 'falls back to post'         { New-PostSlug '!!!' | Should -Be 'post' }
}

Describe 'Get-PostDate' {
    It 'parses YYYY-MM-DD'         { Get-PostDate '2026-09-10' | Should -Be ([datetime]'2026-09-10') }
    It 'falls back when invalid'   { Get-PostDate 'soon' -Fallback ([datetime]'2026-10-17') | Should -Be ([datetime]'2026-10-17') }
}

Describe 'New-PostMarkdown' {
    BeforeAll {
        $script:Post = New-PostMarkdown -Fields (ConvertFrom-IssueForm $script:FullBody) -IssueNumber 7 -IssueAuthor 'alice'
    }

    It 'names the file date-slug.md' {
        $script:Post.FileName | Should -Be '2026-09-10-odbc-18-7-1-1-breaks-site-sql.md'
    }

    It 'escapes the title as a YAML single-quoted string' {
        $script:Post.Content | Should -Match "(?m)^title: 'ODBC 18\.7\.1\.1 breaks ""site"" SQL'$"
    }

    It 'derives a type tag and de-duplicates user tags' {
        $script:Post.Content | Should -Match "(?m)^tags: \['known-issue', 'sql', 'odbc-driver'\]$"
    }

    It 'renders the quote with attribution' {
        $script:Post.Content | Should -Match '(?m)^> Roll back as an immediate mitigation\.$'
        $script:Post.Content | Should -Match '(?m)^> -- Jane Doe, PM$'
    }

    It 'links the source and prefers the stated credit' {
        $script:Post.Content | Should -Match ([regex]::Escape('Source: [https://techcommunity.microsoft.com/example](https://techcommunity.microsoft.com/example)'))
        $script:Post.Content | Should -Match ([regex]::Escape('*Submitted by @someone.*'))
    }

    It 'falls back to the issue author for credit and today for a bad date' {
        $p = New-PostMarkdown -Fields (ConvertFrom-IssueForm $script:MinimalBody) -IssueNumber 8 -IssueAuthor 'bob' -Today ([datetime]'2026-10-17')
        $p.FileName | Should -Be '2026-10-17-hello.md'
        $p.Content  | Should -Match ([regex]::Escape('*Submitted by @bob.*'))
        $p.Content  | Should -Not -Match '(?m)^tags:'
    }

    It 'escapes single quotes in titles' {
        $f = ConvertFrom-IssueForm $script:MinimalBody; $f.Title = "Microsoft's advice"
        (New-PostMarkdown -Fields $f -IssueNumber 9).Content | Should -Match "(?m)^title: 'Microsoft''s advice'$"
    }

    It 'rejects a non-http source' {
        $f = ConvertFrom-IssueForm $script:MinimalBody; $f.Source = 'javascript:alert(1)'
        { New-PostMarkdown -Fields $f -IssueNumber 10 } | Should -Throw '*not an http(s) URL*'
    }

    It 'rejects a missing summary' {
        $f = ConvertFrom-IssueForm $script:MinimalBody; $f.Summary = ''
        { New-PostMarkdown -Fields $f -IssueNumber 11 } | Should -Throw '*no summary*'
    }
}

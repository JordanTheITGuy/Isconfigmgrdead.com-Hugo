# isconfigmgrdead.com style guide

How posts on this site should sound. Written from Jordan Benzing's own writing on
[jordantheitguy.com](https://jordantheitguy.com) and his ConfigMgr posts on
[MSEndpointMgr](https://msendpointmgr.com/author/jordanb/). Anyone drafting a post (human or the weekly
news scout) reads this first. Edit it whenever a draft doesn't sound right.

## The voice in one line

A senior ConfigMgr admin talking to other admins over coffee: dry, direct, a little smug that the product
keeps refusing to die, and always specific.

## Rules

1. **Lead with the news, then the verdict.** First sentence says what happened, with the version, date or
   product name. A short blunt line follows. No warm-up, no "In today's fast-paced world".
2. **Short and long, mixed.** Conversational sentences carry the explanation; short fragments land the point.
   One-word or three-word lines are fine. Use them once or twice a post, not every paragraph.
3. **Dry, not jokey.** Deadpan understatement and mild sarcasm aimed at hype, roadmaps and "ConfigMgr is
   dead" takes. Never aimed at admins. Self-deprecation is welcome. No puns, no emoji, no exclamation marks.
4. **Specific beats impressive.** Exact version and build numbers, KB or hotfix IDs, log file names
   (`SMSEXEC.log`), console paths, dates. If a number matters, show it.
5. **Talk to the reader.** Second person ("your site server", "your ADRs"). First person only for opinion
   or experience ("I'd hold off", "I've seen this one before"), and say when you're not sure.
6. **Problems read like an investigation.** For known issues: symptom → what it looks like in the logs →
   cause → workaround, in that order. Tell people what to check, not just what broke.
7. **Practical caveats, plainly stated.** "Test this before you trust it." "No fix yet; Microsoft says
   they're on it." Don't hedge everything; hedge the thing that's actually uncertain.
8. **Credit and link the source.** Every post links its primary source. Quote sparingly: one short line,
   exact, when the wording itself is the story.
9. **End on a one-liner, not a summary.** A dry closing beat that ties back to the site's thesis, or a
   practical "go check X". Never "In conclusion" or "Let me know your thoughts".
10. **Keep it short.** Most posts are 80-200 words. Headings only when a post has distinct parts
    (e.g. "What it looks like / Why / Workaround").

## Words and moves to avoid

- Corporate filler: leverage, seamless, game-changer, robust, exciting, empower, unlock, delve, landscape.
- Hype or doom framing ("massive", "huge news", "the end of an era").
- Explaining what ConfigMgr is. The readers run it.
- Stacked adjectives, rhetorical questions in a row, or more than one joke per paragraph.
- Profanity. The blog allows the occasional mild one; this site stays clean.

## Moves that sound right

- A blunt reaction after the facts: "So, still shipping."
- Calling the irony when it's there, once, without milking it.
- Reassurance before detail when people might panic: "Don't panic. Roll back first."
- Admitting a surprise: "Didn't expect that sentence from Microsoft in 2026."

## Example

> **ODBC Driver 18.7.1.1 Breaks Site Server SQL Connectivity**
>
> An automatic update to ODBC Driver 18 for SQL Server (18.7.1.1) is knocking site servers off their own
> database. Don't panic. Roll back first.
>
> You'll see `sitecomp.exe` crash with `c0000005`, COM+ errors pointing at `msodbcsql18.dll`, and
> `SMSEXEC.log` retrying SQL until it gives up. According to Microsoft, ConfigMgr ships an older Visual C++
> runtime in its own folder, and the new driver doesn't get along with it.
>
> Uninstall 18.7.1.1, put 18.6.2.1 back, restart the site server, then block the update in your ADRs
> until there's a real fix.
>
> Source: [Tech Community thread](https://techcommunity.microsoft.com/discussions/configurationmanager/latest-odbc-driver-18-for-sql-18-7-1-1-breaks-sccm-site-server--sql-connectivity/4555392)
>
> Nothing says "alive" like a dependency update ruining your Monday.

# Welcome

Hello, and welcome to the 'IsConfigMGRDead.Com' behind the scenes. First a little bit of history. This website originally started as a joke just before MMS back several years ago. At the time, it was just something silly I had done with GIT. I always wanted to come back to it but never did. I never finished updating it, and I never finished doing anything with it.

Enter Hugo. When I first learned about Hugo it was through a discord group called WinAdmins. I learned it was a much better way to setup and manage dynamic content. It was focused on Markdown with well developed controls that could be added. So I started to experiment and this is the result. I hope you like it.

# Contributing

One of the core reasons I wanted to start this was to allow other users and not just myself the oppurtunity to provide positive reasons why Configuration Manager, a platform that has served us for years should have something like this to remember it by. To that end this repo will accept pull requests. However, they will require a review by myself before they are merged.

**Easiest way:** [submit a post through the issue form](https://github.com/JordanTheITGuy/Isconfigmgrdead.com-Hugo/issues/new?template=new-post.yml). Fill in the source link and a short summary, and it gets turned into a post.

Prefer a pull request? Add a new markdown file into the 'posts' section of the site located here https://github.com/JordanTheITGuy/Isconfigmgrdead.com-Hugo/tree/main/content/posts. It will need to observe the following format at the top. 
```md
---
title: "Name of the post"
date: DateTimeOfThePost
draft: false
---
```

You can then include media in the post from other sources if you so choose. However make sure you read up on how Hugo implements shortcodes https://gohugo.io/content-management/shortcodes/

Happy Contributing

# How submissions become posts

1. Someone fills in the [Submit a post](https://github.com/JordanTheITGuy/Isconfigmgrdead.com-Hugo/issues/new?template=new-post.yml) form. The issue gets the `post-submission` label.
2. The maintainer reviews it. To accept, add the `approved` label.
3. The **Post from issue** workflow turns the form into `content/posts/<date>-<slug>.md`, checks the site still builds, and opens a PR that closes the issue.
4. Edit the PR if needed and merge. The site rebuilds and publishes automatically.

The generator lives in `.github/scripts/` (PowerShell, with Pester tests).

---
title: "Configuration Manager 2609 Release"
date: 2026-09-28T09:00:00-04:00
draft: false
tags: ["release"]
---

A new build of Configuration Manager is out: **version 2609** (site version 5.00.9152.1000).

- **Type:** Current branch update, released to the early update ring on September 28, 2026. You opt in with the `EnableEarlyUpdateRing2609` script until it goes generally available.
- **What's in it:** Security hardening and fixes rather than shiny new features. SQL Server 2016 is no longer supported (SQL 2017 CU2+ is the new minimum), the site database no longer needs `TRUSTWORTHY` for ConfigMgr's SQLCLR assemblies, and CMG scale sets move to new VM sizes.

Release notes:

- [What's new in version 2609](https://learn.microsoft.com/en-us/intune/configmgr/core/plan-design/changes/whats-new-version-2609)
- [Summary of changes in version 2609](https://learn.microsoft.com/en-us/intune/configmgr/hotfix/2609/2377842)

Still shipping. Still not dead.

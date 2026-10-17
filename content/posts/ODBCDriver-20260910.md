---
title: "ODBC Driver 18.7.1.1 Breaks Site Server SQL Connectivity"
date: 2026-09-10T09:00:00-04:00
draft: false
tags: ["known-issue", "sql"]
---

Here's a fun one. When an update to the **Microsoft ODBC Driver 18 for SQL Server (18.7.1.1)** lands on a site server, Configuration Manager can lose its connection to the site database.

**What it looks like**

- `sitecomp.exe` crashes (exception `c0000005`), with COM+ errors (Event ID 4786) referencing `msodbcsql18.dll` in the Application log.
- `SMSEXEC.log` fills with repeated failures to connect to SQL, and `hman.log` threads go quiet.

**Why it happens**

According to a Microsoft response in the thread, ConfigMgr ships its own older Visual C++ runtime in its install folder, and the new ODBC driver doesn't get along with it. Updating the system-wide VC++ redistributable alone may not fix it.

**Workaround**

1. Roll the ODBC driver back to **18.6.2.1** on the site server (and any other site systems that took the update).
2. Restart the site server.
3. Block 18.7.1.1 from re-installing until there's a supported fix: decline it in WSUS, exclude it from your ADRs, or pause it in your third-party patching tool.

Full discussion: [Latest ODBC Driver 18 for SQL (18.7.1.1) breaks SCCM site server SQL connectivity](https://techcommunity.microsoft.com/discussions/configurationmanager/latest-odbc-driver-18-for-sql-18-7-1-1-breaks-sccm-site-server--sql-connectivity/4555392)

A dependency update breaking the site server is about the most alive thing a product can do.

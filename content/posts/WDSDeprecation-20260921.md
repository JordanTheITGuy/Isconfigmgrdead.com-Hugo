---
title: "WDS Is Being Deprecated. Microsoft's Advice? Use Configuration Manager."
date: 2026-09-21T09:00:00-04:00
draft: false
tags: ["osd", "wds"]
---

Microsoft announced that **Windows Deployment Services (WDS)** is deprecated starting with the next Windows Server release. It keeps working on Windows Server 2025 and earlier under their normal lifecycles, but active development is done and the role is headed for removal.

So what does Microsoft tell you to use instead?

Not Autopilot. Not Intune. **Microsoft Configuration Manager**, which the notice describes as a better, more flexible and more feature-rich way to deploy Windows images.

Yes, the same Configuration Manager that's supposedly been dead for a decade.

A couple of things worth knowing:

- **ConfigMgr OSD itself isn't affected.** If your PXE or multicast relies on the WDS role, though, Microsoft recommends moving off that dependency.
- **Hands-free WDS deployment** is already disabled by default on systems with the April 2026 updates or later.

Read the notice: [Windows Deployment Services (WDS) deprecation in the next Windows Server release](https://support.microsoft.com/en-us/servicing/os/windows/docs/2026/09/windows-deployment-services-deprecation-in-the-next-windows-server-release)

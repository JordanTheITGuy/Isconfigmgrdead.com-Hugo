---
title: "My First Post"
date: 2021-08-26T22:33:12-04:00
draft: false
---

# Asking the Right Question – With PowerShell
PowerShell has a couple of different ways to query an API. However before we can even get started with querying the API we need to build our bearer token which will authenticate us to ASK questions. Fortunately this is pretty well documented on the Microsoft Website.

```powershell
$tenantId = '' ### Paste your tenant ID here
$appId = '' ### Paste your Application ID here
$appSecret = '' ### Paste your Application secret here
    
#NOTE: Build the auth response token to the Windows Security Center API (Basically establishing a logged in session)
$resourceAppIdUri = 'https://api.securitycenter.windows.com'
$oAuthUri = "https://login.windows.net/$TenantId/oauth2/token"
$authBody = [Ordered] @{
     resource = "$resourceAppIdUri"
     client_id = "$appId"
     client_secret = "$appSecret"
     grant_type = 'client_credentials'
}
$authResponse = Invoke-RestMethod -Method Post -Uri $oAuthUri -Body $authBody -ErrorAction Stop
#NOTE: This returns your access token, and below we pull out the token that will be used as the authorization token going forward. 
$token = $authResponse.access_token
```
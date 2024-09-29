![dddd](https://github.com/user-attachments/assets/970870c8-d50a-42f8-908b-d394171b2f4c)

Summary of the 0xX4SS Script
Purpose: The script is designed to test a target domain for XSS (Cross-Site Scripting) vulnerabilities by injecting various payloads into URLs.

Vulnerability Testing:

For each gathered URL, the script injects each payload and checks the response for any script execution (looking for a specific alert in the response).
If a vulnerability is found, it logs the vulnerable URL with the injected payload in the terminal.

<h1>Prérequis : </h1>

Bash

```bash
waybackurls
```
```bash
gau
```
```bash
curl
```

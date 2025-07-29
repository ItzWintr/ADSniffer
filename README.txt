ADsniffer.ps1

Scans files on Windows NTFS systems to detect Alternate Data Streams (ADS). 
These "hidden streams" can be used to conceal malicious payloads, 
establish persistence, or simply stash secret data.

Features:
- Scans directories for files containing ADS
- Displays name, size, and stream extension
- Flags potentially dangerous streams (e.g. .exe, .ps1, .bat, etc.)
- Supports recursive scanning of subdirectories
- Allows exporting scan results to a .txt file

Usage:
- Basic scan in current directory:
  .\ADsniffer.ps1

- Scan a specific path:
  .\ADsniffer.ps1 -p "C:\Users\Winter\Desktop"

- Recursive scan:
  .\ADsniffer.ps1 -p "C:\Users\Winter" -Recursive

- Export results to file:
  .\ADsniffer.ps1 -p "C:\Users\Winter" -o "results.txt"

- Full scan with export:
  .\ADsniffer.ps1 -p "C:\" -Recursive -o "C:\ads_report.txt"

!!!! I don't recommend performing a full scan from C:\ directory if you don't want      !!!!
!!!! to spend the next 24 hours checking the log file (or the export .txt, you name it) !!!!

Output format:
File: C:\Users\Winter\Desktop\notes.txt
  └─ [STREAM] secret.txt (0.23 KB)

File: C:\Users\Winter\Desktop\video.mp4
  └─ [DANGER] malware.exe (152.40 KB)

File: C:\Users\Winter\Desktop\hacker.txt
  └─ [DANGER] script.ps1 (2.88 KB)

Final summary:
--- SCAN COMPLETE ---
Files scanned:     34
Streams detected:  7

Requirements:
- PowerShell 5.1 or later (compatible with Windows 10+)
- NTFS file system (not supported on FAT32, exFAT, etc.)

License:
This project is licensed under the MIT License. Do what you want with it.

Author:
Created by Winter. A small project focused on offensive security education and detecting NTFS steganography.

Notes:
- PowerShell allows access to ADS, but not all antivirus engines detect them by default.
- This script only detects ADS — it does not delete or modify them.
- Future improvements may include YARA scanning, hash analysis, or stream removal.

Pull requests, forks, and chaos are always welcome.
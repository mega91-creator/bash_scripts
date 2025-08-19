#!/bin/bash
echo "[*] Running Deep RAT Sweep on $(hostname) at $(date)"

# 1. Network connections
echo "[+] Active Suspicious Connections:"
ss -tunap | grep -E ':4444|:1337|:5555|:12345|:9001|:8081'

# 2. Look for reverse shells in .bashrc etc.
echo "[+] Startup File Backdoors:"
grep -iE 'curl|wget|nc|bash|sh|python|perl' ~/.bashrc ~/.bash_profile ~/.profile /etc/profile /etc/bash.bashrc 2>/dev/null

# 3. Unusual /tmp or /dev/shm activity
echo "[+] Scanning Drop Zones:"
find /tmp /dev/shm /var/tmp -type f -exec file {} \; | grep -E 'script|ELF|ASCII|Python'

# 4. Check all running processes for abnormal behavior
echo "[+] Suspicious Processes:"
ps aux | grep -E 'nc |bash -i|sh -i|python -c|perl -e' | grep -v grep

# 5. Auto-start entries
echo "[+] Systemd Services (check for custom entries):"
systemctl list-units --type=service | grep -vE 'systemd|network|dbus|syslog'

# 6. Rootkits
if command -v chkrootkit &> /dev/null; then
  chkrootkit
fi

# 7. List all non-system users with login shells
echo "[+] System Users with Shell Access:"
awk -F: '$3 >= 1000 && $7 ~ /bash/' /etc/passwd

echo "[✔] Done. Review output for any red flags."
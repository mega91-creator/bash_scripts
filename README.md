# bash_scripts
My Rando scripts

---
# Cursor Case

### **Make it executable**

```bash
sudo chmod +x /usr/local/bin/update-cursor
```

---

### **How to use it**

Whenever Cursor says “Update available” and you download the `.AppImage`, just run:

```bash
update-cursor ~/Downloads/Cursor-NEW-VERSION.AppImage
```

After it finishes, run:

```bash
pkill -f cursor && cursor &
```

to restart with the new version.

---

If you want, I can also make **Cursor’s `Help → Check for Updates` menu** automatically open a terminal and run this script when you click “Install” — but that would require a small patch inside `/opt/cursor/resources/app` to intercept the update flow.

Do you want me to wire it into the GUI as well? That way you’d update without touching the terminal.

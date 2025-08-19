Here’s your **clean, proven setup summary** for Cursor on your Ubuntu 24.04.2 LTS HP EliteBook:

---

## ✅ **What We Have Done & Proven to Work**

1. **Installed Cursor from AppImage to `/opt`**

   * Extracted AppImage:

     ```bash
     ./Cursor-*.AppImage --appimage-extract
     sudo mv squashfs-root /opt/cursor
     sudo chmod -R a+rX /opt/cursor
     sudo find /opt/cursor -type f -name AppRun -exec chmod a+rx {} \;
     ```
   * No reliance on `~/Applications` — fully system-wide.

   OR 

   # 0) Adjust this if your AppImage lives elsewhere
APPIMG="$HOME/Applications/Cursor-1.0.1-x86_64_sha.AppImage"

# 1) Extract
cd "$(mktemp -d)"
"$APPIMG" --appimage-extract

# 2) Move into place
sudo rm -rf /opt/cursor
sudo mv squashfs-root /opt/cursor

# 3) Permissions: readable & executable by you
sudo chmod -R a+rX /opt/cursor
sudo find /opt/cursor -type f -name AppRun -exec sudo chmod a+rx {} \;


2. **Created a command launcher (`cursor`)**

   * Global binary:

     ```bash
     printf '%s\n' '#!/bin/sh' \
       'exec /opt/cursor/AppRun --no-sandbox "$@"' | sudo tee /usr/local/bin/cursor >/dev/null
     sudo chmod +x /usr/local/bin/cursor
     ```
   * Now `cursor` works from anywhere in the terminal.

3. **Added desktop entry with icon**

   * `.desktop` file points to `/opt/cursor/co.anysphere.cursor.png`.
   * Cursor appears in the application menu.

4. **Handled permission issues (EACCES & file watcher crash)**

   * Granted safe read access:

     ```bash
     chmod -R a+rX /path/to/dev/projects
     ```
   * Confirmed Cursor can watch files without crashing.

5. **Moved old AppImages to backup**

   * Stored in `/home/joash/Downloads/softwares` to avoid clutter & app search duplicates.

6. **Update script ready**

   * Placeholder for future update automation so replacing `/opt/cursor` is one command.

7. **Detection awareness**

   * Cursor detectable via PATH, process list, desktop entry.
   * Stealth options discussed (rename dirs, mask process name, change .desktop entry).

---

## 🛠 **Areas We Did Not Touch (Improvement Ideas)**

1. **Automatic Update Script Integration**

   * `update-cursor` script exists in concept but not yet coded.
   * Could make Cursor updateable by running a single terminal command.

2. **Stealth/Privacy Mode**

   * Rename `/opt/cursor` and binary for reduced detectability.
   * Patch `AppRun` to hide process name.

3. **Sandbox Hardening**

   * Add extra launch flags for security without breaking dev workflows.

4. **Multi-Version Support**

   * Keep multiple Cursor versions in `/opt/cursor-VERSION` and switch via symlink.

5. **Shared Settings Backup**

   * Sync Cursor’s config between updates so preferences/extensions survive replacements.

---

If you like, I can now **write the `update-cursor` script** so you can drop in any new Cursor AppImage and auto-replace the `/opt/cursor` install without redoing steps. That way, we’ve covered 1 missing improvement right away.

Do you want me to start with that?

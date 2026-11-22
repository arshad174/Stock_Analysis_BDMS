# Upload this project to GitHub from VS Code

## One-time setup
1. Install **Git**: https://git-scm.com/downloads (restart VS Code afterwards).
2. Create a free account at https://github.com.
3. Tell Git who you are (open the VS Code terminal with ``Ctrl + ` ``):
   ```bash
   git config --global user.name "Arshad Kabir"
   git config --global user.email "your-github-email@example.com"
   ```

## Method A — VS Code buttons (no commands)
1. **File → Open Folder** and open `Stock-Analysis-BDMS-Project`.
2. Click the **Source Control** icon (left bar, or `Ctrl+Shift+G`) → **Initialize Repository**.
3. Check `.gitignore` exists so `.venv/` is not uploaded.
4. Hover over **Changes** → click **+** to stage all files.
5. Type a message such as `Initial commit` → click **Commit**.
6. Click **Publish Branch** → sign in to GitHub in the browser when asked.
7. Choose **Public** or **Private**, keep the repo name → **OK**.

## Method B — Terminal commands
1. Create an empty repo on GitHub (**New repository**; do not add a README/license, since they already exist).
2. In the VS Code terminal, from the project folder:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: BDATL stock sentiment & anomaly engine"
   git branch -M main
   git remote add origin https://github.com/arshad174/Stock_Analysis_BDMS.git
   git push -u origin main
   ```
3. Sign in when the browser prompt appears. If asked for a password, use a **Personal Access Token** (GitHub → Settings → Developer settings → Personal access tokens), not your account password.

## Later updates
```bash
git add .
git commit -m "Describe your change"
git push
```
Or use Source Control → Commit → **Sync Changes**.

## Pre-upload checklist
- [ ] `.venv/` is **not** in the Source Control list
- [ ] No `.env` file with real keys is staged (only `.env.example`)
- [ ] Screenshots show in `docs/images/`

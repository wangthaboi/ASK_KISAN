# AskKisan Legal & Compliance Pages Hosting Guide

This directory (`pages/`) contains the standalone, zero-dependency static web pages for AskKisan's legal compliance, designed for immediate hosting on GitHub Pages and compliance with **Meta/WhatsApp Cloud API App Review** and the **Digital Personal Data Protection Act, 2023 (DPDP Act, India)**.

## Pages Included

| Page | File | Purpose |
| --- | --- | --- |
| **Compliance Hub** | `index.html` | Overview and directory linking to all legal documents |
| **Privacy Policy** | `privacy.html` | DPDP Act compliant privacy policy covering phone number usage & data security |
| **Terms & Conditions** | `terms.html` | User agreement including the critical **Agricultural Advisory Disclaimer** |
| **User Data Deletion** | `data-deletion.html` | Meta/WhatsApp compliant instructions for instant in-chat or email data deletion |
| **Shared Styling** | `styles.css` | Accessible responsive design, dark mode, and **skeleton loader shimmer** |
| **Shared Script** | `app.js` | Accessible skeleton loader transition lifecycle and dynamic copyright year |

---

## Immediate Hosting Instructions via GitHub

### Option 1: Automated GitHub Actions (Recommended)

1. Open your repository on GitHub: `https://github.com/wangthaboi/ASK_KISAN`
2. Go to **Settings** &rarr; **Pages** (under Code and automation).
3. Under **Build and deployment** &rarr; **Source**, select:
   👉 **GitHub Actions**
4. Push your changes on the `develop` or `main` branch.
5. The workflow in `.github/workflows/pages.yml` will automatically deploy the `pages/` directory to:
   - **Hub URL:** `https://wangthaboi.github.io/ASK_KISAN/`
   - **Privacy Policy URL:** `https://wangthaboi.github.io/ASK_KISAN/privacy.html`
   - **Terms & Conditions URL:** `https://wangthaboi.github.io/ASK_KISAN/terms.html`
   - **Data Deletion URL:** `https://wangthaboi.github.io/ASK_KISAN/data-deletion.html`

---

### Option 2: Classic Deploy from Branch

If you prefer standard branch hosting without GitHub Actions:
1. Go to **Settings** &rarr; **Pages**.
2. Under **Build and deployment** &rarr; **Source**, select:
   👉 **Deploy from a branch**.
3. Choose the branch (`gh-pages`, `develop`, or `main`).
   *(If deploying directly from root `/`, you can copy the files from `pages/` to root or point directly to `pages/`).*
4. Click **Save**.

---

## Meta App Review / WhatsApp Cloud API Submission URLs

When filling out your Meta App Details (WhatsApp Business / Facebook Login app):

- **Privacy Policy URL:**
  `https://wangthaboi.github.io/ASK_KISAN/privacy.html`
- **Terms of Service URL:**
  `https://wangthaboi.github.io/ASK_KISAN/terms.html`
- **User Data Deletion Instructions URL:**
  `https://wangthaboi.github.io/ASK_KISAN/data-deletion.html`

All pages include skeleton loaders, responsive layouts, and are pure HTML/CSS/JS with 0 external runtime dependencies.

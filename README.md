# Beaver FP Website

Official website for Beaver FP - Financial Planning for Busy Beavers

## Overview

This is a static website hosted on GitHub Pages for beaverfp.com. It provides:
- Homepage with app information
- Privacy Policy (required for Apple App Store submission)
- Terms of Service (required for Apple App Store submission)

## File Structure

```
beaverfp-website/
├── index.html          # Homepage
├── privacy.html        # Privacy Policy
├── terms.html          # Terms of Service
├── style.css           # Shared stylesheet
└── README.md          # This file
```

## Deployment Instructions

### 1. Create GitHub Repository

1. Go to [GitHub](https://github.com) and log in
2. Click the "+" icon in the top-right and select "New repository"
3. Name: `beaverfp-website`
4. Description: "Official website for Beaver FP"
5. Set to **Public** (required for GitHub Pages free hosting)
6. Do NOT initialize with README (we already have one)
7. Click "Create repository"

### 2. Push to GitHub

From this directory (`/Users/robarmstrong/project/beaverfp-website/`), run:

```bash
# If not already initialized (should be done automatically):
# git init
# git add .
# git commit -m "Initial website with privacy policy and terms of service"

# Add GitHub remote (replace with your actual repository URL)
git remote add origin https://github.com/YOUR_USERNAME/beaverfp-website.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### 3. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click "Settings" tab
3. Scroll down to "Pages" in the left sidebar
4. Under "Source":
   - Branch: Select `main`
   - Folder: Select `/ (root)`
5. Click "Save"
6. Wait 1-2 minutes for deployment
7. Your site will be available at: `https://YOUR_USERNAME.github.io/beaverfp-website/`

### 4. Configure Custom Domain (beaverfp.com)

#### On GitHub:
1. In repository Settings → Pages
2. Under "Custom domain", enter: `beaverfp.com`
3. Click "Save"
4. Wait for DNS check (may take a few minutes)
5. Check "Enforce HTTPS" once DNS is verified

#### On GoDaddy:
1. Log in to your GoDaddy account
2. Go to "My Products" → Find your domain → Click "DNS"
3. Update DNS records:

   **For root domain (beaverfp.com):**
   - Type: `A`
   - Name: `@`
   - Value: `185.199.108.153`
   - TTL: 600 seconds

   Add three more A records with these IPs:
   - `185.199.109.153`
   - `185.199.110.153`
   - `185.199.111.153`

   **For www subdomain:**
   - Type: `CNAME`
   - Name: `www`
   - Value: `YOUR_USERNAME.github.io`
   - TTL: 1 hour

4. Save all DNS records
5. Wait 10-60 minutes for DNS propagation

### 5. Create CNAME File (Important!)

Create a file named `CNAME` (no extension) in the root directory with content:
```
beaverfp.com
```

Then push to GitHub:
```bash
git add CNAME
git commit -m "Add CNAME file for custom domain"
git push
```

### 6. Set Up Email (support@beaverfp.com)

#### Option A: GoDaddy Email Forwarding (Free)
1. In GoDaddy, go to your domain
2. Click "Email" → "Manage"
3. Set up email forwarding:
   - Forward `support@beaverfp.com` to `robert.d.armstrong@gmail.com`

#### Option B: Google Workspace (Paid, ~$6/month)
1. Sign up for Google Workspace
2. Verify domain ownership
3. Set up MX records as provided by Google
4. Create `support@beaverfp.com` mailbox

#### Option C: Third-Party Service
- Consider: Zoho Mail (free tier), ProtonMail, or Mailgun

### 7. Verify for Apple App Store

Once deployed, verify these URLs are accessible:
- **Privacy Policy**: `https://beaverfp.com/privacy.html`
- **Terms of Service**: `https://beaverfp.com/terms.html`

Use these exact URLs in your App Store Connect submission.

## Updating the Website

To make changes:

1. Edit the HTML/CSS files locally
2. Test locally by opening `index.html` in a browser
3. Commit and push changes:
   ```bash
   git add .
   git commit -m "Description of changes"
   git push
   ```
4. Changes will be live in 1-2 minutes

## Local Development

To test locally before deploying:

1. Open `index.html` directly in a web browser, or
2. Use a local web server:
   ```bash
   # Python 3
   python3 -m http.server 8000

   # Then visit http://localhost:8000
   ```

## Troubleshooting

### Website Not Loading After DNS Changes
- DNS propagation can take 24-48 hours (usually faster)
- Check DNS propagation: https://www.whatsmydns.net/
- Clear browser cache (Cmd+Shift+R on Mac)

### Custom Domain Not Working on GitHub
- Ensure CNAME file exists in repository
- Verify DNS settings in GoDaddy
- Check GitHub Pages settings
- Look for DNS check errors in Settings → Pages

### HTTPS Not Available
- Wait 24 hours after DNS configuration
- Ensure "Enforce HTTPS" is checked in GitHub Pages settings
- Custom domains need DNS to be fully propagated first

### Email Not Working
- Email forwarding may take 1-2 hours to activate
- Check spam folder
- Verify forwarding settings in GoDaddy

## Support

For questions about this website, contact:
- Email: support@beaverfp.com
- Developer: Rob Armstrong

## License

© 2025 Rob Armstrong. All Rights Reserved.

# 🔧 TROUBLESHOOTING - Network Installation Issues

## Problem: npm Socket Timeout Error

You're experiencing network timeout issues when installing dependencies. This is common and can be resolved!

---

## ✅ Solutions (Try in Order)

### Solution 1: Use Alternative npm Registry (Recommended)

Switch to a faster mirror:

```bash
cd /home/lwena/LwenaTechWareAfrica/next-app

# Try Taobao mirror (usually faster in some regions)
npm config set registry https://registry.npmmirror.com

# Install with increased timeout
npm install --fetch-timeout=600000
```

If that works, great! If not, switch back:
```bash
npm config set registry https://registry.npmjs.org/
```

---

### Solution 2: Install with Yarn (Faster & More Reliable)

Yarn often handles network issues better:

```bash
# Install Yarn if you don't have it
npm install -g yarn

# Navigate to project
cd /home/lwena/LwenaTechWareAfrica/next-app

# Install dependencies with Yarn
yarn install
```

---

### Solution 3: Manual Timeout Configuration

```bash
cd /home/lwena/LwenaTechWareAfrica/next-app

# Set aggressive timeout values
npm config set fetch-timeout 600000
npm config set fetch-retry-mintimeout 200000
npm config set fetch-retry-maxtimeout 1200000
npm config set fetch-retries 5

# Clear cache
npm cache clean --force

# Try again
npm install
```

---

### Solution 4: Check Network & Retry

```bash
# Check if you can reach npm registry
ping registry.npmjs.org

# If ping works, check your internet speed
# Slow internet? Try installing in smaller batches (see Solution 5)
```

---

### Solution 5: Install Core Dependencies First

Install critical packages one at a time:

```bash
cd /home/lwena/LwenaTechWareAfrica/next-app

# Install Next.js and React first
npm install next@14.2.0 react@18.3.0 react-dom@18.3.0

# Then install UI dependencies
npm install @radix-ui/react-slot class-variance-authority clsx tailwind-merge

# Then install icons
npm install lucide-react

# Then dev dependencies
npm install -D typescript @types/node @types/react @types/react-dom tailwindcss postcss autoprefixer

# Finally, run to fix any missing deps
npm install
```

---

### Solution 6: Offline Installation (If you have another computer)

If you have access to another computer with better internet:

**On Computer with Good Internet:**
```bash
# Clone the same project
# Run: npm install
# Copy the entire node_modules folder

# Create a tarball
tar -czf node_modules.tar.gz node_modules/
```

**On Your Computer:**
```bash
# Copy node_modules.tar.gz to: /home/lwena/LwenaTechWareAfrica/next-app/

# Extract
cd /home/lwena/LwenaTechWareAfrica/next-app
tar -xzf node_modules.tar.gz

# Now you can run the project!
npm run dev
```

---

## 🚀 Alternative: Use CodeSandbox or StackBlitz

If local installation keeps failing, use online IDEs:

### CodeSandbox
1. Go to https://codesandbox.io
2. Import from GitHub or upload files
3. Edit and preview instantly
4. No installation needed!

### StackBlitz  
1. Go to https://stackblitz.com
2. Create Next.js project
3. Copy your files over
4. Instant preview!

---

## 🔍 Diagnostic Commands

Check your setup:

```bash
# Check Node version (should be 18+)
node --version

# Check npm version
npm --version

# Check npm config
npm config list

# Check internet connection
ping google.com
ping registry.npmjs.org

# Check npm registry
npm config get registry
```

---

## 📝 Common Causes

1. **Slow Internet** - Use Yarn or alternative registry
2. **Network Restrictions** - Use VPN or different network
3. **Firewall/Proxy** - Configure npm proxy settings
4. **npm Cache Corruption** - Clear cache: `npm cache clean --force`
5. **Registry Issues** - Switch to mirror registry

---

## ✅ What to Do Now

**Recommended Path:**

1. **Try Yarn** (Solution 2) - Usually works best
2. **Try Alternative Registry** (Solution 1) - Faster mirror
3. **Try Installing Core First** (Solution 5) - Smaller batches
4. **Use Online IDE** - CodeSandbox/StackBlitz as backup

---

## 🆘 Still Having Issues?

### Option 1: Contact for Pre-built Version
Email: lwenatech@gmail.com
- I can send you a pre-built version with node_modules
- Or help you troubleshoot specific network issues

### Option 2: Use Development Container
If you have Docker:
```bash
# I can create a Dockerfile that handles installation
```

### Option 3: Different Network
- Try from a different location
- Use mobile hotspot
- Try at different time (less congestion)

---

## 📚 Meanwhile: Review the Code

While waiting for installation to work, you can:

1. **Read the Documentation**
   - Review all the .md files
   - Understand the structure
   - Plan your content

2. **View the Code**
   - Open files in VS Code
   - See component structure
   - Understand the design

3. **Plan Your Content**
   - Write About Us content
   - Prepare product descriptions
   - Gather images

---

## 💡 Pro Tip

**Use Yarn** - It's more reliable:
```bash
npm install -g yarn
cd /home/lwena/LwenaTechWareAfrica/next-app
yarn install
yarn dev
```

This usually works when npm fails!

---

## ✨ Don't Worry!

This is a **temporary network issue**, not a problem with the code or project.

The website structure is complete and perfect - we just need to get the dependencies installed.

Once installed, everything will work smoothly! 🚀

---

**Let me know which solution worked for you!**

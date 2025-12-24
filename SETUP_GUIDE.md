# 🚀 SETUP GUIDE - Lwena TechWareAfrica Website

## Quick Start (5 minutes)

### Step 1: Install Dependencies

```bash
cd next-app
npm install
```

This will install:
- Next.js 14
- React 18
- TypeScript
- Tailwind CSS
- shadcn/ui components
- Lucide icons

### Step 2: Run Development Server

```bash
npm run dev
```

Visit **http://localhost:3000** to see your website! 🎉

---

## 📋 What's Been Created

### ✅ Complete Components
1. **Layout Components**
   - Header with navigation & mobile menu
   - Footer with links and contact info
   
2. **Home Page Sections**
   - Hero section with CTAs
   - Value Proposition (4 cards)
   - Services Overview (6 services)
   - Products Showcase (4 products)
   - Testimonials (3 reviews)
   - CTA Section

3. **Product Page Example**
   - InventoryMaster detail page (`/products/inventorymaster`)

4. **Configuration**
   - Tailwind config with brand colors
   - TypeScript configuration
   - Next.js config with image optimization
   - SEO metadata in layout

---

## 🎨 Brand Colors Applied

- **Primary Blue (#232F3E)** - Headers, footers, main sections
- **Secondary Orange (#FF9900)** - CTA buttons, highlights only
- **Background (#EAEDED)** - Page backgrounds
- **Borders (#D4D4D4)** - Subtle dividers
- **Muted (#777777)** - Secondary text

### Usage Examples:
```tsx
// Primary blue background
className="bg-primary text-white"

// Orange CTA button
<Button variant="cta">Get Started</Button>

// Outlined button
<Button variant="outline">Learn More</Button>
```

---

## 📄 Pages to Create Next

### Priority 1: Essential Pages
1. **About Us** (`src/app/about/page.tsx`)
   - Company vision & mission
   - Team information
   - Company history

2. **Contact** (`src/app/contact/page.tsx`)
   - Contact form
   - Email, phone, location
   - WhatsApp integration

3. **Services Landing** (`src/app/services/page.tsx`)
   - Overview of all services
   - Links to individual service pages

### Priority 2: Product Pages
Create pages for remaining products:
- SmartMenu QR (`src/app/products/smartmenu-qr/page.tsx`)
- Weather Admin (`src/app/products/weatheradmin/page.tsx`)
- SMS Gateway Pro (`src/app/products/sms-gateway-pro/page.tsx`)

Use `inventorymaster/page.tsx` as template!

### Priority 3: Additional
- Individual service detail pages
- Portfolio/case studies
- Blog setup with MDX

---

## 🛠️ Development Tips

### Adding a New Page

1. Create folder structure:
```bash
mkdir -p src/app/about
```

2. Create `page.tsx`:
```tsx
import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'About Us',
  description: 'Learn about Lwena TechWareAfrica...',
}

export default function AboutPage() {
  return (
    <div>
      <h1>About Us</h1>
    </div>
  )
}
```

### Adding a New Component

```tsx
// src/components/ui/my-component.tsx
export function MyComponent() {
  return <div>My Component</div>
}
```

### Using Icons

```tsx
import { ArrowRight, Mail, Phone } from 'lucide-react'

<ArrowRight className="h-5 w-5 text-secondary" />
```

---

## 🎯 Design Guidelines Reminder

### DO ✅
- Use primary blue for main sections
- Use orange **only** for CTAs and highlights
- Keep designs clean and minimal
- Use consistent spacing
- Follow enterprise-grade aesthetics

### DON'T ❌
- Don't overuse orange color
- Don't add flashy animations
- Don't clutter interfaces
- Don't use too many fonts

---

## 🚀 Deployment

### Build for Production

```bash
npm run build
npm start
```

### Deploy to Vercel (Recommended)

1. Push code to GitHub
2. Connect to Vercel
3. Deploy automatically!

### Deploy to Netlify

1. Build command: `npm run build`
2. Publish directory: `.next`
3. Deploy!

---

## 📊 Performance Targets

Aim for these Lighthouse scores:
- **Performance:** ≥ 90
- **SEO:** ≥ 95
- **Accessibility:** ≥ 90
- **Best Practices:** ≥ 95

---

## 🆘 Troubleshooting

### Port Already in Use
```bash
# Kill process on port 3000
npx kill-port 3000
npm run dev
```

### Build Errors
```bash
# Clean install
rm -rf node_modules package-lock.json
npm install
```

### TypeScript Errors
- Errors are expected until dependencies are installed
- Run `npm install` to resolve

---

## 📚 Useful Commands

```bash
# Development
npm run dev          # Start dev server
npm run build        # Build for production
npm start            # Start production server
npm run lint         # Check code quality

# Clear cache
rm -rf .next
```

---

## 📧 Need Help?

Contact: **lwenatech@gmail.com**

---

**Happy Coding! 🎉**

*Building world-class software from Africa for the global market.*

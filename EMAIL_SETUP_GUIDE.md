# Email Contact Form Setup Guide

## Overview
This guide explains how to set up the contact form to receive email submissions on your TechWareAfrica website.

## Features
✅ Email submissions from contact form
✅ Automatic confirmation email to visitor
✅ Email to TechWareAfrica team with full submission details
✅ HTML formatted emails with branding
✅ Error handling and user feedback
✅ Security with HTML escaping

## Setup Instructions

### Option 1: Gmail SMTP (Recommended)

#### Step 1: Enable 2-Factor Authentication
1. Go to https://myaccount.google.com/security
2. Click on "2-Step Verification"
3. Follow the setup process

#### Step 2: Generate App Password
1. Go to https://myaccount.google.com/apppasswords
2. Select "Mail" and "Windows Computer" (or your device)
3. Click "Generate"
4. Copy the generated 16-character password

#### Step 3: Configure Environment Variables
1. Create or edit `.env.local` in the project root:
```bash
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-16-character-app-password
```

2. **Important:** Add `.env.local` to `.gitignore` to keep credentials safe:
```bash
echo ".env.local" >> .gitignore
```

#### Step 4: Test the Form
1. Start the dev server: `npm run dev`
2. Navigate to http://localhost:3000/contact
3. Fill out the form and submit
4. Check your email for confirmation and notification

### Option 2: SendGrid

If you prefer SendGrid, update `src/app/api/contact/route.ts`:

```typescript
import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  host: 'smtp.sendgrid.net',
  port: 587,
  auth: {
    user: 'apikey',
    pass: process.env.SENDGRID_API_KEY,
  },
});
```

Environment variables:
```
SENDGRID_API_KEY=your-sendgrid-api-key
```

### Option 3: AWS SES

Update the transporter configuration:

```typescript
import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  host: process.env.AWS_SES_HOST,
  port: 587,
  auth: {
    user: process.env.AWS_SES_USER,
    pass: process.env.AWS_SES_PASSWORD,
  },
});
```

Environment variables:
```
AWS_SES_HOST=email-smtp.region.amazonaws.com
AWS_SES_USER=your-ses-username
AWS_SES_PASSWORD=your-ses-password
```

## File Structure

```
src/
├── app/
│   ├── api/
│   │   └── contact/
│   │       └── route.ts          # Email API endpoint
│   └── contact/
│       └── page.tsx              # Contact page
└── components/
    └── contact/
        └── ContactForm.tsx       # React form component
```

## How It Works

### 1. User Submits Form
User fills out the contact form on `/contact` page

### 2. Form Submission
ContactForm component sends form data to `/api/contact` endpoint

### 3. Email Validation
API validates required fields (name, email, subject, message)

### 4. Send Emails
Two emails are sent:
- **To Team:** Full submission details
- **To User:** Confirmation receipt

### 5. Response Feedback
User sees success/error message on the form

## Email Templates

### Team Notification Email
- Sender: Email from `EMAIL_USER`
- Recipient: `techwareafrican@gmail.com`
- Reply-To: Visitor's email
- Contains: Full form details with HTML formatting

### User Confirmation Email
- Sender: Email from `EMAIL_USER`
- Recipient: Visitor's email
- Contains: Thank you message + summary of submission

## Security Considerations

✅ **HTML Escaping:** All user input is escaped to prevent XSS
✅ **Environment Variables:** Credentials stored in `.env.local` (not in git)
✅ **Server-Side Processing:** Email logic runs on server, not exposed to client
✅ **HTTPS Only:** Contact form should only work on HTTPS in production

## Troubleshooting

### "Failed to send email" Error

**Issue:** Gmail authentication failed
**Solution:**
- Verify Email_USER and EMAIL_PASSWORD are correct
- Check if 2FA is enabled
- Regenerate App Password
- Wait a few minutes if just created

**Issue:** SMTP Connection Error
**Solution:**
- Check internet connection
- Verify EMAIL_USER format (must be full Gmail address)
- Check if firewall blocks port 587

### Email Not Received

**Issue:** Email goes to spam folder
**Solution:**
- Add your sending email to contacts
- Mark as "Not Spam"
- Check SPF/DKIM records if using custom domain

**Issue:** No confirmation email sent
**Solution:**
- Check browser console for errors
- Verify email address is valid
- Check email server logs

## Testing

### Manual Testing
1. Fill out form with test data
2. Check received emails
3. Verify formatting and content

### Automated Testing
```bash
npm run test
```

## Production Deployment

### Before Going Live

1. ✅ Set environment variables on hosting platform
   - Vercel: Settings → Environment Variables
   - Netlify: Site settings → Build & deploy → Environment
   - Other: Follow platform-specific docs

2. ✅ Test form on production URL
3. ✅ Monitor email delivery
4. ✅ Set up email backup system

### Environment Variables on Vercel
```bash
# In Vercel Dashboard
EMAIL_USER: your-email@gmail.com
EMAIL_PASSWORD: your-16-char-password
```

## Monitoring & Logs

Check API route logs:
```bash
# View production logs
vercel logs     # Vercel
netlify logs    # Netlify
```

## Future Enhancements

- [ ] Add rate limiting to prevent spam
- [ ] Implement CAPTCHA verification
- [ ] Add email scheduling for delayed sends
- [ ] Create admin dashboard for viewing submissions
- [ ] Add database storage for form submissions
- [ ] Implement email templates with Handlebars
- [ ] Add file upload support
- [ ] Multi-language support

## Support

For issues or questions:
- GitHub: https://github.com/LWENA27
- Email: techwareafrican@gmail.com
- Phone: +255 683 274 343

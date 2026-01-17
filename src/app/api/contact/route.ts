import nodemailer from 'nodemailer';
import { NextRequest, NextResponse } from 'next/server';

// Configure your email service
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});

interface ContactFormData {
  name: string;
  email: string;
  phone?: string;
  company?: string;
  subject: string;
  message: string;
}

export async function POST(request: NextRequest) {
  try {
    const body: ContactFormData = await request.json();

    // Validate required fields
    if (!body.name || !body.email || !body.subject || !body.message) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    // Email to TechWareAfrica team
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: 'techwareafrican@gmail.com',
      replyTo: body.email,
      subject: `New Contact Form Submission: ${body.subject}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #232F3E; border-bottom: 3px solid #FF9900; padding-bottom: 10px;">
            New Contact Form Submission
          </h2>
          
          <div style="margin: 20px 0;">
            <p><strong style="color: #232F3E;">Name:</strong> ${escapeHtml(body.name)}</p>
            <p><strong style="color: #232F3E;">Email:</strong> <a href="mailto:${escapeHtml(body.email)}">${escapeHtml(body.email)}</a></p>
            ${body.phone ? `<p><strong style="color: #232F3E;">Phone:</strong> ${escapeHtml(body.phone)}</p>` : ''}
            ${body.company ? `<p><strong style="color: #232F3E;">Company:</strong> ${escapeHtml(body.company)}</p>` : ''}
            <p><strong style="color: #232F3E;">Subject:</strong> ${escapeHtml(body.subject)}</p>
          </div>

          <div style="background-color: #f5f5f5; padding: 15px; border-left: 4px solid #FF9900; margin: 20px 0;">
            <h3 style="color: #232F3E; margin-top: 0;">Message:</h3>
            <p style="color: #555; white-space: pre-wrap;">${escapeHtml(body.message)}</p>
          </div>

          <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #888;">
            <p>This email was generated automatically from the TechWareAfrica contact form.</p>
            <p>Visit: <a href="https://techwareafrica.tech/contact">TechWareAfrica Contact</a></p>
          </div>
        </div>
      `,
    };

    // Send email to TechWareAfrica
    await transporter.sendMail(mailOptions);

    // Optional: Send confirmation email to user
    const confirmationEmail = {
      from: process.env.EMAIL_USER,
      to: body.email,
      subject: 'We received your message - TechWareAfrica',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #232F3E;">Thank you, ${escapeHtml(body.name)}!</h2>
          
          <p style="color: #555; font-size: 16px;">
            We've received your message and will get back to you as soon as possible.
          </p>

          <div style="background-color: #f5f5f5; padding: 15px; border-left: 4px solid #FF9900; margin: 20px 0;">
            <h3 style="color: #232F3E; margin-top: 0;">Your Message Summary:</h3>
            <p><strong>Subject:</strong> ${escapeHtml(body.subject)}</p>
            <p><strong>Email:</strong> ${escapeHtml(body.email)}</p>
            ${body.phone ? `<p><strong>Phone:</strong> ${escapeHtml(body.phone)}</p>` : ''}
          </div>

          <p style="color: #555;">
            <strong>Contact Information:</strong><br/>
            Email: techwareafrican@gmail.com<br/>
            Phone: +255 683 274 343<br/>
            Business Hours: Monday - Friday, 8:00 AM - 6:00 PM CAT<br/>
            Emergency Support: 24/7
          </p>

          <p style="color: #555;">
            Best regards,<br/>
            <strong>TechWareAfrica Team</strong><br/>
            <em>World-Class Software Solutions from Africa</em>
          </p>

          <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #888;">
            <p>Follow us on social media: @techwareafrica</p>
            <p>
              <a href="https://www.tiktok.com/@techwareafrica">TikTok</a> | 
              <a href="https://github.com/LWENA27">GitHub</a> | 
              <a href="https://www.linkedin.com/in/lwena-adam-b55944322/">LinkedIn</a>
            </p>
          </div>
        </div>
      `,
    };

    await transporter.sendMail(confirmationEmail);

    return NextResponse.json(
      { success: true, message: 'Email sent successfully' },
      { status: 200 }
    );
  } catch (error) {
    console.error('Email sending error:', error);
    return NextResponse.json(
      { error: 'Failed to send email. Please try again later.' },
      { status: 500 }
    );
  }
}

function escapeHtml(text: string): string {
  const map: { [key: string]: string } = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;',
  };
  return text.replace(/[&<>"']/g, (m) => map[m]);
}

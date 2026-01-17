import { Metadata } from 'next'
import { Mail, Phone, MapPin, Clock, Github, Linkedin, TrendingUp } from 'lucide-react'
import { ContactForm } from '@/components/contact/ContactForm'

export const metadata: Metadata = {
  title: 'Contact Us',
  description: 'Get in touch with TechWareAfrica. We\'re here to help with your software needs.',
}

export default function ContactPage() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-[#232F3E] to-[#1a242e] text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto text-center">
            <h1 className="text-4xl md:text-5xl font-bold mb-6">
              Get in Touch
            </h1>
            <p className="text-xl text-gray-300">
              Have a project in mind? Let's discuss how we can help you succeed.
            </p>
          </div>
        </div>
      </section>

      {/* Contact Form & Info */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-4">
          <div className="max-w-6xl mx-auto grid lg:grid-cols-2 gap-12">
            {/* Contact Form */}
            <div>
              <h2 className="text-3xl font-bold text-[#232F3E] mb-6">Send Us a Message</h2>
              <ContactForm />
            </div>

            {/* Contact Information */}
            <div className="space-y-8">
              <div>
                <h2 className="text-3xl font-bold text-[#232F3E] mb-6">Contact Information</h2>
                <p className="text-gray-600 mb-8">
                  We're here to answer any questions you may have. Reach out to us and we'll respond as soon as we can.
                </p>
              </div>

              <div className="space-y-6">
                <div className="flex items-start space-x-4">
                  <div className="w-12 h-12 bg-[#FF9900] rounded-lg flex items-center justify-center flex-shrink-0">
                    <Mail className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-[#232F3E] mb-1">Email</h3>
                    <p className="text-gray-600">techwareafrica@gmail.com</p>
                  </div>
                </div>

                <div className="flex items-start space-x-4">
                  <div className="w-12 h-12 bg-[#FF9900] rounded-lg flex items-center justify-center flex-shrink-0">
                    <Phone className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-[#232F3E] mb-1">Phone</h3>
                    <p className="text-gray-600">+255 683 274 343</p>
                    <p className="text-gray-600">Available 24/7</p>
                  </div>
                </div>

                <div className="flex items-start space-x-4">
                  <div className="w-12 h-12 bg-[#FF9900] rounded-lg flex items-center justify-center flex-shrink-0">
                    <MapPin className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-[#232F3E] mb-1">Location</h3>
                    <p className="text-gray-600">Dar es Salaam, Tanzania</p>
                    <p className="text-gray-600">Serving clients worldwide</p>
                  </div>
                </div>

                <div className="flex items-start space-x-4">
                  <div className="w-12 h-12 bg-[#FF9900] rounded-lg flex items-center justify-center flex-shrink-0">
                    <Clock className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-[#232F3E] mb-1">Business Hours</h3>
                    <p className="text-gray-600">Monday - Friday: 8:00 AM - 6:00 PM CAT</p>
                    <p className="text-gray-600">24/7 Emergency Support Available</p>
                  </div>
                </div>
              </div>

              {/* Social Links */}
              <div className="bg-[#EAEDED] p-6 rounded-lg">
                <h3 className="font-semibold text-[#232F3E] mb-4">Meet Us on Social Media</h3>
                <p className="text-sm text-gray-600 mb-4">Follow us on all platforms @techwareafrica</p>
                <div className="flex flex-wrap gap-3">
                  <a
                    href="https://www.tiktok.com/@techwareafrica"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-2 px-4 py-2 bg-[#232F3E] text-white rounded-lg hover:bg-[#FF9900] transition-colors text-sm font-medium"
                    title="TikTok @techwareafrica"
                  >
                    <TrendingUp className="h-4 w-4" />
                    <span>TikTok</span>
                  </a>
                  <a
                    href="https://github.com/LWENA27"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-2 px-4 py-2 bg-[#232F3E] text-white rounded-lg hover:bg-[#FF9900] transition-colors text-sm font-medium"
                    title="GitHub"
                  >
                    <Github className="h-4 w-4" />
                    <span>GitHub</span>
                  </a>
                  <a
                    href="https://www.linkedin.com/in/lwena-adam-b55944322/"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-2 px-4 py-2 bg-[#232F3E] text-white rounded-lg hover:bg-[#FF9900] transition-colors text-sm font-medium"
                    title="LinkedIn"
                  >
                    <Linkedin className="h-4 w-4" />
                    <span>LinkedIn</span>
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ Section */}
      <section className="py-20 bg-[#EAEDED]">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl font-bold text-[#232F3E] mb-8 text-center">Frequently Asked Questions</h2>
            
            <div className="space-y-4">
              {[
                {
                  q: 'What is your typical response time?',
                  a: 'We typically respond to all inquiries within 24 hours during business days. For urgent matters, please call our 24/7 support line.',
                },
                {
                  q: 'Do you offer custom software development?',
                  a: 'Yes! In addition to our ready-made products, we offer custom software development services tailored to your specific business needs.',
                },
                {
                  q: 'What industries do you serve?',
                  a: 'We serve a wide range of industries including retail, hospitality, agriculture, logistics, and more. Our solutions are designed to be flexible and adaptable.',
                },
                {
                  q: 'Do you provide training and support?',
                  a: 'Absolutely! We provide comprehensive training for all our products and offer 24/7 technical support to ensure your success.',
                },
              ].map((faq, index) => (
                <details
                  key={index}
                  className="bg-white p-6 rounded-lg shadow-sm group"
                >
                  <summary className="font-semibold text-[#232F3E] cursor-pointer list-none flex items-center justify-between">
                    <span>{faq.q}</span>
                    <span className="text-[#FF9900] group-open:rotate-180 transition-transform">▼</span>
                  </summary>
                  <p className="mt-4 text-gray-600 leading-relaxed">{faq.a}</p>
                </details>
              ))}
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}

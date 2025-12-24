import { Metadata } from 'next'
import { Mail, Phone, MapPin, Clock } from 'lucide-react'

export const metadata: Metadata = {
  title: 'Contact Us',
  description: 'Get in touch with Lwena TechWareAfrica. We\'re here to help with your software needs.',
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
              <form className="space-y-6">
                <div>
                  <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
                    Full Name *
                  </label>
                  <input
                    type="text"
                    id="name"
                    name="name"
                    required
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#FF9900] focus:border-transparent outline-none transition-all"
                    placeholder="John Doe"
                  />
                </div>

                <div>
                  <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                    Email Address *
                  </label>
                  <input
                    type="email"
                    id="email"
                    name="email"
                    required
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#FF9900] focus:border-transparent outline-none transition-all"
                    placeholder="john@example.com"
                  />
                </div>

                <div>
                  <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-2">
                    Phone Number
                  </label>
                  <input
                    type="tel"
                    id="phone"
                    name="phone"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#FF9900] focus:border-transparent outline-none transition-all"
                    placeholder="+1 (555) 000-0000"
                  />
                </div>

                <div>
                  <label htmlFor="company" className="block text-sm font-medium text-gray-700 mb-2">
                    Company Name
                  </label>
                  <input
                    type="text"
                    id="company"
                    name="company"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#FF9900] focus:border-transparent outline-none transition-all"
                    placeholder="Your Company"
                  />
                </div>

                <div>
                  <label htmlFor="subject" className="block text-sm font-medium text-gray-700 mb-2">
                    Subject *
                  </label>
                  <select
                    id="subject"
                    name="subject"
                    required
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#FF9900] focus:border-transparent outline-none transition-all"
                  >
                    <option value="">Select a subject</option>
                    <option value="general">General Inquiry</option>
                    <option value="products">Product Information</option>
                    <option value="support">Technical Support</option>
                    <option value="partnership">Partnership Opportunity</option>
                    <option value="demo">Request a Demo</option>
                    <option value="other">Other</option>
                  </select>
                </div>

                <div>
                  <label htmlFor="message" className="block text-sm font-medium text-gray-700 mb-2">
                    Message *
                  </label>
                  <textarea
                    id="message"
                    name="message"
                    required
                    rows={6}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#FF9900] focus:border-transparent outline-none transition-all resize-none"
                    placeholder="Tell us about your project or inquiry..."
                  />
                </div>

                <button
                  type="submit"
                  className="w-full bg-[#FF9900] text-white px-8 py-4 rounded-lg font-semibold hover:bg-[#e68a00] transition-colors"
                >
                  Send Message
                </button>
              </form>
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
                    <p className="text-gray-600">info@lwenatech.africa</p>
                    <p className="text-gray-600">support@lwenatech.africa</p>
                  </div>
                </div>

                <div className="flex items-start space-x-4">
                  <div className="w-12 h-12 bg-[#FF9900] rounded-lg flex items-center justify-center flex-shrink-0">
                    <Phone className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-[#232F3E] mb-1">Phone</h3>
                    <p className="text-gray-600">+260 XXX XXX XXX</p>
                    <p className="text-gray-600">Available 24/7</p>
                  </div>
                </div>

                <div className="flex items-start space-x-4">
                  <div className="w-12 h-12 bg-[#FF9900] rounded-lg flex items-center justify-center flex-shrink-0">
                    <MapPin className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-[#232F3E] mb-1">Location</h3>
                    <p className="text-gray-600">Lusaka, Zambia</p>
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
                <h3 className="font-semibold text-[#232F3E] mb-4">Follow Us</h3>
                <div className="flex space-x-4">
                  <a
                    href="#"
                    className="w-10 h-10 bg-[#232F3E] rounded-lg flex items-center justify-center hover:bg-[#FF9900] transition-colors"
                    aria-label="LinkedIn"
                  >
                    <span className="text-white text-sm font-bold">in</span>
                  </a>
                  <a
                    href="#"
                    className="w-10 h-10 bg-[#232F3E] rounded-lg flex items-center justify-center hover:bg-[#FF9900] transition-colors"
                    aria-label="GitHub"
                  >
                    <span className="text-white text-sm font-bold">GH</span>
                  </a>
                  <a
                    href="#"
                    className="w-10 h-10 bg-[#232F3E] rounded-lg flex items-center justify-center hover:bg-[#FF9900] transition-colors"
                    aria-label="Twitter"
                  >
                    <span className="text-white text-sm font-bold">𝕏</span>
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

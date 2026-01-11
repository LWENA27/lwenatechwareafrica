import Link from 'next/link'
import { Mail, Phone, MapPin, Github, Linkedin, Twitter } from 'lucide-react'

export function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="bg-primary text-white">
      <div className="container mx-auto px-4 py-12 lg:px-8">
        <div className="grid grid-cols-1 gap-8 md:grid-cols-2 lg:grid-cols-4">
          {/* Company Info */}
          <div>
            <h3 className="text-xl font-bold font-heading mb-4">
              Lwena <span className="text-secondary">TechWareAfrica</span>
            </h3>
            <p className="text-sm text-white/80 mb-4">
              World-class software solutions built in Africa for the global market. 
              Delivering enterprise-grade SaaS, mobile apps, and custom systems.
            </p>
            <div className="flex gap-4">
              <a href="https://github.com/LWENA27" target="_blank" rel="noopener noreferrer" 
                 className="text-white/80 hover:text-secondary transition-colors">
                <Github className="h-5 w-5" />
              </a>
              <a href="https://www.linkedin.com/in/lwena-adam-b55944322/" className="text-white/80 hover:text-secondary transition-colors">
                <Linkedin className="h-5 w-5" />
              </a>
              <a href="#" className="text-white/80 hover:text-secondary transition-colors">
                <Twitter className="h-5 w-5" />
              </a>
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="font-semibold mb-4">Quick Links</h4>
            <ul className="space-y-2 text-sm">
              <li><Link href="/about" className="text-white/80 hover:text-secondary transition-colors">About Us</Link></li>
              <li><Link href="/services" className="text-white/80 hover:text-secondary transition-colors">Services</Link></li>
              <li><Link href="/products" className="text-white/80 hover:text-secondary transition-colors">Products</Link></li>
              <li><Link href="/portfolio" className="text-white/80 hover:text-secondary transition-colors">Portfolio</Link></li>
              <li><Link href="/blog" className="text-white/80 hover:text-secondary transition-colors">Blog</Link></li>
            </ul>
          </div>

          {/* Services */}
          <div>
            <h4 className="font-semibold mb-4">Our Services</h4>
            <ul className="space-y-2 text-sm">
              <li><Link href="/services/web-development" className="text-white/80 hover:text-secondary transition-colors">Web Development</Link></li>
              <li><Link href="/services/mobile-apps" className="text-white/80 hover:text-secondary transition-colors">Mobile Apps</Link></li>
              <li><Link href="/services/saas-solutions" className="text-white/80 hover:text-secondary transition-colors">SaaS Solutions</Link></li>
              <li><Link href="/services/system-integration" className="text-white/80 hover:text-secondary transition-colors">System Integration</Link></li>
              <li><Link href="/services/ai-solutions" className="text-white/80 hover:text-secondary transition-colors">AI Solutions</Link></li>
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h4 className="font-semibold mb-4">Contact Us</h4>
            <ul className="space-y-3 text-sm">
              <li className="flex items-start gap-2">
                <Mail className="h-5 w-5 text-secondary mt-0.5 flex-shrink-0" />
                <a href="mailto:techwareafrican@gmail.com" className="text-white/80 hover:text-secondary transition-colors">
                  techwareafrican@gmail.com
                </a>
              </li>
              <li className="flex items-start gap-2">
                <Phone className="h-5 w-5 text-secondary mt-0.5 flex-shrink-0" />
                <a href="tel:+255683274343" className="text-white/80 hover:text-secondary transition-colors">
                  +255 683 274 343
                </a>
              </li>
              <li className="flex items-start gap-2">
                <MapPin className="h-5 w-5 text-secondary mt-0.5 flex-shrink-0" />
                <span className="text-white/80">
                  Dar es Salaam, Tanzania<br />East Africa
                </span>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="mt-12 pt-8 border-t border-white/10">
          <div className="flex flex-col md:flex-row justify-between items-center gap-4 text-sm text-white/60">
            <p>&copy; {currentYear} Lwena TechWareAfrica. All rights reserved.</p>
            <div className="flex gap-6">
              <Link href="/privacy" className="hover:text-secondary transition-colors">Privacy Policy</Link>
              <Link href="/terms" className="hover:text-secondary transition-colors">Terms of Service</Link>
            </div>
          </div>
        </div>
      </div>
    </footer>
  )
}

import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { ArrowRight, Mail } from 'lucide-react'

export function CTASection() {
  return (
    <section className="py-20 bg-primary text-white relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute inset-0" style={{
          backgroundImage: 'radial-gradient(circle at 1px 1px, white 1px, transparent 0)',
          backgroundSize: '40px 40px'
        }} />
      </div>

      <div className="container relative mx-auto px-4">
        <div className="max-w-3xl mx-auto text-center">
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold font-heading mb-6">
            Ready to Transform Your Business?
          </h2>
          <p className="text-lg md:text-xl text-white/80 mb-8">
            Join thousands of businesses using our products. Start your free trial today 
            and experience world-class software solutions built in Africa.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-8">
            <Button variant="cta" size="lg" asChild>
              <Link href="/register">
                Start Free Trial <ArrowRight className="ml-2 h-5 w-5" />
              </Link>
            </Button>
            <Button 
              variant="outline" 
              size="lg" 
              className="border-white text-white hover:bg-white hover:text-primary"
              asChild
            >
              <Link href="mailto:lwenatech@gmail.com">
                <Mail className="mr-2 h-5 w-5" />
                Email Us
              </Link>
            </Button>
          </div>

          <p className="text-sm text-white/60">
            💬 Prefer to chat? <a href="https://wa.me/255623586879" target="_blank" rel="noopener noreferrer" className="text-secondary underline hover:no-underline">WhatsApp us</a> for instant response
          </p>
        </div>
      </div>
    </section>
  )
}

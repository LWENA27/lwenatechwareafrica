import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { ArrowRight, Code, Zap, Globe } from 'lucide-react'

export function Hero() {
  return (
    <section className="relative bg-primary text-white overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute inset-0" style={{
          backgroundImage: 'radial-gradient(circle at 1px 1px, white 1px, transparent 0)',
          backgroundSize: '40px 40px'
        }} />
      </div>

      <div className="container relative mx-auto px-4 py-20 lg:py-32">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <div className="space-y-8">
            <div className="space-y-4">
              <div className="inline-block">
                <span className="px-4 py-2 bg-secondary/10 text-secondary border border-secondary/20 rounded-full text-sm font-medium">
                  🚀 Made in Africa, Built for the World
                </span>
              </div>
              
              <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold font-heading leading-tight">
                World-Class Software Solutions from 
                <span className="text-secondary"> Africa</span>
              </h1>
              
              <p className="text-lg md:text-xl text-white/80 leading-relaxed">
                We deliver enterprise-grade SaaS platforms, mobile applications, and custom software 
                that drive business growth and digital transformation.
              </p>
            </div>

            {/* CTAs */}
            <div className="flex flex-col sm:flex-row gap-4">
              <Button variant="cta" size="lg" asChild>
                <Link href="/contact">
                  Get Started <ArrowRight className="ml-2 h-5 w-5" />
                </Link>
              </Button>
              <Button variant="outline" size="lg" asChild>
                <Link href="/products">View Our Products</Link>
              </Button>
            </div>

            {/* Trust Indicators */}
            <div className="grid grid-cols-3 gap-6 pt-8 border-t border-white/10">
              <div>
                <div className="text-3xl font-bold text-secondary">4+</div>
                <div className="text-sm text-white/70">Products Launched</div>
              </div>
              <div>
                <div className="text-3xl font-bold text-secondary">100%</div>
                <div className="text-sm text-white/70">Client Satisfaction</div>
              </div>
              <div>
                <div className="text-3xl font-bold text-secondary">24/7</div>
                <div className="text-sm text-white/70">Support Available</div>
              </div>
            </div>
          </div>

          {/* Right Content - Features Grid */}
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-white/5 backdrop-blur-sm border border-white/10 rounded-lg p-6 hover:bg-white/10 transition-all">
              <Code className="h-10 w-10 text-secondary mb-4" />
              <h3 className="font-semibold mb-2">Clean Code</h3>
              <p className="text-sm text-white/70">Enterprise-grade architecture and best practices</p>
            </div>
            <div className="bg-white/5 backdrop-blur-sm border border-white/10 rounded-lg p-6 hover:bg-white/10 transition-all mt-8">
              <Zap className="h-10 w-10 text-secondary mb-4" />
              <h3 className="font-semibold mb-2">Fast Delivery</h3>
              <p className="text-sm text-white/70">Agile development for rapid deployment</p>
            </div>
            <div className="bg-white/5 backdrop-blur-sm border border-white/10 rounded-lg p-6 hover:bg-white/10 transition-all">
              <Globe className="h-10 w-10 text-secondary mb-4" />
              <h3 className="font-semibold mb-2">Global Scale</h3>
              <p className="text-sm text-white/70">Built to scale for worldwide markets</p>
            </div>
            <div className="bg-white/5 backdrop-blur-sm border border-white/10 rounded-lg p-6 hover:bg-white/10 transition-all mt-8">
              <div className="h-10 w-10 text-secondary mb-4 text-3xl">💪</div>
              <h3 className="font-semibold mb-2">Reliable</h3>
              <p className="text-sm text-white/70">Robust systems you can depend on</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

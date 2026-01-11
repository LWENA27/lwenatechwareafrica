import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { ArrowRight } from 'lucide-react'

export function SupportTeam() {
  return (
    <section className="py-20 bg-gradient-to-br from-gray-50 to-white">
      <div className="container mx-auto px-4">
        <div className="max-w-6xl mx-auto">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            {/* Image */}
            <div className="relative">
              <div className="rounded-2xl overflow-hidden shadow-2xl">
                <img
                  src="/images/Brand&LandingPage/SupportTeam.png"
                  alt="Meet Our Support Team"
                  className="w-full h-auto object-cover"
                />
              </div>
            </div>

            {/* Content */}
            <div className="space-y-8">
              <div>
                <h2 className="text-4xl font-bold text-primary mb-4">
                  Meet Our Support Team
                </h2>
                <p className="text-xl text-muted leading-relaxed">
                  Our dedicated team of professionals is ready to help you succeed. Partner with us today and experience world-class support and expertise.
                </p>
              </div>

              {/* CTA */}
              <div>
                <Button variant="cta" size="lg" asChild>
                  <Link href="/team">
                    View Our Team <ArrowRight className="ml-2 h-5 w-5" />
                  </Link>
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

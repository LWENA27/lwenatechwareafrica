import { Metadata } from 'next'
import { Briefcase } from 'lucide-react'

export const metadata: Metadata = {
  title: 'Portfolio',
  description: 'Explore our portfolio of successful projects and client success stories.',
}

export default function PortfolioPage() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-[#232F3E] to-[#1a242e] text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto text-center">
            <Briefcase className="w-16 h-16 text-[#FF9900] mx-auto mb-6" />
            <h1 className="text-4xl md:text-5xl font-bold mb-6">
              Our Portfolio
            </h1>
            <p className="text-xl text-gray-300">
              Successful projects and satisfied clients across the globe
            </p>
          </div>
        </div>
      </section>

      {/* Content Section */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto text-center">
            <div className="bg-[#EAEDED] p-12 rounded-lg">
              <h2 className="text-2xl font-bold text-[#232F3E] mb-4">
                Portfolio Coming Soon
              </h2>
              <p className="text-gray-600 mb-8">
                We're currently curating our best work to showcase here. Check back soon to see our amazing projects and client success stories.
              </p>
              <div className="space-y-4 text-left max-w-2xl mx-auto">
                <div className="bg-white p-4 rounded-lg">
                  <h3 className="font-semibold text-[#232F3E] mb-2">What You'll Find Here:</h3>
                  <ul className="space-y-2 text-gray-600">
                    <li>• Case studies from real client projects</li>
                    <li>• Before and after transformations</li>
                    <li>• Client testimonials and results</li>
                    <li>• Technical challenges and solutions</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Products CTA */}
      <section className="py-20 bg-[#EAEDED]">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold text-[#232F3E] mb-4">
            In the Meantime, Check Out Our Products
          </h2>
          <p className="text-gray-600 mb-8">
            See what we've built and how it can help your business
          </p>
          <a
            href="/products/inventorymaster"
            className="inline-block bg-[#FF9900] text-white px-8 py-4 rounded-lg font-semibold hover:bg-[#e68a00] transition-colors"
          >
            View Our Products
          </a>
        </div>
      </section>
    </div>
  )
}

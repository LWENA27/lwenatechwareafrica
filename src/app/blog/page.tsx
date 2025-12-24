import { Metadata } from 'next'
import { BookOpen } from 'lucide-react'

export const metadata: Metadata = {
  title: 'Blog',
  description: 'Insights, tutorials, and updates from the Lwena TechWareAfrica team.',
}

export default function BlogPage() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-[#232F3E] to-[#1a242e] text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto text-center">
            <BookOpen className="w-16 h-16 text-[#FF9900] mx-auto mb-6" />
            <h1 className="text-4xl md:text-5xl font-bold mb-6">
              Blog & Insights
            </h1>
            <p className="text-xl text-gray-300">
              Technical insights, industry trends, and company updates
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
                Blog Coming Soon
              </h2>
              <p className="text-gray-600 mb-8">
                We're preparing valuable content for you. Soon you'll find technical tutorials, industry insights, and behind-the-scenes looks at our projects.
              </p>
              <div className="space-y-4 text-left max-w-2xl mx-auto">
                <div className="bg-white p-4 rounded-lg">
                  <h3 className="font-semibold text-[#232F3E] mb-2">Upcoming Topics:</h3>
                  <ul className="space-y-2 text-gray-600">
                    <li>• Building scalable web applications</li>
                    <li>• Best practices in software development</li>
                    <li>• Cloud migration strategies</li>
                    <li>• Tech innovation in Africa</li>
                    <li>• Product updates and releases</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Newsletter Signup */}
      <section className="py-20 bg-gradient-to-r from-[#232F3E] to-[#FF9900] text-white">
        <div className="container mx-auto px-4">
          <div className="max-w-2xl mx-auto text-center">
            <h2 className="text-3xl font-bold mb-4">Stay Updated</h2>
            <p className="text-xl mb-8 text-gray-200">
              Subscribe to get notified when we publish new content
            </p>
            <form className="flex flex-col sm:flex-row gap-4 max-w-md mx-auto">
              <input
                type="email"
                placeholder="Enter your email"
                className="flex-1 px-4 py-3 rounded-lg text-gray-900 outline-none"
                required
              />
              <button
                type="submit"
                className="bg-white text-[#232F3E] px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors"
              >
                Subscribe
              </button>
            </form>
          </div>
        </div>
      </section>
    </div>
  )
}

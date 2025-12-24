import { Metadata } from 'next'
import Link from 'next/link'
import { Package, ArrowRight, CheckCircle2 } from 'lucide-react'

export const metadata: Metadata = {
  title: 'Products',
  description: 'Explore our suite of production-ready software solutions designed for modern businesses.',
}

export default function ProductsPage() {
  const products = [
    {
      name: 'InventoryMaster',
      slug: 'inventorymaster',
      tagline: 'Complete Inventory Management Solution',
      description: 'A comprehensive inventory management system that streamlines stock control, orders, and reporting for businesses of all sizes.',
      status: 'Production Ready',
      gradient: 'from-blue-500 to-cyan-500',
      features: [
        'Real-time inventory tracking',
        'Automated reorder points',
        'Multi-location support',
        'Advanced reporting & analytics',
        'Barcode scanning',
        'Supplier management',
      ],
    },
    {
      name: 'SmartMenu QR',
      slug: 'smartmenu-qr',
      tagline: 'Digital Menu Solution for Restaurants',
      description: 'Transform your restaurant with contactless QR code menus. Easy to update, multilingual support, and stunning presentation.',
      status: 'Production Ready',
      gradient: 'from-green-500 to-emerald-500',
      features: [
        'QR code generation',
        'Real-time menu updates',
        'Multilingual support',
        'Rich media (images/videos)',
        'Order tracking integration',
        'Analytics dashboard',
      ],
    },
    {
      name: 'Weather Admin',
      slug: 'weatheradmin',
      tagline: 'Weather Data Management System',
      description: 'Professional weather station data management with real-time monitoring, forecasting, and comprehensive reporting capabilities.',
      status: 'Production Ready',
      gradient: 'from-purple-500 to-pink-500',
      features: [
        'Real-time data collection',
        'Historical data analysis',
        'Weather forecasting',
        'Alert system',
        'API integration',
        'Custom reporting',
      ],
    },
    {
      name: 'SMS Gateway Pro',
      slug: 'sms-gateway-pro',
      tagline: 'Enterprise SMS & Communication Platform',
      description: 'Reliable bulk SMS gateway with advanced features for marketing campaigns, notifications, and two-way messaging.',
      status: 'Production Ready',
      gradient: 'from-orange-500 to-red-500',
      features: [
        'Bulk SMS sending',
        'Two-way messaging',
        'Campaign management',
        'Delivery reports',
        'API access',
        'Contact management',
      ],
    },
  ]

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-[#232F3E] to-[#1a242e] text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto text-center">
            <Package className="w-16 h-16 text-[#FF9900] mx-auto mb-6" />
            <h1 className="text-4xl md:text-5xl font-bold mb-6">
              Our Products
            </h1>
            <p className="text-xl text-gray-300">
              Production-ready software solutions designed to solve real business challenges
            </p>
          </div>
        </div>
      </section>

      {/* Products Grid */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-4">
          <div className="space-y-16 max-w-7xl mx-auto">
            {products.map((product, index) => (
              <div
                key={product.slug}
                className={`grid lg:grid-cols-2 gap-12 items-center ${
                  index % 2 === 1 ? 'lg:grid-flow-dense' : ''
                }`}
              >
                {/* Product Visual */}
                <div className={index % 2 === 1 ? 'lg:col-start-2' : ''}>
                  <div
                    className={`relative bg-gradient-to-br ${product.gradient} rounded-2xl p-8 aspect-video flex items-center justify-center overflow-hidden shadow-xl`}
                  >
                    {/* Decorative elements */}
                    <div className="absolute inset-0 opacity-20">
                      <div className="absolute top-0 right-0 w-40 h-40 bg-white rounded-full -translate-y-20 translate-x-20"></div>
                      <div className="absolute bottom-0 left-0 w-32 h-32 bg-white rounded-full translate-y-16 -translate-x-16"></div>
                    </div>
                    
                    {/* Product icon/logo area */}
                    <div className="relative z-10 text-white text-center">
                      <Package className="w-24 h-24 mx-auto mb-4" />
                      <h3 className="text-3xl font-bold">{product.name}</h3>
                    </div>
                  </div>
                </div>

                {/* Product Details */}
                <div className={`space-y-6 ${index % 2 === 1 ? 'lg:col-start-1 lg:row-start-1' : ''}`}>
                  <div>
                    <span className="inline-block px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm font-medium mb-4">
                      {product.status}
                    </span>
                    <h2 className="text-3xl font-bold text-[#232F3E] mb-2">
                      {product.name}
                    </h2>
                    <p className="text-lg text-[#FF9900] font-semibold mb-4">
                      {product.tagline}
                    </p>
                    <p className="text-gray-600 leading-relaxed">
                      {product.description}
                    </p>
                  </div>

                  <div>
                    <h3 className="font-semibold text-[#232F3E] mb-3">Key Features:</h3>
                    <ul className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                      {product.features.map((feature, idx) => (
                        <li key={idx} className="flex items-start">
                          <CheckCircle2 className="w-5 h-5 text-[#FF9900] mr-2 flex-shrink-0 mt-0.5" />
                          <span className="text-gray-600 text-sm">{feature}</span>
                        </li>
                      ))}
                    </ul>
                  </div>

                  <div className="flex flex-wrap gap-4">
                    <Link
                      href={`/products/${product.slug}`}
                      className="inline-flex items-center bg-[#FF9900] text-white px-6 py-3 rounded-lg font-semibold hover:bg-[#e68a00] transition-colors"
                    >
                      Learn More <ArrowRight className="ml-2 h-5 w-5" />
                    </Link>
                    <Link
                      href="/contact"
                      className="inline-flex items-center border-2 border-[#232F3E] text-[#232F3E] px-6 py-3 rounded-lg font-semibold hover:bg-[#232F3E] hover:text-white transition-colors"
                    >
                      Request Demo
                    </Link>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-r from-[#232F3E] to-[#FF9900] text-white">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold mb-4">Need a Custom Solution?</h2>
          <p className="text-xl mb-8 text-gray-200">
            We also offer bespoke software development tailored to your specific needs
          </p>
          <Link
            href="/contact"
            className="inline-block bg-white text-[#232F3E] px-8 py-4 rounded-lg font-semibold hover:bg-gray-100 transition-colors"
          >
            Discuss Your Project
          </Link>
        </div>
      </section>
    </div>
  )
}

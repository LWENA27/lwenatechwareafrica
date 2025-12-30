"use client"

import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { ArrowRight, Package, QrCode, Cloud as CloudIcon, MessageSquare } from 'lucide-react'
import React, { useEffect, useRef, useState } from 'react'

export function ProductsShowcase() {
  const products = [
    // {
    //   icon: Package,
    //   name: 'InventoryMaster SaaS',
    //   tagline: 'Multi-Platform Inventory Management',
    //   description: 'Complete inventory management system with multi-tenant architecture, supporting Web, Android, Windows, macOS, and Linux.',
    //   features: ['Multi-tenant SaaS', 'Real-time sync', 'Product catalog with images', 'Cross-platform'],
    //   link: '/products/inventorymaster',
    //   status: 'Production Ready',
    //   color: 'from-blue-500 to-blue-600'
    // },
    // {
    //   icon: QrCode,
    //   name: 'SmartMenu QR',
    //   tagline: 'QR-Based Restaurant Ordering',
    //   description: 'Smart menu food ordering system for restaurants and hotels. Customers scan QR codes to view menus and place orders.',
    //   features: ['QR code menus', 'Order management', 'Kitchen dashboard', 'No app required'],
    //   link: '/products/smartmenu-qr',
    //   status: 'Production Ready',
    //   color: 'from-green-500 to-green-600'
    // },
    // {
    //   icon: CloudIcon,
    //   name: 'Weather Admin App',
    //   tagline: 'SMS Weather Information Platform',
    //   description: 'Android platform providing real-time weather information via SMS in Swahili with AI assistant integration.',
    //   features: ['SMS-based queries', 'AI assistant', 'Weather forecasts', 'Agricultural advice'],
    //   link: '/products/weatheradmin',
    //   status: 'Production Ready',
    //   color: 'from-purple-500 to-purple-600'
    // },
    {
      icon: MessageSquare,
      name: 'SMS Gateway Pro',
      tagline: 'Professional Bulk SMS System',
      description: 'Multi-tenant bulk SMS management with native Android sending, contact management, and group messaging.',
      features: ['Bulk messaging', 'Multi-tenant', 'Native SMS', 'API integration'],
      link: '/products/sms-gateway-pro',
      status: 'Production Ready',
      color: 'from-orange-500 to-orange-600'
    }
  ]

  const scrollRef = useRef<HTMLDivElement | null>(null)
  const [isPaused, setIsPaused] = useState(false)

  useEffect(() => {
    const container = scrollRef.current
    if (!container) return

    const intervalMs = 3500
    let timer: ReturnType<typeof setInterval> | null = null

    const doScroll = () => {
      if (!container) return
      const clientWidth = container.clientWidth
      const maxScroll = container.scrollWidth - clientWidth

      // Determine next scroll position (page-wise)
      const currentPage = Math.round(container.scrollLeft / clientWidth)
      let nextPage = currentPage + 1
      let nextScroll = nextPage * clientWidth
      if (nextScroll > maxScroll) {
        nextScroll = 0
      }
      container.scrollTo({ left: nextScroll, behavior: 'smooth' })
    }

    if (!isPaused) {
      timer = setInterval(doScroll, intervalMs)
    }

    return () => {
      if (timer) clearInterval(timer)
    }
  }, [isPaused])

  return (
    <section className="py-20 bg-white">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold font-heading text-primary mb-4">
            Ready-to-Deploy Products
          </h2>
          <p className="text-lg text-muted max-w-2xl mx-auto">
            Battle-tested SaaS solutions that are ready to generate revenue. 
            License our products or get custom development.
          </p>
        </div>

        {/* Horizontal auto-sliding carousel */}
        <div className="relative">
          <div className="overflow-hidden">
            <div
              ref={scrollRef}
              onMouseEnter={() => setIsPaused(true)}
              onMouseLeave={() => setIsPaused(false)}
              className="product-scroll-container flex gap-8 overflow-x-auto scroll-smooth snap-x snap-mandatory py-4"
              style={{ WebkitOverflowScrolling: 'touch' }}
            >
              {products.map((product, index) => (
                <div
                  key={index}
                  className="snap-start flex-shrink-0 w-full sm:w-1/2 md:w-1/3 lg:w-1/4"
                >
                  <div className="group relative bg-white rounded-xl border border-border hover:border-secondary shadow-sm hover:shadow-xl transition-all overflow-hidden">
                    <div className="absolute top-4 right-4 z-10">
                      <span className="px-3 py-1 bg-green-100 text-green-700 text-xs font-semibold rounded-full">
                        {product.status}
                      </span>
                    </div>

                    <div className={`h-24 bg-gradient-to-r ${product.color} opacity-10 group-hover:opacity-20 transition-opacity`} />

                    <div className="p-8 -mt-12">
                      <div className={`inline-flex p-4 bg-white rounded-lg shadow-md mb-4 border-2 border-white group-hover:border-secondary transition-colors`}>
                        <product.icon className="h-8 w-8 text-secondary" />
                      </div>

                      <h3 className="text-2xl font-bold text-primary mb-2">{product.name}</h3>
                      <p className="text-secondary font-medium mb-3">{product.tagline}</p>
                      <p className="text-muted mb-6">{product.description}</p>

                      <div className="grid grid-cols-2 gap-2 mb-6">
                        {product.features.map((feature, idx) => (
                          <div key={idx} className="flex items-center gap-2 text-sm">
                            <div className="h-1.5 w-1.5 rounded-full bg-secondary" />
                            <span className="text-muted">{feature}</span>
                          </div>
                        ))}
                      </div>

                      <Link
                        href={product.link}
                        className="inline-flex items-center text-secondary font-semibold hover:gap-2 transition-all"
                      >
                        View Details <ArrowRight className="ml-1 h-4 w-4" />
                      </Link>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Auto-scroll behavior */}

        <div className="text-center mt-12">
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button variant="cta" size="lg" asChild>
              <Link href="/products">Explore All Products</Link>
            </Button>
            <Button variant="outline" size="lg" asChild>
              <Link href="/contact">Get Custom Development</Link>
            </Button>
          </div>
        </div>
      </div>
    </section>
  )
}

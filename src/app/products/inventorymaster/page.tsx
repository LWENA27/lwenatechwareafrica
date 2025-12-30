import { Metadata } from 'next'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { ArrowLeft, CheckCircle2, Download, Globe, Smartphone, Monitor } from 'lucide-react'

export const metadata: Metadata = {
  title: 'InventoryMaster SaaS - Multi-Platform Inventory Management',
  description: 'Comprehensive multi-tenant inventory management system built with Flutter and Supabase. Supports Web, Android, Windows, macOS, and Linux.',
}

export default function InventoryMasterPage() {
  const features = [
    'Multi-tenant Architecture - Support multiple businesses',
    'Product Management - Complete catalog with up to 5 images per product',
    'Inventory Tracking - Real-time stock levels and alerts',
    'Sales Management - Track sales with foreign key constraints',
    'User Authentication - Secure login with role-based access',
    'Real-time Sync - Cross-platform data synchronization',
    'Image Management - Supabase Storage integration',
    'Export Capabilities - Generate reports and export data',
    'Offline Support - View products when offline'
  ]

  const platforms = [
    { name: 'Web Application', icon: Globe, description: 'PWA with offline capabilities' },
    { name: 'Android Mobile', icon: Smartphone, description: 'Native Android 5.0+ support' },
    { name: 'Windows Desktop', icon: Monitor, description: 'Native Windows 10/11 app' },
    { name: 'macOS Desktop', icon: Monitor, description: 'Native macOS 10.14+ app' },
    { name: 'Linux Desktop', icon: Monitor, description: 'Ubuntu 18.04+ compatible' }
  ]

  const techStack = [
    { category: 'Frontend', tech: 'Flutter, Dart' },
    { category: 'Backend', tech: 'Supabase (PostgreSQL)' },
    { category: 'Authentication', tech: 'Supabase Auth' },
    { category: 'Storage', tech: 'Supabase Storage' },
    { category: 'Real-time', tech: 'Supabase Realtime' }
  ]

  return (
    <div className="min-h-screen bg-white">
      {/* Hero Section */}
      <section className="bg-primary text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl">
            <Link href="/products" className="inline-flex items-center text-secondary hover:text-secondary/80 mb-6">
              <ArrowLeft className="mr-2 h-4 w-4" />
              Back to Products
            </Link>
            
            <div className="inline-block px-4 py-2 bg-green-500/20 text-green-300 rounded-full text-sm font-semibold mb-6">
              ✅ Production Ready
            </div>

            <h1 className="text-4xl md:text-5xl font-bold font-heading mb-6">
              InventoryMaster SaaS
            </h1>
            
            <p className="text-xl text-white/80 mb-8">
              A comprehensive multi-tenant inventory management system built with Flutter and Supabase, 
              supporting Web, Android, Windows, macOS, and Linux platforms.
            </p>

            <div className="flex flex-wrap gap-4">
              <Button variant="cta" size="lg" asChild>
                <a href="https://inventorymaster-saas.netlify.app" target="_blank" rel="noopener noreferrer">
                  <Globe className="mr-2 h-5 w-5" />
                  Try Live Demo
                </a>
              </Button>
              <Button variant="outline" size="lg" className="border-white text-white hover:bg-white hover:text-primary" asChild>
                <Link href="/contact">Get Custom Version</Link>
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-6xl mx-auto">
            <h2 className="text-3xl font-bold font-heading text-primary mb-12 text-center">
              Comprehensive Features
            </h2>
            
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {features.map((feature, index) => (
                <div key={index} className="flex items-start gap-3">
                  <CheckCircle2 className="h-6 w-6 text-secondary flex-shrink-0 mt-1" />
                  <span className="text-muted">{feature}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Platforms Section */}
      <section className="py-20 bg-background">
        <div className="container mx-auto px-4">
          <div className="max-w-6xl mx-auto">
            <h2 className="text-3xl font-bold font-heading text-primary mb-12 text-center">
              Multi-Platform Support
            </h2>
            
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {platforms.map((platform, index) => (
                <div key={index} className="bg-white p-6 rounded-lg border border-border hover:border-secondary hover:shadow-lg transition-all">
                  <platform.icon className="h-10 w-10 text-secondary mb-4" />
                  <h3 className="text-xl font-semibold text-primary mb-2">{platform.name}</h3>
                  <p className="text-muted">{platform.description}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Tech Stack Section */}
      <section className="py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl font-bold font-heading text-primary mb-12 text-center">
              Technology Stack
            </h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              {techStack.map((item, index) => (
                <div key={index} className="flex items-center gap-4 p-6 bg-background rounded-lg">
                  <div className="font-semibold text-primary min-w-[120px]">{item.category}:</div>
                  <div className="text-muted">{item.tech}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Use Cases Section */}
      <section className="py-20 bg-background">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <h2 className="text-3xl font-bold font-heading text-primary mb-12 text-center">
              Perfect For
            </h2>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div className="bg-white p-6 rounded-lg border border-border">
                <h3 className="text-xl font-semibold text-primary mb-3">Retail Businesses</h3>
                <p className="text-muted">Track inventory across multiple stores with real-time updates</p>
              </div>
              <div className="bg-white p-6 rounded-lg border border-border">
                <h3 className="text-xl font-semibold text-primary mb-3">Warehouses</h3>
                <p className="text-muted">Manage stock levels, track movements, and prevent stockouts</p>
              </div>
              <div className="bg-white p-6 rounded-lg border border-border">
                <h3 className="text-xl font-semibold text-primary mb-3">E-commerce</h3>
                <p className="text-muted">Sync online and offline inventory seamlessly</p>
              </div>
              <div className="bg-white p-6 rounded-lg border border-border">
                <h3 className="text-xl font-semibold text-primary mb-3">Small Businesses</h3>
                <p className="text-muted">Affordable, easy-to-use inventory management solution</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-primary text-white">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl mx-auto text-center">
            <h2 className="text-3xl md:text-4xl font-bold font-heading mb-6">
              Ready to Streamline Your Inventory?
            </h2>
            <p className="text-lg text-white/80 mb-8">
              Start using InventoryMaster today with our free trial. No credit card required.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button variant="cta" size="lg" asChild>
                <Link href="/register">Start Free Trial</Link>
              </Button>
              <Button variant="outline" size="lg" className="border-white text-white hover:bg-white hover:text-primary" asChild>
                <a href="https://github.com/LWENA27/Mem_technology" target="_blank" rel="noopener noreferrer">
                  View on GitHub
                </a>
              </Button>
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}

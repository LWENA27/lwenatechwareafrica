import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Code, Smartphone, Cloud, Database, Cpu, Link as LinkIcon } from 'lucide-react'

export function ServicesOverview() {
  const services = [
    {
      icon: Code,
      title: 'Web Application Development',
      description: 'Full-stack web applications built with modern frameworks like Next.js, React, and Node.js.',
      link: '/services/web-development'
    },
    {
      icon: Smartphone,
      title: 'Mobile App Development',
      description: 'Native and cross-platform mobile apps for iOS and Android using Flutter and React Native.',
      link: '/services/mobile-apps'
    },
    {
      icon: Cloud,
      title: 'SaaS Solutions',
      description: 'Multi-tenant SaaS platforms with subscription management, billing, and analytics.',
      link: '/services/saas-solutions'
    },
    {
      icon: Database,
      title: 'Inventory & Management Systems',
      description: 'Custom ERP, inventory, and business management systems tailored to your needs.',
      link: '/services/management-systems'
    },
    {
      icon: Cpu,
      title: 'AI & Data Solutions',
      description: 'Machine learning, data analytics, and AI-powered features for intelligent applications.',
      link: '/services/ai-solutions'
    },
    {
      icon: LinkIcon,
      title: 'System Integration',
      description: 'Seamlessly connect your existing systems with APIs, webhooks, and microservices.',
      link: '/services/system-integration'
    }
  ]

  return (
    <section className="py-20 bg-background">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold font-heading text-primary mb-4">
            Our Services
          </h2>
          <p className="text-lg text-muted max-w-2xl mx-auto">
            Comprehensive software development services to transform your business ideas into reality
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {services.map((service, index) => (
            <Link 
              key={index}
              href={service.link}
              className="group block p-8 bg-white rounded-lg border border-border hover:border-secondary hover:shadow-xl transition-all"
            >
              <div className="mb-4">
                <service.icon className="h-12 w-12 text-secondary" />
              </div>
              <h3 className="text-xl font-semibold text-primary mb-3 group-hover:text-secondary transition-colors">
                {service.title}
              </h3>
              <p className="text-muted mb-4">{service.description}</p>
              <span className="text-secondary font-medium inline-flex items-center group-hover:gap-2 transition-all">
                Learn More 
                <span className="ml-1 group-hover:ml-2 transition-all">→</span>
              </span>
            </Link>
          ))}
        </div>

        <div className="text-center mt-12">
          <Button variant="cta" size="lg" asChild>
            <Link href="/services">View All Services</Link>
          </Button>
        </div>
      </div>
    </section>
  )
}

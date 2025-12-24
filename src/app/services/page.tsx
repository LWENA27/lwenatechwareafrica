import { Metadata } from 'next'
import { Code, Cloud, Smartphone, Database, Shield, Zap } from 'lucide-react'

export const metadata: Metadata = {
  title: 'Services',
  description: 'Comprehensive software development and technology services from Lwena TechWareAfrica.',
}

export default function ServicesPage() {
  const services = [
    {
      icon: Code,
      title: 'Custom Software Development',
      description: 'Tailored software solutions built to your exact specifications. From web applications to enterprise systems, we bring your vision to life.',
      features: ['Full-stack development', 'Agile methodology', 'Scalable architecture', 'Clean, maintainable code'],
    },
    {
      icon: Cloud,
      title: 'Cloud Solutions',
      description: 'Cloud-native applications and migration services. We help you leverage the power of cloud computing for maximum efficiency.',
      features: ['AWS/Azure/GCP', 'Cloud migration', 'Serverless architecture', 'DevOps & CI/CD'],
    },
    {
      icon: Smartphone,
      title: 'Mobile App Development',
      description: 'Native and cross-platform mobile applications that deliver exceptional user experiences on iOS and Android.',
      features: ['React Native', 'Flutter', 'Native iOS/Android', 'App Store deployment'],
    },
    {
      icon: Database,
      title: 'Database Design & Optimization',
      description: 'Robust database architecture and performance optimization to ensure your data is secure, accessible, and lightning-fast.',
      features: ['SQL/NoSQL databases', 'Performance tuning', 'Data migration', 'Backup & recovery'],
    },
    {
      icon: Shield,
      title: 'Security & Compliance',
      description: 'Enterprise-grade security implementation and compliance consulting to protect your business and customer data.',
      features: ['Security audits', 'GDPR compliance', 'Penetration testing', 'Encryption implementation'],
    },
    {
      icon: Zap,
      title: 'API Development & Integration',
      description: 'RESTful and GraphQL APIs, third-party integrations, and microservices architecture for seamless system connectivity.',
      features: ['REST/GraphQL APIs', 'Third-party integrations', 'Microservices', 'API documentation'],
    },
  ]

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-[#232F3E] to-[#1a242e] text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto text-center">
            <h1 className="text-4xl md:text-5xl font-bold mb-6">
              Our Services
            </h1>
            <p className="text-xl text-gray-300">
              Comprehensive software development and technology solutions to power your business
            </p>
          </div>
        </div>
      </section>

      {/* Services Grid */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8 max-w-7xl mx-auto">
            {services.map((service, index) => {
              const Icon = service.icon
              return (
                <div key={index} className="bg-white border border-gray-200 rounded-lg p-8 hover:shadow-lg transition-shadow">
                  <div className="w-16 h-16 bg-[#FF9900] rounded-lg flex items-center justify-center mb-6">
                    <Icon className="w-8 h-8 text-white" />
                  </div>
                  <h3 className="text-2xl font-bold text-[#232F3E] mb-4">{service.title}</h3>
                  <p className="text-gray-600 mb-6">{service.description}</p>
                  <ul className="space-y-2">
                    {service.features.map((feature, idx) => (
                      <li key={idx} className="flex items-center text-sm text-gray-600">
                        <span className="w-1.5 h-1.5 bg-[#FF9900] rounded-full mr-2"></span>
                        {feature}
                      </li>
                    ))}
                  </ul>
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-r from-[#232F3E] to-[#FF9900] text-white">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold mb-4">Ready to Start Your Project?</h2>
          <p className="text-xl mb-8 text-gray-200">
            Let's discuss how we can help you achieve your goals
          </p>
          <a
            href="/contact"
            className="inline-block bg-white text-[#232F3E] px-8 py-4 rounded-lg font-semibold hover:bg-gray-100 transition-colors"
          >
            Get in Touch
          </a>
        </div>
      </section>
    </div>
  )
}

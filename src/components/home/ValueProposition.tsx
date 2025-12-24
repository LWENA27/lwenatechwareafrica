import { Shield, Rocket, Users, Award } from 'lucide-react'

export function ValueProposition() {
  const values = [
    {
      icon: Shield,
      title: 'Enterprise-Grade Quality',
      description: 'Production-ready code with security, scalability, and performance built-in from day one.'
    },
    {
      icon: Rocket,
      title: 'Ready-to-Deploy Products',
      description: 'Our SaaS solutions are battle-tested and ready to generate revenue immediately.'
    },
    {
      icon: Users,
      title: 'Client-Focused Approach',
      description: 'We partner with you to understand your business and deliver solutions that drive growth.'
    },
    {
      icon: Award,
      title: 'African Excellence',
      description: 'Proudly building world-class software from Africa, competing on the global stage.'
    }
  ]

  return (
    <section className="py-20 bg-white">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold font-heading text-primary mb-4">
            Why Choose Lwena TechWareAfrica?
          </h2>
          <p className="text-lg text-muted max-w-2xl mx-auto">
            We don't just write code — we build businesses. Our solutions are designed to solve 
            real problems and create lasting value.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {values.map((value, index) => (
            <div 
              key={index}
              className="group p-6 rounded-lg border border-border hover:border-secondary hover:shadow-lg transition-all"
            >
              <div className="mb-4">
                <div className="inline-flex p-3 bg-secondary/10 rounded-lg group-hover:bg-secondary/20 transition-colors">
                  <value.icon className="h-8 w-8 text-secondary" />
                </div>
              </div>
              <h3 className="text-xl font-semibold text-primary mb-2">{value.title}</h3>
              <p className="text-muted">{value.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

import { Metadata } from 'next'
import { Building2, Users, Target, Zap } from 'lucide-react'

export const metadata: Metadata = {
  title: 'About Us',
  description: 'Learn about Lwena TechWareAfrica - World-class software solutions built in Africa for the global market.',
}

export default function AboutPage() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-[#232F3E] to-[#1a242e] text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto text-center">
            <h1 className="text-4xl md:text-5xl font-bold mb-6">
              About Lwena TechWareAfrica
            </h1>
            <p className="text-xl text-gray-300">
              We are a world-class software company built in Africa, delivering enterprise-grade solutions to clients worldwide.
            </p>
          </div>
        </div>
      </section>

      {/* Mission & Vision */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-2 gap-12 max-w-6xl mx-auto">
            <div className="space-y-4">
              <div className="w-16 h-16 bg-[#FF9900] rounded-lg flex items-center justify-center mb-4">
                <Target className="w-8 h-8 text-white" />
              </div>
              <h2 className="text-3xl font-bold text-[#232F3E]">Our Mission</h2>
              <p className="text-gray-600 leading-relaxed">
                To deliver world-class, production-ready software solutions that empower businesses globally. 
                We combine African innovation with international standards to create products that solve real-world problems.
              </p>
            </div>
            
            <div className="space-y-4">
              <div className="w-16 h-16 bg-[#FF9900] rounded-lg flex items-center justify-center mb-4">
                <Zap className="w-8 h-8 text-white" />
              </div>
              <h2 className="text-3xl font-bold text-[#232F3E]">Our Vision</h2>
              <p className="text-gray-600 leading-relaxed">
                To be recognized as a leading global software company that showcases Africa's technical excellence. 
                We aim to bridge the gap between African talent and international opportunities.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Our Story */}
      <section className="py-20 bg-[#EAEDED]">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <div className="text-center mb-12">
              <Building2 className="w-16 h-16 text-[#FF9900] mx-auto mb-4" />
              <h2 className="text-3xl font-bold text-[#232F3E] mb-4">Our Story</h2>
            </div>
            
            <div className="bg-white p-8 rounded-lg shadow-sm space-y-6 text-gray-600 leading-relaxed">
              <p>
                Lwena TechWareAfrica was founded with a simple yet powerful vision: to prove that world-class 
                software can be built anywhere, including right here in Africa.
              </p>
              
              <p>
                We started by identifying real business challenges that needed elegant, scalable solutions. 
                Each of our products - from InventoryMaster to Weather Admin - was born from actual market 
                needs and refined through real-world usage.
              </p>
              
              <p>
                Today, we serve clients across multiple continents, providing enterprise-grade software solutions 
                that compete with the best in the industry. Our commitment to quality, reliability, and customer 
                satisfaction has made us a trusted partner for businesses worldwide.
              </p>
              
              <p>
                We're not just building software - we're building a legacy of African excellence in technology.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Core Values */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-[#232F3E] mb-4">Our Core Values</h2>
            <p className="text-gray-600 max-w-2xl mx-auto">
              These principles guide everything we do
            </p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
            {[
              {
                title: 'Excellence',
                description: 'We deliver nothing but the highest quality in everything we build.',
              },
              {
                title: 'Innovation',
                description: 'We constantly push boundaries to create cutting-edge solutions.',
              },
              {
                title: 'Reliability',
                description: '24/7 support and 99.9% uptime - our clients can count on us.',
              },
              {
                title: 'Transparency',
                description: 'Clear communication and honest partnerships with every client.',
              },
              {
                title: 'Scalability',
                description: 'Solutions built to grow with your business needs.',
              },
              {
                title: 'Global Standards',
                description: 'International quality from an African powerhouse.',
              },
            ].map((value, index) => (
              <div key={index} className="bg-[#EAEDED] p-6 rounded-lg">
                <h3 className="text-xl font-bold text-[#232F3E] mb-3">{value.title}</h3>
                <p className="text-gray-600">{value.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section className="py-20 bg-[#EAEDED]">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <Users className="w-16 h-16 text-[#FF9900] mx-auto mb-4" />
            <h2 className="text-3xl font-bold text-[#232F3E] mb-4">Our Team</h2>
            <p className="text-gray-600 max-w-2xl mx-auto">
              A diverse group of talented professionals committed to delivering excellence
            </p>
          </div>
          
          <div className="bg-white p-8 rounded-lg shadow-sm max-w-4xl mx-auto text-center">
            <p className="text-gray-600 leading-relaxed mb-6">
              Our team consists of experienced software engineers, designers, project managers, and support specialists 
              who work together to bring your vision to life. With expertise spanning multiple technologies and industries, 
              we're equipped to handle projects of any scale.
            </p>
            <p className="text-lg font-semibold text-[#232F3E]">
              Collective Experience: 50+ years in software development
            </p>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-r from-[#232F3E] to-[#FF9900] text-white">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold mb-4">Ready to Work With Us?</h2>
          <p className="text-xl mb-8 text-gray-200">
            Let's build something amazing together
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

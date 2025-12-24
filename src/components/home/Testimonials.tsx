import { Star } from 'lucide-react'

export function Testimonials() {
  const testimonials = [
    {
      name: 'John Mwamba',
      role: 'CEO, RetailCo Tanzania',
      content: 'InventoryMaster transformed our business operations. The multi-platform support means our team can work from anywhere.',
      rating: 5,
      image: '👨‍💼'
    },
    {
      name: 'Sarah Kimario',
      role: 'Restaurant Owner',
      content: 'SmartMenu QR revolutionized how we take orders. Our customers love the contactless experience and our efficiency improved dramatically.',
      rating: 5,
      image: '👩‍💼'
    },
    {
      name: 'David Mollel',
      role: 'Marketing Director',
      content: 'SMS Gateway Pro helped us reach thousands of customers instantly. The bulk messaging feature is incredibly reliable and easy to use.',
      rating: 5,
      image: '👨‍💻'
    }
  ]

  return (
    <section className="py-20 bg-background">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold font-heading text-primary mb-4">
            What Our Clients Say
          </h2>
          <p className="text-lg text-muted max-w-2xl mx-auto">
            Don't just take our word for it — hear from businesses we've helped transform
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <div 
              key={index}
              className="bg-white p-8 rounded-lg border border-border hover:border-secondary hover:shadow-lg transition-all"
            >
              {/* Rating */}
              <div className="flex gap-1 mb-4">
                {[...Array(testimonial.rating)].map((_, i) => (
                  <Star key={i} className="h-5 w-5 fill-secondary text-secondary" />
                ))}
              </div>

              {/* Content */}
              <p className="text-muted mb-6 italic">
                "{testimonial.content}"
              </p>

              {/* Author */}
              <div className="flex items-center gap-3 pt-4 border-t border-border">
                <div className="text-4xl">{testimonial.image}</div>
                <div>
                  <div className="font-semibold text-primary">{testimonial.name}</div>
                  <div className="text-sm text-muted">{testimonial.role}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

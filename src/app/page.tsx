import { Hero } from '@/components/home/Hero'
import { ValueProposition } from '@/components/home/ValueProposition'
import { ServicesOverview } from '@/components/home/ServicesOverview'
import { ProductsShowcase } from '@/components/home/ProductsShowcase'
import { Testimonials } from '@/components/home/Testimonials'
import { SupportTeam } from '@/components/home/SupportTeam'
import { CTASection } from '@/components/home/CTASection'

export default function HomePage() {
  return (
    <>
      <Hero />
      <ValueProposition />
      <ServicesOverview />
      <ProductsShowcase />
      <Testimonials />
      <SupportTeam />
      <CTASection />
    </>
  )
}

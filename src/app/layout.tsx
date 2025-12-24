import './globals.css'
import type { Metadata } from 'next'
import { Inter, Poppins } from 'next/font/google'
import { Header } from '@/components/layout/Header'
import { Footer } from '@/components/layout/Footer'

const inter = Inter({ 
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
})

const poppins = Poppins({ 
  weight: ['400', '500', '600', '700'],
  subsets: ['latin'],
  variable: '--font-poppins',
  display: 'swap',
})

export const metadata: Metadata = {
  title: {
    default: 'Lwena TechWareAfrica | World-Class Software Solutions from Africa',
    template: '%s | Lwena TechWareAfrica'
  },
  description: 'Professional software development company delivering world-class SaaS solutions, mobile apps, and enterprise systems. Built in Africa for the global market.',
  keywords: [
    'software company Africa',
    'web development Tanzania',
    'SaaS solutions Africa',
    'mobile app development',
    'enterprise software Africa',
    'inventory management system',
    'SMS gateway',
    'restaurant management system',
  ],
  authors: [{ name: 'Lwena TechWareAfrica' }],
  creator: 'Lwena TechWareAfrica',
  publisher: 'Lwena TechWareAfrica',
  metadataBase: new URL('https://lwenatech.com'),
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://lwenatech.com',
    title: 'Lwena TechWareAfrica | World-Class Software Solutions from Africa',
    description: 'Professional software development company delivering world-class solutions built in Africa for the global market.',
    siteName: 'Lwena TechWareAfrica',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Lwena TechWareAfrica | World-Class Software Solutions',
    description: 'Professional software development company from Africa.',
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={`${inter.variable} ${poppins.variable} font-sans antialiased`}>
        <Header />
        <main className="min-h-screen">
          {children}
        </main>
        <Footer />
      </body>
    </html>
  )
}

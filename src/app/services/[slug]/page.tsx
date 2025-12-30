import React from "react";
import { notFound } from "next/navigation";
import Link from "next/link";
import { PlaceholderImage } from "../../../components/ui/PlaceholderImage";

type Service = {
  title: string;
  short: string;
  features: string[];
  hero?: string;
};

const SERVICES: Record<string, Service> = {
  "web-development": {
    title: "Web Development",
    short: "Modern, responsive web apps built with best practices.",
    features: [
      "Custom web applications",
      "Responsive & accessible UI",
      "Performance & SEO optimization",
    ],
  },
  "mobile-apps": {
    title: "Mobile Apps",
    short: "Cross-platform mobile apps for Android and iOS.",
    features: ["React Native / Flutter options", "Native integrations", "App Store submission"],
  },
  "saas-solutions": {
    title: "SaaS Solutions",
    short: "From MVP to scale — subscription products and multi-tenant platforms.",
    features: ["Multi-tenant architecture", "Billing & subscriptions", "Analytics & monitoring"],
  },
  "system-integration": {
    title: "System Integration",
    short: "Connect your systems with reliable APIs and automation.",
    features: ["API design & gateways", "ETL & data sync", "Third-party integrations"],
  },
  "ai-solutions": {
    title: "AI Solutions",
    short: "Practical AI/ML features to boost business workflows.",
    features: ["Custom ML models", "NLP and search", "Automation & insights"],
  },
};

export async function generateStaticParams() {
  return Object.keys(SERVICES).map((slug) => ({ slug }));
}

export default function Page({ params }: { params: { slug: string } }) {
  const { slug } = params;
  const service = SERVICES[slug];

  if (!service) return notFound();

  return (
    <main className="container mx-auto px-6 py-16">
      <div className="grid md:grid-cols-2 gap-12 items-center">
        <div>
          <h1 className="text-4xl font-bold mb-4">{service.title}</h1>
          <p className="text-muted-foreground mb-6">{service.short}</p>

          <ul className="space-y-3 mb-6">
            {service.features.map((f) => (
              <li key={f} className="flex items-start gap-3">
                <span className="inline-block w-2 h-2 rounded-full bg-amber-500 mt-2" />
                <span>{f}</span>
              </li>
            ))}
          </ul>

          <div className="flex gap-3">
            <Link href="/register" className="btn btn-primary">
              Start Free Trial
            </Link>
            <Link href="/services" className="btn btn-ghost">
              All Services
            </Link>
          </div>
        </div>

        <div>
          <PlaceholderImage text={service.title} gradient="purple" width={800} height={360} className="rounded-lg" />
        </div>
      </div>

      <section className="mt-12">
        <h2 className="text-2xl font-semibold mb-4">How we work</h2>
        <ol className="list-decimal list-inside space-y-2 text-muted-foreground">
          <li>Discovery & requirements</li>
          <li>Design & prototyping</li>
          <li>Development & testing</li>
          <li>Launch & maintenance</li>
        </ol>
      </section>
    </main>
  );
}

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        // Lwena TechWareAfrica Brand Colors (AWS-inspired)
        primary: {
          DEFAULT: "#232F3E", // AWS Dark Blue
          foreground: "#FFFFFF",
        },
        secondary: {
          DEFAULT: "#FF9900", // AWS Orange - CTA & Highlights ONLY
          foreground: "#FFFFFF",
        },
        background: {
          DEFAULT: "#EAEDED", // Light page background
          dark: "#2D2D2D", // Dark mode cards
        },
        muted: {
          DEFAULT: "#777777", // Secondary text
          foreground: "#FFFFFF",
        },
        border: "#D4D4D4",
        destructive: {
          DEFAULT: "#FF4444", // Errors only
          foreground: "#FFFFFF",
        },
      },
      fontFamily: {
        sans: ['var(--font-inter)', 'system-ui', 'sans-serif'],
        heading: ['var(--font-poppins)', 'var(--font-inter)', 'system-ui', 'sans-serif'],
      },
      keyframes: {
        "accordion-down": {
          from: { height: 0 },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: 0 },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}

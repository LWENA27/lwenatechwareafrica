interface PlaceholderImageProps {
  width?: number
  height?: number
  text?: string
  gradient?: 'blue' | 'green' | 'purple' | 'orange' | 'default'
  className?: string
}

export function PlaceholderImage({ 
  width = 400, 
  height = 300, 
  text = 'Image', 
  gradient = 'default',
  className = '' 
}: PlaceholderImageProps) {
  const gradients = {
    blue: 'from-blue-500 to-cyan-500',
    green: 'from-green-500 to-emerald-500',
    purple: 'from-purple-500 to-pink-500',
    orange: 'from-orange-500 to-red-500',
    default: 'from-[#232F3E] to-[#FF9900]',
  }

  return (
    <div
      className={`relative bg-gradient-to-br ${gradients[gradient]} flex items-center justify-center overflow-hidden ${className}`}
      style={{ width: `${width}px`, height: `${height}px`, maxWidth: '100%' }}
    >
      {/* Decorative shapes */}
      <div className="absolute inset-0 opacity-20">
        <div className="absolute top-0 right-0 w-32 h-32 bg-white rounded-full -translate-y-16 translate-x-16"></div>
        <div className="absolute bottom-0 left-0 w-24 h-24 bg-white rounded-full translate-y-12 -translate-x-12"></div>
        <div className="absolute top-1/2 left-1/2 w-40 h-40 bg-white rounded-full -translate-x-1/2 -translate-y-1/2 opacity-50"></div>
      </div>
      
      {/* Text overlay */}
      <div className="relative z-10 text-white text-center p-4">
        <svg
          className="w-16 h-16 mx-auto mb-2 opacity-80"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
          />
        </svg>
        <p className="text-sm font-medium opacity-80">{text}</p>
      </div>
    </div>
  )
}

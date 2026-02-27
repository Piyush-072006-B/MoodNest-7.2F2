import SwiftUI

// Particle model for animated backgrounds
struct FloatingParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: CGFloat
    var type: ParticleType
    var rotation: Double = 0
    
    enum ParticleType {
        case star, sparkle, heart, circle
    }
}

// Animated background component using Canvas (Teal/Aqua theme)
struct AnimatedBackground: View {
    let particleType: FloatingParticle.ParticleType
    let particleCount: Int
    let colors: [Color]
    
    @State private var particles: [FloatingParticle] = []
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    init(
        particleType: FloatingParticle.ParticleType = .sparkle,
        particleCount: Int = 20,
        colors: [Color] = [.softAqua, .cyanBlue, .deepTeal.opacity(0.6)]
    ) {
        self.particleType = particleType
        self.particleCount = particleCount
        self.colors = colors
    }
    
    var body: some View {
        GeometryReader { geometry in
            if reduceMotion {
                // Static version for accessibility
                Canvas { context, size in
                    for particle in particles {
                        drawParticle(context: context, particle: particle, size: size)
                    }
                }
                .onAppear {
                    initializeParticles(size: geometry.size)
                }
            } else {
                // Animated version
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let time = timeline.date.timeIntervalSinceReferenceDate
                        
                        for particle in particles {
                            var animatedParticle = particle
                            
                            // Animate position
                            animatedParticle.y = particle.y + sin(time * Double(particle.speed) + Double(particle.x)) * 20
                            animatedParticle.x = particle.x + cos(time * Double(particle.speed) * 0.5) * 10
                            
                            // Animate opacity
                            animatedParticle.opacity = particle.opacity * (0.5 + 0.5 * sin(time * 2 + Double(particle.x)))
                            
                            // Animate rotation
                            animatedParticle.rotation = time * Double(particle.speed) * 50
                            
                            drawParticle(context: context, particle: animatedParticle, size: size)
                        }
                    }
                }
                .onAppear {
                    initializeParticles(size: geometry.size)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func initializeParticles(size: CGSize) {
        particles = (0..<particleCount).map { index in
            FloatingParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 8...24),
                opacity: Double.random(in: 0.2...0.6),
                speed: CGFloat.random(in: 0.3...0.8),
                type: particleType
            )
        }
    }
    
    func drawParticle(context: GraphicsContext, particle: FloatingParticle, size: CGSize) {
        var wrappedX = particle.x
        var wrappedY = particle.y
        
        // Wrap particles around screen
        if wrappedX < -50 { wrappedX = size.width + 50 }
        if wrappedX > size.width + 50 { wrappedX = -50 }
        if wrappedY < -50 { wrappedY = size.height + 50 }
        if wrappedY > size.height + 50 { wrappedY = -50 }
        
        let position = CGPoint(x: wrappedX, y: wrappedY)
        let color = colors[Int(particle.x) % colors.count].opacity(particle.opacity)
        
        var particleContext = context
        particleContext.opacity = particle.opacity
        
        switch particle.type {
        case .star:
            drawStar(context: particleContext, at: position, size: particle.size, color: color, rotation: particle.rotation)
        case .sparkle:
            drawSparkle(context: particleContext, at: position, size: particle.size, color: color, rotation: particle.rotation)
        case .heart:
            drawHeart(context: particleContext, at: position, size: particle.size, color: color)
        case .circle:
            drawCircle(context: particleContext, at: position, size: particle.size, color: color)
        }
    }
    
    func drawStar(context: GraphicsContext, at position: CGPoint, size: CGFloat, color: Color, rotation: Double) {
        var path = Path()
        let points = 5
        let outerRadius = size / 2
        let innerRadius = outerRadius * 0.4
        
        for i in 0..<points * 2 {
            let angle = Double(i) * .pi / Double(points) - .pi / 2 + rotation * .pi / 180
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = position.x + cos(angle) * radius
            let y = position.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        context.fill(path, with: .color(color))
    }
    
    func drawSparkle(context: GraphicsContext, at position: CGPoint, size: CGFloat, color: Color, rotation: Double) {
        var path = Path()
        let length = size / 2
        
        // Horizontal line
        path.move(to: CGPoint(x: position.x - length, y: position.y))
        path.addLine(to: CGPoint(x: position.x + length, y: position.y))
        
        // Vertical line
        path.move(to: CGPoint(x: position.x, y: position.y - length))
        path.addLine(to: CGPoint(x: position.x, y: position.y + length))
        
        context.stroke(path, with: .color(color), lineWidth: 2)
    }
    
    func drawHeart(context: GraphicsContext, at position: CGPoint, size: CGFloat, color: Color) {
        var path = Path()
        let width = size
        let height = size
        
        path.move(to: CGPoint(x: position.x, y: position.y + height * 0.3))
        
        path.addCurve(
            to: CGPoint(x: position.x - width * 0.5, y: position.y - height * 0.1),
            control1: CGPoint(x: position.x, y: position.y),
            control2: CGPoint(x: position.x - width * 0.5, y: position.y - height * 0.3)
        )
        
        path.addArc(
            center: CGPoint(x: position.x - width * 0.25, y: position.y - height * 0.1),
            radius: width * 0.25,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        path.addArc(
            center: CGPoint(x: position.x + width * 0.25, y: position.y - height * 0.1),
            radius: width * 0.25,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        path.addCurve(
            to: CGPoint(x: position.x, y: position.y + height * 0.3),
            control1: CGPoint(x: position.x + width * 0.5, y: position.y - height * 0.3),
            control2: CGPoint(x: position.x, y: position.y)
        )
        
        context.fill(path, with: .color(color))
    }
    
    func drawCircle(context: GraphicsContext, at position: CGPoint, size: CGFloat, color: Color) {
        let rect = CGRect(x: position.x - size/2, y: position.y - size/2, width: size, height: size)
        let path = Circle().path(in: rect)
        context.fill(path, with: .color(color))
    }
}

#Preview {
    ZStack {
        Color.lightSky
        AnimatedBackground(particleType: .sparkle, particleCount: 30)
    }
}

import SwiftUI

// Confetti particle for success animations
struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var size: CGFloat
    var velocity: CGVector
    var rotation: Double
    var rotationSpeed: Double
}

// Confetti animation view (Teal/Aqua theme)
struct ConfettiView: View {
    let particleCount: Int
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    init(particleCount: Int? = nil) {
        if let count = particleCount {
            self.particleCount = count
        } else {
            #if targetEnvironment(simulator)
            self.particleCount = 60
            #else
            // Adjust based on device capability if needed, standardizing to 100 for balance
            self.particleCount = 100
            #endif
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if reduceMotion {
                // Simple checkmark for accessibility
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.cyanBlue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Animated confetti
                ZStack {
                    ForEach(particles) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .rotationEffect(.degrees(particle.rotation))
                            .position(x: particle.x, y: particle.y)
                    }
                }
                .onAppear {
                    initializeParticles(size: geometry.size)
                    Task {
                        await animateConfetti()
                    }
                }
            }
        }
    }
    
    func initializeParticles(size: CGSize) {
        // Teal/Aqua color palette for confetti
        let colors: [Color] = [
            .deepTeal, .cyanBlue, .softAqua,
            .deepTeal.opacity(0.7), .cyanBlue.opacity(0.8), .softAqua.opacity(0.9)
        ]
        
        particles = (0..<particleCount).map { _ in
            ConfettiParticle(
                x: size.width / 2,
                y: size.height / 2,
                color: colors.randomElement() ?? .cyanBlue,
                size: CGFloat.random(in: 6...12),
                velocity: CGVector(
                    dx: CGFloat.random(in: -200...200),
                    dy: CGFloat.random(in: -300...(-100))
                ),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -360...360)
            )
        }
    }
    
    @MainActor
    func animateConfetti() async {
        isAnimating = true
        
        // Run animation loop for 3 seconds
        let startTime = Date()
        let duration: TimeInterval = 3.0
        
        while isAnimating && Date().timeIntervalSince(startTime) < duration {
            // Update particles
            for index in particles.indices {
                // Apply gravity
                particles[index].velocity.dy += 15
                
                // Update position
                particles[index].x += particles[index].velocity.dx * 0.016
                particles[index].y += particles[index].velocity.dy * 0.016
                
                // Update rotation
                particles[index].rotation += particles[index].rotationSpeed * 0.016
            }
            
            // Wait for next frame (60fps = ~16ms)
            try? await Task.sleep(nanoseconds: 16_000_000)
        }
        
        // Stop animation
        isAnimating = false
    }
}

#Preview {
    ZStack {
        Color.lightSky
        ConfettiView()
    }
}

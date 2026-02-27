import SwiftUI

struct DecorativeBackground: View {
    var gradient: LinearGradient = LinearGradient(
        colors: [Color.lightSky, Color.softAqua.opacity(0.15)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base gradient
            gradient
                .ignoresSafeArea()
            
            // Animated Blobs
            GeometryReader { geometry in
                ZStack {
                    // Top left blob
                    Circle()
                        .fill(Color.cyanBlue.opacity(0.08))
                        .frame(width: 400, height: 400)
                        .blur(radius: 60)
                        .offset(x: animate ? -50 : -100, y: animate ? -50 : -100)
                        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
                    
                    // Bottom right blob
                    Circle()
                        .fill(Color.deepTeal.opacity(0.06))
                        .frame(width: 350, height: 350)
                        .blur(radius: 50)
                        .offset(x: geometry.size.width - (animate ? 100 : 150), y: geometry.size.height - (animate ? 100 : 150))
                        .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)
                    
                    // Center floating aqua accent
                    Circle()
                        .fill(Color.softAqua.opacity(0.1))
                        .frame(width: 250, height: 250)
                        .blur(radius: 40)
                        .offset(x: geometry.size.width / 2 + (animate ? 30 : -30), y: geometry.size.height / 3 + (animate ? 20 : -20))
                        .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate)
                }
                
                // Foliage Overlay (Subtle silhouettes)
                FoliagePatterns(size: geometry.size)
                    .opacity(0.05)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            animate = true
        }
    }
}

struct FoliagePatterns: View {
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Bottom left plant silhouette
            LeafShape()
                .fill(Color.deepTeal)
                .frame(width: 200, height: 300)
                .rotationEffect(.degrees(-15))
                .offset(x: -50, y: size.height - 200)
            
            // Top right subtle branch
            LeafShape()
                .fill(Color.cyanBlue)
                .frame(width: 150, height: 200)
                .rotationEffect(.degrees(165))
                .offset(x: size.width - 100, y: 50)
        }
    }
}

struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Simple organic leaf shape
        path.move(to: CGPoint(x: width / 2, y: height))
        path.addCurve(to: CGPoint(x: width / 2, y: 0),
                      control1: CGPoint(x: width, y: height * 0.7),
                      control2: CGPoint(x: width * 0.8, y: height * 0.2))
        path.addCurve(to: CGPoint(x: width / 2, y: height),
                      control1: CGPoint(x: 0, y: height * 0.2),
                      control2: CGPoint(x: 0, y: height * 0.7))
        
        return path
    }
}

#Preview {
    DecorativeBackground()
}

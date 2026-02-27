import SwiftUI

struct CustomMoodEditorView: View {
    @StateObject private var moodManager = CustomMoodManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showingAddMood = false
    
    var body: some View {
        NavigationView {
            ZStack {
                DecorativeBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Customize Your Moods")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.deepTeal)
                            
                            Text("Add, edit, or remove mood options")
                                .font(.system(size: 14))
                                .foregroundColor(.softAqua)
                        }
                        .padding(.top, 20)
                        
                        // Mood List
                        VStack(spacing: 12) {
                            ForEach(moodManager.customMoods) { mood in
                                MoodEditorRow(mood: mood)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Add New Mood Button
                        Button(action: { showingAddMood = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Add Custom Mood")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.cyanBlue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cyanBlue)
                }
            }
            .sheet(isPresented: $showingAddMood) {
                MoodEditSheet(mood: nil)
            }
        }
    }
}

// MARK: - Mood Editor Row

struct MoodEditorRow: View {
    let mood: CustomMood
    @StateObject private var moodManager = CustomMoodManager.shared
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: mood.iconName)
                .font(.system(size: 28))
                .foregroundColor(mood.color)
                .frame(width: 50, height: 50)
                .background(mood.color.opacity(0.15))
                .cornerRadius(12)
            
            // Name
            Text(mood.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.deepTeal)
            
            Spacer()
            
            // Default Badge
            if mood.isDefault {
                Text("Default")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.softAqua)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.softAqua.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Edit Button
            Button(action: { showingEditSheet = true }) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.cyanBlue)
            }
            
            // Delete Button (only for custom moods)
            if !mood.isDefault {
                Button(action: {
                    withAnimation {
                        moodManager.deleteMood(mood)
                    }
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.7))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingEditSheet) {
            MoodEditSheet(mood: mood)
        }
    }
}

// MARK: - Mood Edit Sheet

struct MoodEditSheet: View {
    @StateObject private var moodManager = CustomMoodManager.shared
    @Environment(\.dismiss) var dismiss
    
    let mood: CustomMood?  // nil for new mood
    
    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColor: Color
    
    init(mood: CustomMood?) {
        self.mood = mood
        _name = State(initialValue: mood?.name ?? "")
        _selectedIcon = State(initialValue: mood?.iconName ?? "face.smiling")
        _selectedColor = State(initialValue: mood?.color ?? .cyanBlue)
    }
    
    let availableIcons = [
        "face.smiling", "face.smiling.inverse", "face.dashed",
        "heart.fill", "star.fill", "sun.max.fill",
        "moon.fill", "cloud.fill", "bolt.fill",
        "flame.fill", "leaf.fill", "drop.fill",
        "sparkles", "wind", "snowflake"
    ]
    
    let availableColors: [Color] = [
        .cyanBlue, .softAqua, .deepTeal,
        .orange, .purple, .pink,
        .red, .green, .blue,
        .yellow, .indigo, .mint
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                DecorativeBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview
                        VStack(spacing: 16) {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 60))
                                .foregroundColor(selectedColor)
                                .frame(width: 120, height: 120)
                                .background(selectedColor.opacity(0.15))
                                .cornerRadius(20)
                            
                            Text(name.isEmpty ? "Mood Name" : name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.deepTeal)
                        }
                        .padding(.top, 20)
                        
                        // Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mood Name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.deepTeal)
                            
                            TextField("Enter mood name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: 16))
                        }
                        .padding(.horizontal, 20)
                        
                        // Icon Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Icon")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.deepTeal)
                                .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 50))
                            ], spacing: 12) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedIcon == icon ? .white : .deepTeal)
                                            .frame(width: 50, height: 50)
                                            .background(selectedIcon == icon ? Color.cyanBlue : Color.softAqua.opacity(0.2))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Color Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Color")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.deepTeal)
                                .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 50))
                            ], spacing: 12) {
                                ForEach(availableColors, id: \.self) { color in
                                    Button(action: { selectedColor = color }) {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(Color.white, lineWidth: selectedColor == color ? 4 : 0)
                                            )
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Save Button
                        Button(action: saveMood) {
                            Text(mood == nil ? "Add Mood" : "Update Mood")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(name.isEmpty ? Color.gray : Color.cyanBlue)
                                .cornerRadius(12)
                        }
                        .disabled(name.isEmpty)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(mood == nil ? "New Mood" : "Edit Mood")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.cyanBlue)
                }
            }
        }
    }
    
    func saveMood() {
        guard !name.isEmpty else { return }
        
        let colorHex = selectedColor.toHex() ?? "#5AC8FA"
        
        if let existingMood = mood {
            // Update existing mood
            let updatedMood = CustomMood(
                id: existingMood.id,
                name: name,
                iconName: selectedIcon,
                colorHex: colorHex,
                isDefault: existingMood.isDefault
            )
            moodManager.updateMood(updatedMood)
        } else {
            // Add new mood
            let newMood = CustomMood(
                name: name,
                iconName: selectedIcon,
                colorHex: colorHex,
                isDefault: false
            )
            moodManager.addMood(newMood)
        }
        
        dismiss()
    }
}

#Preview {
    CustomMoodEditorView()
}

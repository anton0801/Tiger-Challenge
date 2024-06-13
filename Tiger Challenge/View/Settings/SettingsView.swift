import SwiftUI

struct SettingsView: View {

    @Environment(\.presentationMode) var preMode
    @StateObject var settingsViewModel: SettingsViewModel = SettingsViewModel()

    var body: some View {
        VStack {
            ZStack {
                Image("button_bg")
                    .resizable()
                    .frame(width: 240, height: 100)
                Text("Settings")
                    .font(.custom(.tlHeaderFont, size: 48))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            ZStack {
                Image("settings_bg")
                VStack {
                    HStack {
                        Image("music_app")
                            .resizable()
                            .frame(width: 32, height: 32)
                        Button {
                            withAnimation(.linear(duration: 0.5)) {
                                settingsViewModel.musicOn = !settingsViewModel.musicOn
                            }
                        } label: {
                            if settingsViewModel.musicOn {
                                Image("full")
                            } else {
                                Image("empty")
                            }
                        }
                    }
                    
                    HStack {
                        Image("sound_app")
                            .resizable()
                            .frame(width: 32, height: 32)
                        Button {
                            withAnimation(.linear(duration: 0.5)) {
                                settingsViewModel.soundsOn = !settingsViewModel.soundsOn
                            }
                        } label: {
                            if settingsViewModel.soundsOn {
                                Image("full")
                            } else {
                                Image("empty")
                            }
                        }
                    }
                }
            }
            Button {
                preMode.wrappedValue.dismiss()
            } label: {
                Image("done_button")
            }
            .offset(y: -20)
            
            Spacer()
            
            Button {
                preMode.wrappedValue.dismiss()
            } label: {
                Image("home_btn")
            }
        }
        .background(
            Image("levels_bg")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 40)
        )
    }
}

#Preview {
    SettingsView()
}

import SwiftUI

struct InfoGameRulesView: View {
    
    @Environment(\.presentationMode) var preMode
    
    var body: some View {
        VStack {
            ZStack {
               Image("button_bg")
                   .resizable()
                   .frame(width: 240, height: 100)
               Text("Rules")
                   .font(.custom(.tlHeaderFont, size: 48))
                   .foregroundColor(.white)
           }
            
            Spacer()
            
            ScrollView {
                Image("rules_1")
                    .padding([.top, .bottom])
                Image("rules_2")
                    .padding([.top, .bottom])
                Image("rules_3")
                    .padding([.top, .bottom])
            }
            .padding()
            
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
    InfoGameRulesView()
}

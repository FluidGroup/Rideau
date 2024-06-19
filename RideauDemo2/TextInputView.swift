
import SwiftUI

struct TextInputView: View {

  @State var text: String = ""

  var body: some View {

    ZStack {

      Color.red
      
      VStack {

        Text("Hello")

        TextField.init("Input", text: $text)

        Spacer()

      }

    }
  }

}

#Preview {
  TextInputView()
}

import SwiftUI

private let groupID = "group.com.example.GhostType"
private let listKey = "messageList"

struct ContentView: View {
    @State private var text = UserDefaults(suiteName: groupID)?.string(forKey: listKey) ?? ""
    @State private var saved = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Danh sách tin nhắn")
                    .font(.title2.bold())

                Text("Mỗi dòng là một tin nhắn. Bàn phím sẽ gõ từng ký tự của dòng đang chọn; bạn tự bấm Gửi trong Discord.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                TextEditor(text: $text)
                    .font(.body.monospaced())
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.35)))

                Button {
                    UserDefaults(suiteName: groupID)?.set(text, forKey: listKey)
                    saved = true
                } label: {
                    Text("Lưu danh sách")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)

                if saved {
                    Text("Đã lưu trên thiết bị.")
                        .font(.footnote)
                        .foregroundStyle(.green)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Cách bật bàn phím")
                        .font(.headline)
                    Text("Cài đặt → Cài đặt chung → Bàn phím → Bàn phím → Thêm bàn phím mới → GhostType Keyboard.")
                        .font(.footnote)
                    Text("Chỉ bật “Cho phép truy cập đầy đủ” nếu cần đọc danh sách đã lưu qua App Group. Bản mẫu không gửi nội dung ra mạng.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("GhostType")
        }
    }
}

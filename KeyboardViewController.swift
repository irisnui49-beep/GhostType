import UIKit

private let groupID = "group.com.example.GhostType"
private let listKey = "messageList"

final class KeyboardViewController: UIInputViewController {
    private let statusLabel = UILabel()
    private let startButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let delaySlider = UISlider()
    private var messages: [String] = []
    private var messageIndex = 0
    private var typingTask: Task<Void, Never>?
    private var isTyping = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        buildUI()
        loadMessages()
    }

    deinit { typingTask?.cancel() }

    private func buildUI() {
        let title = UILabel()
        title.text = "GhostType"
        title.font = .boldSystemFont(ofSize: 16)

        statusLabel.text = "Sẵn sàng"
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = .secondaryLabel

        startButton.setTitle("▶ Bắt đầu", for: .normal)
        stopButton.setTitle("■ Dừng", for: .normal)
        nextButton.setTitle("Câu tiếp", for: .normal)

        startButton.addTarget(self, action: #selector(startTyping), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopTyping), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMessage), for: .touchUpInside)

        delaySlider.minimumValue = 0.04
        delaySlider.maximumValue = 0.22
        delaySlider.value = 0.09

        let buttons = UIStackView(arrangedSubviews: [startButton, stopButton, nextButton])
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 8

        let stack = UIStackView(arrangedSubviews: [title, statusLabel, buttons, delaySlider])
        stack.axis = .vertical
        stack.spacing = 9
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            view.heightAnchor.constraint(equalToConstant: 116)
        ])
    }

    private func loadMessages() {
        let raw = UserDefaults(suiteName: groupID)?.string(forKey: listKey) ?? ""
        messages = raw.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        messageIndex = min(messageIndex, max(messages.count - 1, 0))
        statusLabel.text = messages.isEmpty ? "Chưa có câu — mở app để nhập" : "\(messages.count) câu đã tải"
    }

    @objc private func startTyping() {
        guard !isTyping else { return }
        loadMessages()
        guard messageIndex < messages.count else {
            statusLabel.text = "Đã hết danh sách"
            return
        }
        let message = messages[messageIndex]
        guard !message.isEmpty else { return }

        isTyping = true
        statusLabel.text = "Đang gõ câu \(messageIndex + 1)/\(messages.count)…"
        typingTask = Task { @MainActor in
            for character in message {
                if Task.isCancelled { break }
                textDocumentProxy.insertText(String(character))
                let base = Double(delaySlider.value)
                let jitter = Double.random(in: 0.0...0.07)
                try? await Task.sleep(nanoseconds: UInt64((base + jitter) * 1_000_000_000))
            }
            isTyping = false
            if !Task.isCancelled {
                statusLabel.text = "Xong câu \(messageIndex + 1). Tự bấm Gửi, rồi chọn Câu tiếp."
            } else {
                statusLabel.text = "Đã dừng"
            }
        }
    }

    @objc private func stopTyping() {
        typingTask?.cancel()
        typingTask = nil
        isTyping = false
        statusLabel.text = "Đã dừng"
    }

    @objc private func nextMessage() {
        stopTyping()
        messageIndex += 1
        if messageIndex >= messages.count {
            statusLabel.text = "Đã hết danh sách"
        } else {
            statusLabel.text = "Sẵn sàng câu \(messageIndex + 1)/\(messages.count)"
        }
    }
}

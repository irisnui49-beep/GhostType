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
    private var isTyping = false {
        didSet {
            // Cập nhật trạng thái bật/tắt của nút bấm cho trực quan
            startButton.isEnabled = !isTyping
            nextButton.isEnabled = !isTyping
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        buildUI()
        loadMessages()
    }

    deinit { 
        typingTask?.cancel() 
    }

    private func buildUI() {
        let title = UILabel()
        title.text = "GhostType"
        title.font = .boldSystemFont(ofSize: 15)

        statusLabel.text = "Sẵn sàng"
        statusLabel.font = .systemFont(ofSize: 11)
        statusLabel.textColor = .secondaryLabel

        startButton.setTitle("▶ Bắt đầu", for: .normal)
        stopButton.setTitle("■ Dừng", for: .normal)
        nextButton.setTitle("Câu tiếp ➡", for: .normal)

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
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6),
            // Tăng nhẹ chiều cao để bàn phím thoáng hơn, tránh bị tràn trên một số máy
            view.heightAnchor.constraint(equalToConstant: 135)
        ])
    }

    private func loadMessages() {
        let raw = UserDefaults(suiteName: groupID)?.string(forKey: listKey) ?? ""
        messages = raw.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        messageIndex = min(messageIndex, max(messages.count - 1, 0))
        
        if messages.isEmpty {
            statusLabel.text = "Chưa có câu — hãy mở app chính để nhập"
        } else {
            statusLabel.text = "Đã tải \(messages.count) câu (Đang ở câu \(messageIndex + 1))"
        }
    }

    @objc private func startTyping() {
        guard !isTyping else { return }
        loadMessages()
        
        guard !messages.isEmpty, messageIndex < messages.count else {
            statusLabel.text = "Danh sách trống hoặc đã hết câu!"
            return
        }
        
        let message = messages[messageIndex]
        guard !message.isEmpty else { return }

        isTyping = true
        statusLabel.text = "Đang gõ câu \(messageIndex + 1)/\(messages.count)…"
        
        typingTask = Task { @MainActor in
            for character in message {
                // Kiểm tra hủy task liên tục
                if Task.isCancelled { break }
                
                textDocumentProxy.insertText(String(character))
                
                let base = Double(delaySlider.value)
                let jitter = Double.random(in: 0.0...0.07)
                
                do {
                    try await Task.sleep(nanoseconds: UInt64((base + jitter) * 1_000_000_000))
                } catch {
                    // Task bị hủy trong lúc sleep
                    break
                }
            }
            
            isTyping = false
            
            if Task.isCancelled {
                statusLabel.text = "Đã dừng"
            } else {
                statusLabel.text = "Xong câu \(messageIndex + 1). Bấm Gửi, rồi bấm 'Câu tiếp'."
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
        loadMessages()
        
        guard !messages.isEmpty else { return }
        
        messageIndex = (messageIndex + 1) % messages.count // Vòng lặp lại từ đầu nếu hết danh sách
        statusLabel.text = "Sẵn sàng câu \(messageIndex + 1)/\(messages.count)"
    }
}

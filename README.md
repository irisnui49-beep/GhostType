# GhostType — iOS keyboard starter

This is an experimental SwiftUI host app + custom keyboard extension.

## What this prototype does
- Host app stores a multiline list in an App Group shared `UserDefaults`.
- Each non-empty line is treated as one message.
- In the keyboard, **Bắt đầu** types the current message one character at a time.
- **Dừng** cancels the current typing task.
- After typing one message, manually send it in the target app, then tap **Câu tiếp**.

## Important limitations
- This does **not** press Discord's Send button.
- It does **not** automatically detect when you sent a message.
- iOS may suspend or terminate a keyboard extension; long timed typing is experimental and may stop if the keyboard loses focus or the system ends the extension.
- A custom keyboard can be blocked in secure text fields and some apps.
- The sample requests keyboard Full Access so it can read the shared App Group list. The code contains no networking, analytics, or data upload. Review the source before enabling Full Access.
- This starter is not signed and cannot be installed directly as-is.

## Build notes
1. Change `com.example.GhostType`, `com.example.GhostType.Keyboard`, and `group.com.example.GhostType` to identifiers you own, consistently in `project.yml`, both entitlements, and `KeyboardViewController.swift` / `ContentView.swift`.
2. Create the matching App Group in your Apple Developer account/team and enable it for both targets. Free personal signing may have limitations.
3. Push the project to a GitHub repository.
4. Run the `Build GhostType (unsigned)` workflow from the Actions tab.
5. The workflow artifact is an unsigned IPA. It still needs to be signed with your Apple ID and installed using a compatible sideloading workflow. The GitHub build alone does not install it on your iPhone.

## Current behavior by design
The first prototype types one message per run. After sending it manually, tap **Câu tiếp** and then **Bắt đầu** for the next one. A truly unattended “type all messages while waiting for manual sends” flow is not implemented because the extension cannot reliably detect Discord's send action.

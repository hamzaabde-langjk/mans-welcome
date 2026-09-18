import QtQuick
import Quickshell
import Quickshell.Io

Service {
  id: root
  moduleName: "mans.welcome"

  readonly property string scriptPath: String(Qt.resolvedUrl("bin/omarchy-welcome")).replace(/^file:\/\//, "")

  property string userName: "User"
  property string avatarPath: ""
  property int duration: 4

  Component.onCompleted: loadSettings.running = true

  Process {
    id: loadSettings
    command: [
      "bash",
      "-c",
      "cat ~/.config/mans.welcome/name 2>/dev/null || echo User; cat ~/.config/mans.welcome/avatar 2>/dev/null || echo ''; cat ~/.config/mans.welcome/duration 2>/dev/null || echo 4"
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        var lines = String(text).split("\n")
        root.userName = (lines[0] || "User").trim()
        root.avatarPath = (lines[1] || "").trim()
        root.duration = parseInt(lines[2] || "4") || 4
        launchWelcome.running = true
      }
    }
  }

  Process {
    id: launchWelcome
    command: [
      "foot",
      "--app-id=omarchy-welcome",
      "--title=Welcome",
      "-e",
      root.scriptPath,
      root.userName,
      String(root.duration),
      root.avatarPath
    ]
  }
}

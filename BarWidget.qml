import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

Panel {
  id: root
  moduleName: "mans.welcome"
  ipcTarget: "mans.welcome"
  manageIpc: false

  readonly property string scriptPath: String(Qt.resolvedUrl("bin/omarchy-welcome")).replace(/^file:\/\//, "")

  property string userName: "User"
  property string avatarPath: ""
  property int duration: 4

  implicitWidth: buttonRow.implicitWidth + 16
  implicitHeight: buttonRow.implicitHeight + 8

  RowLayout {
    id: buttonRow
    anchors.centerIn: parent
    spacing: 6

    Text {
      text: ""
      font.pixelSize: 16
      color: root.bar.foreground
    }

    Text {
      text: ""
      font.family: root.bar.fontFamily
      font.pixelSize: 12
      font.bold: true
      color: root.bar.foreground
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(panelColumn.implicitHeight, Style.space(420))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()

      Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: panelColumn.implicitHeight
        clip: true
        interactive: contentHeight > height

        Column {
          id: panelColumn
          width: parent.width
          spacing: Style.space(12)

          Text {
            width: parent.width
            text: "Omarchy Welcome"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.title
            font.bold: true
          }

          Text {
            width: parent.width
            text: "Configure your name, avatar, and duration."
            color: Qt.darker(root.bar.foreground, 1.4)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }

          PanelSeparator { foreground: root.bar.foreground }

          Column {
            width: parent.width
            spacing: Style.space(6)

            Text {
              text: "NAME"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
            }

            TextField {
              id: nameField
              width: parent.width
              text: root.userName
              placeholderText: "Enter your name"
              font.family: root.bar.fontFamily
              onTextChanged: root.userName = text
            }
          }

          Column {
            width: parent.width
            spacing: Style.space(6)

            Text {
              text: "AVATAR"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
            }

            Row {
              width: parent.width
              spacing: Style.space(6)

              TextField {
                id: avatarField
                width: parent.width - 90
                text: root.avatarPath
                placeholderText: "No image selected"
                readOnly: true
                font.family: root.bar.fontFamily
              }

              Button {
                width: 80
                text: "Browse"
                onClicked: filePicker.running = true
              }
            }
          }

          Column {
            width: parent.width
            spacing: Style.space(6)

            Text {
              text: "DURATION: " + durationSlider.value + "s"
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
            }

            Slider {
              id: durationSlider
              width: parent.width
              from: 1
              to: 15
              value: root.duration
              stepSize: 1
              onValueChanged: root.duration = Math.round(value)
            }
          }

          PanelSeparator { foreground: root.bar.foreground }

          Button {
            width: parent.width
            text: "▶ Preview"
            onClicked: {
              previewProc.command = [
                "foot",
                "--app-id=omarchy-welcome",
                "--title=Welcome",
                "-e",
                root.scriptPath,
                root.userName,
                String(root.duration),
                root.avatarPath
              ]
              previewProc.running = true
            }
          }

          Button {
            width: parent.width
            text: "💾 Save"
            onClicked: saveProc.running = true
          }

          Item { width: parent.width; height: Style.space(4) }
        }
      }
    }
  }

  Process {
    id: filePicker
    command: [
      "bash",
      "-c",
      "zenity --file-selection --file-filter='Images | *.png *.jpg *.jpeg *.gif *.bmp' 2>/dev/null || kdialog --getopenfilename . 'Images (*.png *.jpg *.jpeg *.gif *.bmp)' 2>/dev/null"
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        var path = String(text).trim()
        if (path.length > 0) {
          root.avatarPath = path
          avatarField.text = path
        }
      }
    }
  }

  Process {
    id: previewProc
  }

  Process {
    id: saveProc
    command: [
      "bash",
      "-c",
      "mkdir -p ~/.config/mans.welcome && printf '%s' \"" + root.userName + "\" > ~/.config/mans.welcome/name && printf '%s' \"" + root.avatarPath + "\" > ~/.config/mans.welcome/avatar && printf '%s' \"" + root.duration + "\" > ~/.config/mans.welcome/duration"
    ]
    stdout: StdioCollector {
      onStreamFinished: console.log("mans.welcome: settings saved")
    }
  }

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
        nameField.text = root.userName
        avatarField.text = root.avatarPath
        durationSlider.value = root.duration
      }
    }
  }
}

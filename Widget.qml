import QtQuick
import Quickshell.Io
import qs.Ui
import qs.Commons

Panel {
  id: root
  moduleName: "slider.opacity"
  ipcTarget: "slider.opacity"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property real sliderMin: 0.3
  readonly property real sliderMax: 1.0

  property real activeOpacity: 0.9
  property real inactiveOpacity: 0.85
  property bool glassEnabled: false

  function clampOpacity(value) {
    return Math.max(root.sliderMin, Math.min(root.sliderMax, Number(value)))
  }

  function applyOption(name, value) {
    var v = root.clampOpacity(value)
    root.bar.run("hyprctl eval 'hl.config({ decoration = { " + name + " = " + v.toFixed(2) + " } })'")
  }

  function percentLabel(value) {
    return Math.round(value * 100) + "%"
  }

  function readCurrentValues() {
    activeProbe.running = true
    inactiveProbe.running = true
    glassProbe.running = true
  }

  function applyGlass(enabled) {
    var value = enabled === true
    if (value) {
      root.bar.run("hyprctl eval 'hl.config({ decoration = { blur = { enabled = true, size = 8, passes = 2 } } })'")
    } else {
      root.bar.run("hyprctl eval 'hl.config({ decoration = { blur = { enabled = false } } })'")
    }
    root.glassEnabled = value
  }

  Component.onCompleted: root.readCurrentValues()

  Process {
    id: activeProbe
    command: ["hyprctl", "getoption", "decoration:active_opacity"]
    stdout: SplitParser {
      onRead: function(line) {
        var match = String(line).trim().match(/^float:\s*([0-9.]+)/)
        if (match) root.activeOpacity = root.clampOpacity(match[1])
      }
    }
  }

  Process {
    id: inactiveProbe
    command: ["hyprctl", "getoption", "decoration:inactive_opacity"]
    stdout: SplitParser {
      onRead: function(line) {
        var match = String(line).trim().match(/^float:\s*([0-9.]+)/)
        if (match) root.inactiveOpacity = root.clampOpacity(match[1])
      }
    }
  }

  Process {
    id: glassProbe
    command: ["hyprctl", "getoption", "decoration:blur:enabled"]
    stdout: SplitParser {
      onRead: function(line) {
        var match = String(line).trim().match(/^bool:\s*(true|false)/)
        if (match) root.glassEnabled = match[1] === "true"
      }
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "Opacity"
    fontSize: Style.font.body
    tooltipText: "Window transparency"
    onPressed: function(b) {
      if (b !== Qt.LeftButton) return
      root.toggle()
      root.readCurrentValues()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: Style.space(280)
    contentHeight: Math.min(content.implicitHeight + Style.spacing.popupPadding * 2, Style.space(220))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
    }

    Column {
      id: content
      width: parent.width
      spacing: Style.spacing.controlGap

      Row {
        width: parent.width
        spacing: Style.space(6)

        Text {
          textFormat: Text.PlainText
          text: "Active"
          color: root.barForeground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.body
          anchors.verticalCenter: parent.verticalCenter
        }

        Item { width: 1; height: 1 }

        Text {
          textFormat: Text.PlainText
          text: root.percentLabel(root.activeOpacity)
          color: root.barForeground.opacity ? root.barForeground : Color.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.body
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      PanelSlider {
        id: activeSlider
        width: parent.width
        minimum: root.sliderMin
        maximum: root.sliderMax
        step: 0.05
        value: root.activeOpacity
        onMoved: function(v) {
          root.activeOpacity = v
          root.applyOption("active_opacity", v)
        }
      }

      Row {
        width: parent.width
        spacing: Style.space(6)

        Text {
          textFormat: Text.PlainText
          text: "Inactive"
          color: root.barForeground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.body
          anchors.verticalCenter: parent.verticalCenter
        }

        Item { width: 1; height: 1 }

        Text {
          textFormat: Text.PlainText
          text: root.percentLabel(root.inactiveOpacity)
          color: root.barForeground.opacity ? root.barForeground : Color.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.body
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      PanelSlider {
        id: inactiveSlider
        width: parent.width
        minimum: root.sliderMin
        maximum: root.sliderMax
        step: 0.05
        value: root.inactiveOpacity
        onMoved: function(v) {
          root.inactiveOpacity = v
          root.applyOption("inactive_opacity", v)
        }
      }

      Toggle {
        id: glassToggle
        width: parent.width
        label: "Glass blur"
        description: "Frosted blur behind transparent windows"
        foreground: root.barForeground
        accent: Color.accent
        fontFamily: root.bar.fontFamily
        checked: root.glassEnabled
        onClicked: root.applyGlass(!root.glassEnabled)
      }

      Text {
        textFormat: Text.PlainText
        text: "Fullscreen windows stay opaque"
        color: Color.muted
        font.family: root.bar.fontFamily
        font.pixelSize: 11
        horizontalAlignment: Text.AlignHCenter
      }
    }
  }
}
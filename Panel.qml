import "CompatUi" as ThemeUi
// SPDX-License-Identifier: GPL-3.0-only

import QtQuick
import qs.Commons as Commons
import qs.Ui

Panel {
  id: root
  moduleName: "io.github.manateelazycat.color-picker"
  ipcTarget: "io.github.manateelazycat.color-picker"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property string selectedFormat: "hex"
  property int focusIndex: 0

  readonly property var barIdentity: hostWidget || root
  readonly property color foreground: root.bar ? root.bar.barForeground : Commons.Color.foreground
  readonly property string fontFamily: root.bar ? root.bar.fontFamily : Commons.Style.font.family

  function normalizedFormat(value) {
    var normalized = String(value || "").toLowerCase()
    return normalized === "rgb" || normalized === "hsl" ? normalized : "hex"
  }

  function indexForFormat(value) {
    var normalized = root.normalizedFormat(value)
    return normalized === "rgb" ? 1 : normalized === "hsl" ? 2 : 0
  }

  function formatForIndex(index) {
    return index === 1 ? "rgb" : index === 2 ? "hsl" : "hex"
  }

  function applyFormat(value) {
    root.selectedFormat = root.normalizedFormat(value)
    root.focusIndex = root.indexForFormat(root.selectedFormat)
  }

  function open() {
    if (root.hostWidget) root.applyFormat(root.hostWidget.activeFormat)
    root.controller.show()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function moveFocus(delta) {
    root.focusIndex = (root.focusIndex + (delta > 0 ? 1 : -1) + 3) % 3
  }

  function chooseFormat(value) {
    var normalized = root.normalizedFormat(value)
    root.selectedFormat = normalized
    root.focusIndex = root.indexForFormat(normalized)
    if (root.hostWidget && root.hostWidget.setFormat)
      root.hostWidget.setFormat(normalized)
    root.close()
  }

  function activateFocused() {
    root.chooseFormat(root.formatForIndex(root.focusIndex))
  }

  component FormatItem: Rectangle {
    id: formatItem

    property string formatValue: "hex"
    property string label: "HEX"
    property string example: "#1E90FF"
    property bool selected: false
    property bool hasCursor: false
    property color foreground: Commons.Color.foreground
    property string fontFamily: Commons.Style.font.family

    signal clicked()
    signal hovered(bool isHovered)

    implicitHeight: Math.max(Commons.Style.space(48), labels.implicitHeight + Commons.Style.space(12))
    radius: Commons.Style.cornerRadius
    color: mouse.pressed
      ? Commons.Style.pressedFillFor(formatItem.foreground, Commons.Color.accent)
      : (formatItem.hasCursor || mouse.containsMouse)
        ? Commons.Style.hoverFillFor(formatItem.foreground, formatItem.foreground)
        : formatItem.selected
          ? Commons.Style.selectedFillFor(formatItem.foreground, Commons.Color.accent)
          : "transparent"

    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
      width: Commons.Style.space(18)
      anchors.left: parent.left
      anchors.leftMargin: Commons.Style.space(10)
      anchors.verticalCenter: parent.verticalCenter
      text: formatItem.selected ? "✓" : ""
      color: formatItem.foreground
      font.family: formatItem.fontFamily
      font.pixelSize: Commons.Style.font.body
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }

    Column {
      id: labels
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: Commons.Style.space(40)
      anchors.rightMargin: Commons.Style.space(10)
      anchors.verticalCenter: parent.verticalCenter
      spacing: Commons.Style.space(2)

      Text {
        text: formatItem.label
        color: formatItem.foreground
        font.family: formatItem.fontFamily
        font.pixelSize: Commons.Style.font.body
      }

      Text {
        text: formatItem.example
        color: formatItem.foreground
        opacity: 0.62
        font.family: formatItem.fontFamily
        font.pixelSize: Commons.Style.font.caption
      }
    }

    MouseArea {
      id: mouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: formatItem.clicked()
      onEntered: formatItem.hovered(true)
      onExited: formatItem.hovered(false)
    }
  }

  ThemeUi.KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Commons.Style.space(240))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    ThemeUi.PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (dy !== 0) root.moveFocus(dy)
      }
      onActivateRequested: root.activateFocused()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(text) {
        var key = String(text || "").toLowerCase()
        if (key === "x" || key === "1") root.chooseFormat("hex")
        else if (key === "r" || key === "2") root.chooseFormat("rgb")
        else if (key === "h" || key === "3") root.chooseFormat("hsl")
      }

      Column {
        id: content
        width: parent.width
        spacing: Commons.Style.space(4)

        Text {
          width: parent.width
          text: "复制颜色格式"
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Commons.Style.font.caption
          opacity: 0.68
          leftPadding: Commons.Style.space(10)
          bottomPadding: Commons.Style.space(4)
        }

        FormatItem {
          width: parent.width
          formatValue: "hex"
          label: "HEX"
          example: "#1E90FF"
          selected: root.selectedFormat === formatValue
          hasCursor: root.focusIndex === 0
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: root.chooseFormat(formatValue)
          onHovered: function(hovered) { if (hovered) root.focusIndex = 0 }
        }

        FormatItem {
          width: parent.width
          formatValue: "rgb"
          label: "RGB"
          example: "rgb(30, 144, 255)"
          selected: root.selectedFormat === formatValue
          hasCursor: root.focusIndex === 1
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: root.chooseFormat(formatValue)
          onHovered: function(hovered) { if (hovered) root.focusIndex = 1 }
        }

        FormatItem {
          width: parent.width
          formatValue: "hsl"
          label: "HSL"
          example: "hsl(210, 100%, 56%)"
          selected: root.selectedFormat === formatValue
          hasCursor: root.focusIndex === 2
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: root.chooseFormat(formatValue)
          onHovered: function(hovered) { if (hovered) root.focusIndex = 2 }
        }
      }
    }
  }
}

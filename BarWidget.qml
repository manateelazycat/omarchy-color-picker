// SPDX-License-Identifier: GPL-3.0-only

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.manateelazycat.color-picker"

  property bool pickPending: false
  property string lastColor: ""
  property string pickerError: ""

  readonly property string controlPath: root.localPath(Qt.resolvedUrl("scripts/color-pickerctl"))
  readonly property string activeFormat: root.normalizeFormat(root.setting("format", "hex"))
  readonly property bool pickerBusy: root.pickPending || pickerProc.running
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property bool popoutSwitchClosing: panelLoader.item
    ? panelLoader.item.popoutSwitchClosing === true
    : false

  function localPath(url) {
    var value = String(url || "")
    if (value.indexOf("file://") === 0) value = value.substring(7)
    try { return decodeURIComponent(value) } catch (error) { return value }
  }

  function normalizeFormat(value) {
    var normalized = String(value || "").toLowerCase()
    return normalized === "rgb" || normalized === "hsl" ? normalized : "hex"
  }

  function formatLabel(value) {
    return root.normalizeFormat(value).toUpperCase()
  }

  function setFormat(value) {
    var normalized = root.normalizeFormat(value)
    var entry = { id: root.moduleName }
    for (var key in root.settings) if (key !== "id") entry[key] = root.settings[key]
    entry.format = normalized

    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
    root.injectPanel()
    return normalized
  }

  function startPicking() {
    if (root.pickerBusy) return
    root.pickerError = ""
    root.pickPending = true
    if (root.opened) root.close()
    pickDelay.restart()
  }

  function runPicker() {
    root.pickPending = false
    if (pickerProc.running) return
    pickerProc.command = [root.controlPath, "pick", root.activeFormat]
    pickerProc.running = true
  }

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
    if (target.applyFormat) target.applyFormat(root.activeFormat)
  }

  function open() {
    if (panelLoader.item) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item) panelLoader.item.close()
  }

  function togglePanel() {
    if (panelLoader.item) panelLoader.item.toggle()
  }

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()
  onActiveFormatChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  Timer {
    id: pickDelay
    interval: 100
    onTriggered: root.runPicker()
  }

  Process {
    id: pickerProc

    stdout: StdioCollector {
      id: pickerOutput
      waitForEnd: true
    }

    stderr: StdioCollector {
      id: pickerErrors
      waitForEnd: true
    }

    onExited: function(exitCode) {
      var color = String(pickerOutput.text || "").trim()
      var error = String(pickerErrors.text || "").trim()
      if (exitCode === 0 && color !== "") {
        root.lastColor = color
        root.pickerError = ""
      } else if (exitCode !== 0 && error !== "") {
        root.pickerError = error
      }
    }
  }

  IpcHandler {
    target: "io.github.manateelazycat.color-picker"

    function pick(): void { root.startPicking() }
    function currentFormat(): string { return root.activeFormat }
    function setFormat(value: string): string { return root.setFormat(value) }
    function lastPickedColor(): string { return root.lastColor }
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.togglePanel() }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰃉"
    active: root.pickerBusy
    tooltipText: root.pickerBusy
      ? "正在取色…\n点击颜色完成，按 Esc 取消"
      : root.pickerError !== ""
        ? "取色失败：" + root.pickerError + "\n左键重试 · 右键选择格式"
        : "取色器 · " + root.formatLabel(root.activeFormat)
          + "\n左键取色 · 右键选择格式"
          + (root.lastColor !== "" ? "\n上次复制：" + root.lastColor : "")

    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.togglePanel()
      else if (buttonCode === Qt.LeftButton) root.startPicking()
    }
  }
}

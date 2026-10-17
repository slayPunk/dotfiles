import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../"
import "../reusables"

Item {
    id: root
    property var panel
    readonly property bool active: !!panel && panel.visible
    property var readings: ({})
    implicitHeight: s(92)

    function s(value) { return panel ? panel.s(value) : Scaler.s(value); }
    function refresh() { if (active && !reader.running) reader.running = true; }

    onActiveChanged: {
        if (active) refresh();
        else reader.running = false;
    }
    Component.onCompleted: refresh()

    Process {
        id: reader
        command: ["python3", Caching.serpantinumDir + "/scripts/hardware-sensors.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim()) return;
                try { root.readings = JSON.parse(text); }
                catch (error) { console.warn("Could not read hardware sensors:", error); }
            }
        }
    }

    Timer {
        interval: 3000
        repeat: true
        running: root.active
        onTriggered: root.refresh()
    }

    RowLayout {
        anchors.fill: parent
        spacing: root.s(5)

        Repeater {
            model: [
                { name: "CPU", icon: "󰻠", temperature: root.readings.cpu_temp, rpm: root.readings.cpu_fan_rpm, sleeping: false, accent: ThemeBackend.peach },
                { name: "GPU", icon: "󰢮", temperature: root.readings.gpu_temp, rpm: root.readings.gpu_fan_rpm, sleeping: root.readings.gpu_state === "sleep", accent: ThemeBackend.sapphire }
            ]
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: root.panel ? root.panel.boxRadius : ThemeBackend.borderRadius
                color: cardGlass.active ? "transparent" : ThemeBackend.faded(Qt.darker(ThemeBackend.surface0, 1.04))

                GlassFill {
                    id: cardGlass
                    anchors.fill: parent
                    radius: parent.radius
                    tintColor: ThemeBackend.surface0
                    tintAmount: 0.3
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.s(10)
                    spacing: root.s(4)

                    RowLayout {
                        spacing: root.s(6)
                        Text {
                            text: modelData.icon
                            color: modelData.accent
                            font.family: ThemeBackend.iconFont
                            font.pixelSize: root.s(16)
                        }
                        Text {
                            text: modelData.name
                            color: ThemeBackend.subtext0
                            font.family: ThemeBackend.fontFamily
                            font.pixelSize: root.s(11)
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: modelData.sleeping ? I18n.t("syspanel.sensors.sleeping", "Asleep")
                                : (modelData.temperature !== undefined && modelData.temperature !== null ? modelData.temperature + "°C" : "—")
                            color: ThemeBackend.text
                            font.family: ThemeBackend.fontFamily
                            font.pixelSize: root.s(21)
                            font.weight: Font.DemiBold
                        }
                    }

                    RowLayout {
                        spacing: root.s(6)
                        Text {
                            text: "󰈐"
                            color: ThemeBackend.subtext0
                            font.family: ThemeBackend.iconFont
                            font.pixelSize: root.s(14)
                        }
                        Text {
                            text: (modelData.rpm !== undefined && modelData.rpm !== null ? modelData.rpm : "—")
                                + " " + I18n.t("syspanel.sensors.rpm", "RPM")
                            color: ThemeBackend.subtext0
                            font.family: ThemeBackend.fontFamily
                            font.pixelSize: root.s(11)
                        }
                    }
                }
            }
        }
    }
}

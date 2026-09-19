pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.workspace.dbus as DBus
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property int currentIndex: desktopInfo.desktopIds.indexOf(desktopInfo.currentDesktop)

    preferredRepresentation: fullRepresentation

    TaskManager.VirtualDesktopInfo {
        id: desktopInfo
    }

    function switchTo(index) {
        const count = desktopInfo.numberOfDesktops;
        if (Plasmoid.configuration.wrapScrolling) {
            index = (index % count + count) % count;
        } else if (index < 0 || index >= count) {
            return;
        }
        DBus.SessionBus.asyncCall({
            service: "org.kde.KWin",
            path: "/KWin",
            iface: "org.kde.KWin",
            member: "setCurrentDesktop",
            arguments: [index + 1],
            // signature covers the whole argument list; bare "i" sends no args
            signature: "(i)"
        });
    }

    fullRepresentation: MouseArea {
        id: rep

        readonly property real boxSize: Plasmoid.configuration.boxSize > 0
            ? Plasmoid.configuration.boxSize
            : Math.max(
                Kirigami.Units.gridUnit,
                (root.vertical ? width : height) - Kirigami.Units.smallSpacing * 2)

        readonly property int fontPixelSize: Math.max(8, Math.round(boxSize * Plasmoid.configuration.fontPercent / 100))

        // keep the padding even at minimum size so a crowded panel doesn't
        // crush the boxes flush against their neighbors
        readonly property real contentWidth: grid.implicitWidth + Kirigami.Units.smallSpacing * 2
        readonly property real contentHeight: grid.implicitHeight + Kirigami.Units.smallSpacing * 2

        Layout.minimumWidth: root.vertical ? 0 : contentWidth
        Layout.preferredWidth: root.vertical ? 0 : contentWidth
        Layout.minimumHeight: root.vertical ? contentHeight : 0
        Layout.preferredHeight: root.vertical ? contentHeight : 0

        // accumulate to full notches so touchpads don't skip desktops
        property real wheelAccum: 0
        onWheel: wheel => {
            wheelAccum += wheel.angleDelta.y;
            const steps = Math.trunc(wheelAccum / 120);
            if (steps !== 0) {
                wheelAccum -= steps * 120;
                root.switchTo(root.currentIndex - steps);
            }
        }

        Grid {
            id: grid
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing
            columns: root.vertical ? 1 : desktopInfo.numberOfDesktops

            Repeater {
                model: desktopInfo.numberOfDesktops

                Rectangle {
                    id: box

                    required property int index
                    readonly property bool active: index === root.currentIndex

                    width: rep.boxSize
                    height: rep.boxSize
                    radius: height * Plasmoid.configuration.radiusPercent / 100
                    color: active ? Kirigami.Theme.highlightColor
                                  : Qt.alpha(Kirigami.Theme.highlightColor, 0)
                    border.width: 1
                    border.color: active ? Kirigami.Theme.highlightColor
                                         : Qt.alpha(Kirigami.Theme.textColor, 0.4)

                    Behavior on color {
                        ColorAnimation { duration: Kirigami.Units.shortDuration }
                    }

                    PlasmaComponents3.Label {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: box.index + 1
                        color: box.active ? Kirigami.Theme.highlightedTextColor
                                          : Kirigami.Theme.textColor
                        font.family: Kirigami.Theme.defaultFont.family
                        font.pixelSize: rep.fontPixelSize
                        font.bold: box.active
                    }

                    PlasmaCore.ToolTipArea {
                        anchors.fill: parent
                        mainText: desktopInfo.desktopNames[box.index] || ""

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.switchTo(box.index)
                        }
                    }
                }
            }
        }
    }
}

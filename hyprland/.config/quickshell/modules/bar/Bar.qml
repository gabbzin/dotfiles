import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs
import "."
import "../controlCenter"
import "../notificationCenter"

PanelWindow {
    id: root
    property bool controlCenterOpen: false
    property bool notificationCenterOpen: false

    // ── LayerShell config ──
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: 0
        left: 0
        right: 0
        bottom: 0
    }
    exclusionMode: ExclusionMode.Auto
    aboveWindows: true
    color: Theme.barBg

    implicitHeight: Theme.barHeight

    // ── Conteúdo da barra ──
    RowLayout {
        id: barContent
        anchors.fill: parent
        anchors.leftMargin: Theme.barPaddingH
        anchors.rightMargin: Theme.barPaddingH
        anchors.topMargin: Theme.barPaddingV
        anchors.bottomMargin: Theme.barPaddingV
        spacing: Theme.barSpacing

        // ── LEFT ──
        RowLayout {
            id: leftSection
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            spacing: Theme.spacingM

            Workspaces {
                id: workspaces
            }
            Rectangle { width: 1; height: 16; color: Theme.surface0 }
            ActiveWindow {
                id: activeWindow
            }
        }

        // ── CENTER ── (expande e centraliza)
        RowLayout {
            id: centerSection
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            spacing: Theme.spacingM

            Item { Layout.fillWidth: true } // spacer left

            Media {
                id: media
            }
            Rectangle {
                width: 1; height: 16; color: Theme.surface0
                visible: media.visible
            }
            Clock {
                id: clock
            }

            Item { Layout.fillWidth: true } // spacer right
        }

        // ── RIGHT ──
        Item {
            id: rightSectionWrapper
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            implicitWidth: rightSection.implicitWidth
            implicitHeight: rightSection.implicitHeight

            RowLayout {
                id: rightSection
                anchors.centerIn: parent
                spacing: Theme.spacingS

                SystemStatus {
                    id: systemStatus
                }
            }

            // área clicável (fase 3 abre ControlCenter)
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.controlCenterOpen = !root.controlCenterOpen
            }
        }
    }

    // borda inferior sutil
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.barBorder
    }

    // ── Control Center (PopupWindow ancorado) ──
    ControlCenter {
        id: controlCenter
        barWindow: root
        isOpen: root.controlCenterOpen
        onIsOpenChanged: {
            root.controlCenterOpen = isOpen
            if (isOpen) root.notificationCenterOpen = false
        }
    }

    // ── Notification Center (PopupWindow ancorado) ──
    NotificationCenter {
        id: notificationCenter
        barWindow: root
        isOpen: root.notificationCenterOpen
        onIsOpenChanged: {
            root.notificationCenterOpen = isOpen
            if (isOpen) root.controlCenterOpen = false
        }
    }
}

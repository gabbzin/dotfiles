import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import qs

Rectangle {
    id: root
    required property var notification
    implicitHeight: contentLayout.implicitHeight + Theme.spacingM * 2
    radius: Theme.radiusS
    color: Theme.surface0
    border.color: Theme.surface1
    border.width: 1

    // cor por urgência
    readonly property color urgencyColor: {
        if (!notification) return Theme.surface0;
        switch (notification.urgency) {
            case NotificationUrgency.Critical: return Theme.red;
            case NotificationUrgency.Low: return Theme.surface1;
            default: return Theme.accent;
        }
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: Theme.spacingS
        spacing: Theme.spacingS

        // barra lateral de urgência
        Rectangle {
            width: 4
            Layout.fillHeight: true
            radius: 2
            color: root.urgencyColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingS
                Text {
                    text: notification ? (notification.appName || "App") : ""
                    color: Theme.subtext1
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    // timestamp relativo simplificado
                    text: notification ? Qt.formatDateTime(new Date(notification.time * 1000), "hh:mm") : ""
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
                Text {
                    text: "󰅖"
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: notification.dismiss()
                    }
                }
            }

            Text {
                text: notification ? (notification.summary || "") : ""
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                Layout.fillWidth: true
                textFormat: Text.PlainText
            }

            Text {
                text: notification ? (notification.body || "") : ""
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: notification && notification.body
                textFormat: Text.PlainText
            }

            // Actions
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: notification && notification.actions && notification.actions.length > 0
                Repeater {
                    model: notification ? notification.actions : []
                    delegate: Rectangle {
                        height: 28
                        implicitWidth: actionText.implicitWidth + 16
                        radius: Theme.radiusS
                        color: Theme.surface1
                        border.color: Theme.surface2
                        Text {
                            id: actionText
                            anchors.centerIn: parent
                            text: modelData.text || "Action"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.invoke()
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import qs

RowLayout {
    id: root
    property string title: ""
    property string icon: ""
    property string summary: ""
    Layout.fillWidth: true
    spacing: Theme.spacingS

    Text {
        text: root.icon
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        Layout.alignment: Qt.AlignVCenter
    }
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        Text {
            text: root.title
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
        }
        Text {
            text: root.summary
            color: Theme.subtext0
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }
}

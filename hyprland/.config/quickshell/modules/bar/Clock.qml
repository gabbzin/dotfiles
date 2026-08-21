import Quickshell
import QtQuick
import QtQuick.Layouts
import qs

Item {
    id: root
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: Theme.spacingS

        Text {
            id: clockText
            text: Qt.formatDateTime(clock.date, Theme.clockFormat)
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // Área clicável — futuro: abrir calendário/painel
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: console.log("Clock clicked — futuro: calendário")
    }
}

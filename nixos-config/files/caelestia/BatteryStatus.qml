// DIVERGÊNCIA NixOS: porcentagem em vez do ícone (upstream não tem chave
// de config pra isso). Mantido: cor de erro abaixo de 20% na bateria.
// Se upstream mover o arquivo, o build quebra avisando (revisar o patch).
import QtQuick
import Quickshell.Services.UPower
import qs.components
import qs.services
import qs.utils

StyledText {
    required property color colour

    readonly property bool charging: [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged, UPowerDeviceState.PendingCharge].includes(UPower.displayDevice.state)
    readonly property real percent: UPower.displayDevice.percentage

    animate: true
    text: {
        if (!UPower.displayDevice.isLaptopBattery)
            return "";
        return Math.round(percent * 100) + "%";
    }
    // Carregando = verde, perto de descarregar (<20% fora da tomada) = vermelho.
    color: charging ? "#4ade80" : (!UPower.onBattery || percent > 0.2 ? colour : Colours.palette.m3error)
}

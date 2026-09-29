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

    animate: true
    text: {
        if (!UPower.displayDevice.isLaptopBattery)
            return "";
        return Math.round(UPower.displayDevice.percentage * 100) + "%";
    }
    color: !UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? colour : Colours.palette.m3error
}

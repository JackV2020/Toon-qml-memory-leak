import QtQuick 2.1
import qb.components 1.0

Tile {
    id                          : xmlHttpRequestHowToTile
        
// --- Tile button

    YaLabel {
        id                      : toggleBasicSavingButton
        buttonText              : app.tileInfo
        height                  : parent.height - 20
        width                   : parent.width - 20
        buttonActiveColor       : app.basicSaving ? "red" : "green"
        buttonSelectedColor     : buttonActiveColor
        hoveringEnabled         : false
        selected                : true
        enabled                 : true
        textColor               : "black"
        anchors {
            verticalCenter      : parent.verticalCenter
            horizontalCenter    : parent.horizontalCenter
        }
        onClicked: {
            app.basicSaving = ! app.basicSaving
            app.updateTile()
            app.debug && app.log("app.basicSaving : "+app.basicSaving)
        }
    }
    
}

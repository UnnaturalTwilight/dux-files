pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.Services
import qs.DCommon.Widgets
import qs.DCommon.FileBrowser

Row {
    id: status

    property int total: 0
    property int hidden: 0
    property bool compact: false
    property bool showClipboard: true
    property string hint: ""
    property real room: Number.POSITIVE_INFINITY
    property bool showSelection: true
    property int selectionCount: 0
    property int selectionBytes: 0
    property bool selectionActions: false

    readonly property int clipboardCount: ClipboardService.paths.length
    readonly property real textRoom: room - (chip.visible ? chip.width + spacing : 0)
    readonly property string itemsText: FileFormat.count(total)
    readonly property string countText: {
        if (hidden <= 0)
            return itemsText;
        return I18n.tr("%1 · %2", "folder status: item count then hidden count").arg(itemsText).arg(I18n.tr("%1 hidden", "count of hidden items left out of a folder listing").arg(hidden));
    }
    readonly property string shownText: {
        if (hint !== "")
            return hint;
        if (total <= 0 && hidden <= 0)
            return "";
        if (Math.ceil(countMetrics.advanceWidth) <= textRoom)
            return countText;
        return Math.ceil(itemsMetrics.advanceWidth) <= textRoom ? itemsText : "";
    }
    readonly property string clipboardText: {
        switch (true) {
        case ClipboardService.cut && clipboardCount === 1:
            return I18n.tr("1 item cut", "clipboard indicator for a single cut item");
        case ClipboardService.cut:
            return I18n.tr("%1 items cut", "clipboard indicator for cut items").arg(clipboardCount);
        case clipboardCount === 1:
            return I18n.tr("1 item copied", "clipboard indicator for a single copied item");
        default:
            return I18n.tr("%1 items copied", "clipboard indicator for copied items").arg(clipboardCount);
        }
    }
    readonly property string selectionText: {
        const items = I18n.tr("%1 selected", "count of selected items").arg(selectionCount);
        return selectionBytes < 0 ? items : `${items} · ${FileFormat.size(selectionBytes)}`;
    }

    signal selectionCleared
    // signal selectionActionRequested(string action)

    spacing: Theme.spacingS

    component Measure: StyledTextMetrics {
        font.pixelSize: Theme.fontSizeSmall
    }

    Measure {
        id: countMetrics

        text: status.countText
    }

    Measure {
        id: itemsMetrics

        text: status.itemsText
    }

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        visible: text !== "" && status.textRoom > 0
        width: Math.min(implicitWidth, Math.max(0, status.textRoom))
        text: status.shownText
        color: Theme.surfaceVariantText
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.NoWrap
    }

    Rectangle {
        id: selectionChip

        anchors.verticalCenter: parent.verticalCenter
        visible: status.showSelection && status.selectionCount > 1
        width: selectionRow.implicitWidth + FileBrowserMetrics.pathPillPadding + Theme.spacingXXS
        height: FileBrowserMetrics.pathPillHeight
        radius: FileBrowserMetrics.pathPillRadius
        color: Theme.chipLayer
        border.width: Theme.outlineWidth
        border.color: Theme.outlineVariant
        Accessible.role: Accessible.StaticText
        Accessible.name: status.selectionText

        Row {
            id: selectionRow

            anchors.left: parent.left
            anchors.leftMargin: FileBrowserMetrics.pathPillPadding
            anchors.verticalCenter: parent.verticalCenter
            spacing: FileBrowserMetrics.pathPillSpacing

            DIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: "select_all"
                size: FileBrowserMetrics.pathIconSize
                color: Theme.primary
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: selectionBytes < 0 ? selectionCount : `${selectionCount} · ${FileFormat.size(selectionBytes)}`
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Theme.fontWeightMedium
                font.family: Theme.monoFontFamily
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }

            DActionButton {
                id: clearSelection
                anchors.verticalCenter: parent.verticalCenter
                buttonSize: FileBrowserMetrics.pathPillHeight - Theme.spacingXXS * 2
                iconName: "close"
                iconSize: Theme.iconSizeSmall
                iconColor: Theme.surfaceVariantText
                tooltipText: I18n.tr("Clear the selection", "tooltip on the button clearing the file selection")
                tooltipSide: "top"
                onClicked: status.selectionCleared()
            }

            // Row {
            //     Repeater {
            //         model: ["copy", "cut", "trash"]

            //         DActionButton {
            //             required property string modelData

            //             anchors.verticalCenter: parent.verticalCenter
            //             buttonSize: FileBrowserMetrics.pathPillHeight - Theme.spacingXXS * 2
            //             iconName: FileActions.icon(modelData)
            //             iconSize: Theme.iconSizeSmall
            //             iconColor: modelData === "trash" ? Theme.error : Theme.surfaceVariantText
            //             tooltipText: FileActions.label(modelData)
            //             tooltipSide: "top"
            //             onClicked: status.selectionActionRequested(modelData)
            //         }
            //     }
            // }
        }
    }

    Rectangle {
        id: chip

        anchors.verticalCenter: parent.verticalCenter
        visible: status.showClipboard && status.clipboardCount > 0
        width: chipRow.implicitWidth + FileBrowserMetrics.pathPillPadding + Theme.spacingXXS
        height: FileBrowserMetrics.pathPillHeight
        radius: FileBrowserMetrics.pathPillRadius
        color: Theme.chipLayer
        border.width: Theme.outlineWidth
        border.color: Theme.outlineVariant
        Accessible.role: Accessible.StaticText
        Accessible.name: status.clipboardText

        Row {
            id: chipRow

            anchors.left: parent.left
            anchors.leftMargin: FileBrowserMetrics.pathPillPadding
            anchors.verticalCenter: parent.verticalCenter
            spacing: FileBrowserMetrics.pathPillSpacing

            DIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: ClipboardService.cut ? "content_cut" : "content_copy"
                size: FileBrowserMetrics.pathIconSize
                color: Theme.primary
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: status.clipboardCount
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Theme.fontWeightMedium
                font.family: Theme.monoFontFamily
            }

            DActionButton {
                anchors.verticalCenter: parent.verticalCenter
                buttonSize: FileBrowserMetrics.pathPillHeight - Theme.spacingXXS * 2
                iconName: "close"
                iconSize: Theme.iconSizeSmall
                iconColor: Theme.surfaceVariantText
                tooltipText: I18n.tr("Clear the clipboard", "tooltip on the button dropping the copied or cut items")
                tooltipSide: "top"
                onClicked: ClipboardService.clear()
            }
        }
    }
}

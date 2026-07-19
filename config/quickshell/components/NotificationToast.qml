import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import qs

// One notification toast: slides in from the right, auto-dismisses after its
// lifetime (paused while hovered), and on close collapses its height so toasts
// below slide up. Colour follows urgency. The delegate reserves `card height +
// gap` and clips; the card wipes in horizontally, the box height animates on
// close to drive the reflow.
Item {
    id: root

    required property var notif        // the Notification object

    readonly property color accent: Theme.notifAccent(notif.urgency)
    // Critical stays until dismissed; others honour the sender's expiry (ms) or
    // fall back to the configured default.
    readonly property int lifetime: {
        if (notif.urgency === NotificationUrgency.Critical)
            return 0;
        const t = notif.expireTimeout;
        return t > 0 ? t : Notifs.defaultTimeout;
    }
    // A HoverHandler, not the MouseAreas' containsMouse: hover is exclusive
    // between stacked MouseAreas, so hovering a chip would un-hover the card and
    // let it expire mid-aim.
    readonly property bool hovered: cardHover.hovered

    property bool shown: false
    property bool closing: false
    property bool expired: false

    readonly property string iconSource: notif.image !== ""
        ? notif.image
        : Icons.resolve([notif.appIcon, notif.desktopEntry, notif.appName], "")

    // Sender actions other than the default render as chips below the body.
    readonly property var extraActions:
        [...notif.actions].filter(a => a.identifier !== "default")

    width: card.width
    height: closing ? 0 : card.height + Theme.notifGap
    clip: true

    // Only the close collapse animates (drives the reflow), armed imperatively
    // in close() before `closing` flips the height to 0. Smooth in-out, not
    // emphasized-decelerate — a decelerate front-loads the travel and reads as
    // the stack jumping.
    Behavior on height {
        id: collapse
        enabled: false
        NumberAnimation {
            duration: 240
            easing.type: Easing.InOutCubic
        }
    }

    function close(byTimeout: bool): void {
        if (closing)
            return;
        collapse.enabled = true;
        expired = byTimeout === true;
        closing = true;      // slide card out + collapse height → others reflow up
        shown = false;
        drop.start();
    }

    // After the exit: report expire vs dismiss to the sender, then drop the toast.
    Timer {
        id: drop
        interval: 260
        onTriggered: {
            if (root.expired)
                root.notif.expire();
            else
                root.notif.dismiss();
            Notifs.forget(root.notif);
        }
    }

    // Sender closed it out from under us while it's still showing — drop it.
    Connections {
        target: root.notif
        function onClosed(reason) {
            if (!root.closing)
                Notifs.forget(root.notif);
        }
    }

    // Dismiss-all (null) or this specific notification: animate out.
    Connections {
        target: Notifs
        function onCloseRequested(target) {
            if (!target || target.id === root.notif.id)
                root.close(false);
        }
    }

    // Auto-dismiss after the lifetime; hovering holds it open. Never armed for
    // critical (no expiry).
    Timer {
        interval: root.lifetime
        running: root.shown && !root.closing && root.lifetime > 0 && !root.hovered
        onTriggered: root.close(true)
    }

    Component.onCompleted: shown = true

    Rectangle {
        id: card
        width: Theme.notifWidth
        height: body.implicitHeight + 2 * Theme.notifPadding
        radius: Theme.popupRadius
        color: Theme.popupBg
        border.width: 1
        border.color: Theme.alpha(root.accent, 0.6)

        // Slide from the right + fade (clipped to a wipe-in). Easing is keyed off
        // `closing`, not `shown`: close() sets `closing` first, so keying off
        // `shown` would read its stale value and pick the entry curve for the exit.
        x: root.shown ? 0 : width + 8
        opacity: root.shown ? 1 : 0
        Behavior on x {
            NumberAnimation {
                duration: root.closing ? 260 : 320
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.closing
                    ? [0.3, 0.0, 0.8, 0.15, 1, 1]   // emphasized accelerate out
                    : [0.05, 0.7, 0.1, 1.0, 1, 1]   // emphasized decelerate in
            }
        }
        Behavior on opacity {
            NumberAnimation { duration: root.closing ? 200 : 220 }
        }

        HoverHandler { id: cardHover }

        MouseArea {
            id: cardMouse
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: mouse => {
                // Left-click invokes the default action then dismisses; other
                // buttons just dismiss.
                if (mouse.button === Qt.LeftButton) {
                    const def = root.notif.actions.find(a => a.identifier === "default");
                    if (def)
                        def.invoke();
                }
                root.close(false);
            }
        }

        Row {
            id: body
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.notifPadding
            }
            spacing: 11

            Item {
                id: iconWrap
                width: Theme.notifIconSize
                height: Theme.notifIconSize

                Image {
                    id: iconImg
                    anchors.fill: parent
                    source: root.iconSource
                    sourceSize.width: 2 * Theme.notifIconSize
                    sourceSize.height: 2 * Theme.notifIconSize
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    asynchronous: true
                    cache: true
                    visible: status === Image.Ready
                }

                // Generic bell glyph when no icon resolves.
                Text {
                    anchors.centerIn: parent
                    visible: iconImg.status !== Image.Ready
                    font.family: Theme.mdiFontFamily
                    font.pixelSize: Theme.notifIconSize - 4
                    color: root.accent
                    text: "\u{F009A}"
                }
            }

            Column {
                id: textCol
                width: parent.width - iconWrap.width - parent.spacing
                spacing: 3

                Text {
                    id: appName
                    width: parent.width - 20   // leave room for the hover close ×
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: Font.Medium
                    color: root.accent
                    textFormat: Text.PlainText
                    text: root.notif.appName || root.notif.desktopEntry || "Notification"
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                    color: Theme.text
                    textFormat: Text.PlainText
                    text: root.notif.summary
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    wrapMode: Text.Wrap
                    maximumLineCount: 5
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: Theme.subtext0
                    // Body may carry limited freedesktop markup (<b>, <i>, links).
                    textFormat: Text.StyledText
                    linkColor: Theme.blue
                    text: root.notif.body
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }

                // Non-default actions as chips; above the card MouseArea, so
                // chip clicks don't trigger the default action.
                Flow {
                    width: parent.width
                    spacing: 6
                    visible: root.extraActions.length > 0

                    Repeater {
                        model: root.extraActions

                        Rectangle {
                            id: actionChip
                            required property var modelData

                            width: actionLabel.implicitWidth + 18
                            height: 22
                            radius: 11
                            color: actionMouse.containsMouse
                                ? Theme.alpha(root.accent, 0.18)
                                : Theme.chipBg(root.accent, true)
                            border.width: 1
                            border.color: Theme.chipBorder(root.accent, true)

                            Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }

                            Text {
                                id: actionLabel
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.popupCaptionSize
                                color: root.accent
                                textFormat: Text.PlainText
                                text: actionChip.modelData.text
                            }

                            MouseArea {
                                id: actionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    actionChip.modelData.invoke();
                                    root.close(false);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Close affordance, revealed on hover.
        Text {
            id: closeBtn
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 6
                rightMargin: 12
            }
            text: "×"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 4
            color: closeMouse.containsMouse ? Theme.text : Theme.overlay1
            opacity: root.hovered ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                onClicked: root.close(false)
            }
        }
    }
}

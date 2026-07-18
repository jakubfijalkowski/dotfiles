import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import qs

// One notification toast. It slides in from the right, auto-dismisses after its
// lifetime (paused while hovered), and on the way out collapses its own height
// so every toast below slides up to fill the gap. Colour follows urgency, in
// the bar's neon-outline language.
//
// Layout note: the delegate reserves `card height + gap` and clips to it. The
// card slides horizontally inside that box (a wipe from the right edge), while
// the box's height is what animates on close to drive the reflow.
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
    // A HoverHandler rather than the MouseAreas' containsMouse: hover is
    // exclusive between stacked MouseAreas, so hovering an action chip would
    // un-hover the card and let the toast expire mid-aim.
    readonly property bool hovered: cardHover.hovered

    property bool shown: false
    property bool closing: false
    property bool expired: false

    readonly property string iconSource: notif.image !== ""
        ? notif.image
        : Icons.resolve([notif.appIcon, notif.desktopEntry, notif.appName], "")

    // Sender actions other than the default (which lives on the card itself)
    // render as chips below the body.
    readonly property var extraActions:
        [...notif.actions].filter(a => a.identifier !== "default")

    width: card.width
    height: closing ? 0 : card.height + Theme.notifGap
    clip: true

    // Only the close collapse is animated — that's what makes the toasts below
    // slide up. Entry is a pure horizontal slide (no vertical motion), so this
    // Behavior is armed imperatively in close() to guarantee it's enabled
    // before `closing` flips the height binding to 0. The ease is a smooth
    // in-out (NOT the emphasized-decelerate used for entrances): a decelerate
    // front-loads most of the travel into the first frame, which reads as the
    // stack jumping rather than gliding as the gap closes.
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

    // After the exit animation: tell the sender (expire vs dismiss reports the
    // right close reason) and drop this toast from the display list, which
    // destroys the delegate.
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

    // Dismiss-all (target null) or dismiss-last/-specific (target === this
    // notification): animate out on request.
    Connections {
        target: Notifs
        function onCloseRequested(target) {
            if (!target || target.id === root.notif.id)
                root.close(false);
        }
    }

    // Auto-dismiss after the lifetime. Hovering holds the toast open (the timer
    // stops and restarts fresh on leave). Never armed for no-expiry (critical).
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

        // Slide from the right + fade. Clipped by the delegate's `clip` to a
        // wipe-in from the right edge. The direction/easing is keyed off
        // `closing` (not `shown`): close() sets `closing` before `shown`, so
        // it's already settled when `shown` fires this Behavior — keying off
        // `shown` itself reads its stale pre-change value and picks the entry
        // curve for the exit, making the card lurch instead of easing out.
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
                // Left-click triggers the notification's default action (if any),
                // then dismisses; any other button just dismisses.
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

                // Generic bell glyph whenever no icon resolves (no source, or a
                // source that fails to load).
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
                    width: parent.width - 16   // leave room for the hover close ×
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

                // Non-default sender actions as chips in the urgency accent.
                // (This sits above the card's MouseArea, so chip clicks never
                // reach the default-action handler.)
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
                rightMargin: 8
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

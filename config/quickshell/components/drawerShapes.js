// Shared Canvas painting for the drawers (BarDrawer / EdgeDrawer): colour
// formatting, the two drawer outlines, and the neon seam trim laid along the
// edge where a drawer meets the bar.
.pragma library

// cubic-bezier quarter-circle constant
var K = 0.5523;

function css(c) {
    return "rgba(" + Math.round(c.r * 255) + ", " + Math.round(c.g * 255)
         + ", " + Math.round(c.b * 255) + ", " + c.a + ")";
}

// Drawer hanging below a pill: both top corners meet the bar through concave
// fillets, both bottom corners are free. Returns the seam's [x0, x1].
function barPath(ctx, width, height, rc, rb, ms, mb) {
    var k = K;
    var left = ms, right = width - ms;      // outer top corners, meet the bar
    var bl = ms + rc, br = width - ms - rc;  // straight body sides
    var top = 0, bottom = height - mb;

    ctx.beginPath();
    ctx.moveTo(left, top);
    ctx.bezierCurveTo(left + k * rc, top, bl, top + rc - k * rc, bl, top + rc);
    ctx.lineTo(bl, bottom - rb);
    ctx.arcTo(bl, bottom, bl + rb, bottom, rb);
    ctx.lineTo(br - rb, bottom);
    ctx.arcTo(br, bottom, br, bottom - rb, rb);
    ctx.lineTo(br, top + rc);
    ctx.bezierCurveTo(br, top + rc - k * rc, right - k * rc, top, right, top);
    ctx.closePath();
    return [left, right];
}

// Drawer hinged in the top-right corner: the top edge meets the bar, the right
// edge meets the screen and fillets into the bottom; the left side and the
// bottom-left corner are free. Returns the seam's [x0, x1].
function cornerPath(ctx, width, height, rc, rb, ms, mb) {
    var k = K;
    var top = 0, right = width;
    var bodyLeft = ms + rc;
    var bodyBottom = height - mb - rc;
    // The screen edge runs rc past the body bottom before it fillets in.
    var rightBottom = height - mb;

    ctx.beginPath();
    ctx.moveTo(ms, top);
    ctx.lineTo(right, top);
    ctx.lineTo(right, rightBottom);
    ctx.bezierCurveTo(right, rightBottom - k * rc, right - rc + k * rc, bodyBottom, right - rc, bodyBottom);
    ctx.lineTo(bodyLeft + rb, bodyBottom);
    ctx.arcTo(bodyLeft, bodyBottom, bodyLeft, bodyBottom - rb, rb);
    ctx.lineTo(bodyLeft, top + rc);
    ctx.bezierCurveTo(bodyLeft, top + rc - k * rc, ms + k * rc, top, ms, top);
    ctx.closePath();
    return [ms, right];
}

// Lay the accent seam along a horizontal edge x0..x1 at y: a soft glow bleeding
// into the body plus a crisp core. Caller must clip to the drawer shape first so
// the trim can't spill past the fillets. `theme` is the Theme singleton (a
// .pragma library has no QML context of its own).
function paintSeam(ctx, accent, x0, x1, y, theme) {
    var argb = Math.round(accent.r * 255) + ", " + Math.round(accent.g * 255)
             + ", " + Math.round(accent.b * 255);
    var glow = ctx.createLinearGradient(0, y, 0, y + theme.drawerSeamGlow);
    glow.addColorStop(0, "rgba(" + argb + ", " + theme.drawerSeamGlowAlpha + ")");
    glow.addColorStop(1, "rgba(" + argb + ", 0)");
    ctx.fillStyle = glow;
    ctx.fillRect(x0, y, x1 - x0, theme.drawerSeamGlow);
    ctx.fillStyle = "rgba(" + argb + ", " + theme.drawerSeamLineAlpha + ")";
    ctx.fillRect(x0, y, x1 - x0, theme.drawerSeamLine);
}

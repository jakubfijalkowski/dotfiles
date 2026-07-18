// Shared Canvas painting for the drawers (BarDrawer / EdgeDrawer): colour
// formatting and the neon seam trim laid along the edge where a drawer
// meets the bar.
.pragma library

// cubic-bezier quarter-circle constant
var K = 0.5523;

function css(c) {
    return "rgba(" + Math.round(c.r * 255) + ", " + Math.round(c.g * 255)
         + ", " + Math.round(c.b * 255) + ", " + c.a + ")";
}

// Lay the accent seam along a horizontal edge from x0..x1 at y: a soft glow
// bleeding down into the body plus a crisp core. The top edge is two
// independently-blurred surfaces meeting, which leaves a faint mismatch
// line; rather than hide it, own it — the intentional line dominates the
// accidental one and the drawer reads as the pill's colour flowing out.
// The caller must have clipped the context to the drawer shape first so the
// trim can't spill past the fillets. `theme` is the Theme singleton (a
// .pragma library file has no QML context of its own).
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

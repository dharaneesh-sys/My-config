import QtQuick

import qs.tokens

Text {
    id: shellText

    // ═══════════════════════════════════════════════════════════════
    //  ShellText
    //
    //  Themed text component. Pick a semantic role and all
    //  typography properties are set from the token system.
    //  Zero logic — pure presentation.
    //
    //  Roles: heading, subheading, title, subtitle, body,
    //         bodyBold, caption, captionMedium, overline, button,
    //         appLabel, sliderValue, mono, monoCaption
    // ═══════════════════════════════════════════════════════════════

    // ── Role enum ──────────────────────────────────────────────────
    enum Role {
        Heading,
        Subheading,
        Title,
        Subtitle,
        Body,
        BodyBold,
        Caption,
        CaptionMedium,
        Overline,
        Button,
        AppLabel,
        SliderValue,
        Mono,
        MonoCaption
    }

    // ── Configurable properties ────────────────────────────────────
    property int role: ShellText.Role.Body
    property color textColor: role === ShellText.Role.Caption
                              || role === ShellText.Role.CaptionMedium
                              || role === ShellText.Role.Overline
                              ? Colors.fgMuted
                              : Colors.fg

    // ── Resolved style ─────────────────────────────────────────────
    readonly property QtObject _style: {
        switch (role) {
        case ShellText.Role.Heading:       return Typography.heading
        case ShellText.Role.Subheading:    return Typography.subheading
        case ShellText.Role.Title:         return Typography.title
        case ShellText.Role.Subtitle:      return Typography.subtitle
        case ShellText.Role.Body:          return Typography.body
        case ShellText.Role.BodyBold:      return Typography.bodyBold
        case ShellText.Role.Caption:       return Typography.caption
        case ShellText.Role.CaptionMedium: return Typography.captionMedium
        case ShellText.Role.Overline:      return Typography.overline
        case ShellText.Role.Button:        return Typography.button
        case ShellText.Role.AppLabel:      return Typography.appLabel
        case ShellText.Role.SliderValue:   return Typography.sliderValue
        case ShellText.Role.Mono:          return Typography.mono
        case ShellText.Role.MonoCaption:   return Typography.monoCaption
        default:                           return Typography.body
        }
    }

    // ── Text config ────────────────────────────────────────────────
    color:           textColor
    font.family:    _style.family
    font.pixelSize: _style.size
    font.weight:    _style.weight
    font.letterSpacing: _style.tracking
    lineHeight:     _style.lineHeight
    lineHeightMode: Text.ProportionalHeight
}

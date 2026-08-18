import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central responsive helper — breakpoints and derived layout values so every
/// screen sizes consistently from phones up to large desktops.
class Responsive {
  // Breakpoints (logical px). The desktop breakpoint is 900 (not 1024) so the
  // full desktop layout also engages for desktop browsers and mobile "Desktop
  // site" mode (~980px), instead of falling back to the compact layout.
  static const double phone = 600;
  static const double tablet = 900;

  // Max width the app is allowed to occupy on very wide screens; keeps the
  // admin panel readable instead of stretching edge-to-edge on a monitor.
  // Sized for the desktop shell: 280px sidebar + ~1100px content.
  static const double maxContentWidth = 1400;

  static bool isPhone(BuildContext c) => MediaQuery.of(c).size.width < phone;
  static bool isTablet(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    return w >= phone && w < tablet;
  }
  static bool isDesktop(BuildContext c) => MediaQuery.of(c).size.width >= tablet;

  /// Number of columns for card grids given an available width.
  static int gridColumns(double w) {
    if (w >= 1240) return 5;
    if (w >= tablet) return 4;
    if (w >= phone) return 3;
    if (w >= 420) return 2;
    return 1;
  }

  /// Column count tuned for compact stat/quick-action tiles.
  static int compactColumns(double w) {
    if (w >= tablet) return 4;
    if (w >= phone) return 3;
    return 2;
  }

  /// Horizontal page padding that grows a little on larger canvases.
  static double pagePadding(double w) => w >= phone ? 24 : 16;
}

class AppColors {
  static bool _isDark = false;
  static bool get isDark => _isDark;
  static void setDark(bool v) { _isDark = v; }

  // ── Dristi Fashions light palette ──────────────────────────────────────────
  // Airy lavender canvas, pure-white cards, hairline lilac borders, and a calm
  // violet-tinted neutral text ramp (matches dristi-fashions.ai.studio).
  static const Color _lightBg = Color(0xFFF6F3FC);         // airy lavender canvas
  static const Color _lightBgAlt = Color(0xFFF3EBF8);      // input fills / tinted panels
  static const Color _lightSurface = Color(0xFFFFFFFF);    // cards
  static const Color _lightSurfaceAlt = Color(0xFFFEF7FF); // near-white lilac (flatter gradients)
  static const Color _lightSurfaceRaised = Color(0xFFFFFFFF);
  static const Color _lightBorder = Color(0xFFCBC3D7);     // visible lilac hairline
  static const Color _lightBorderLight = Color(0xFFE7E0ED);// subtle lilac hairline
  static const Color _lightTextPrimary = Color(0xFF1D1A23);// deep ink
  static const Color _lightTextSecondary = Color(0xFF494454);// muted slate
  static const Color _lightTextMuted = Color(0xFF7B7486);  // soft lilac-grey
  static const Color _lightOverlay = Color(0x26000000);
  static const Color _lightShimmer = Color(0xFFEDEAF8);

  static const Color _darkBg = Color(0xFF17132A);          // deep indigo-violet
  static const Color _darkBgAlt = Color(0xFF221B3D);
  static const Color _darkSurface = Color(0xFF221B3D);
  static const Color _darkSurfaceAlt = Color(0xFF2E2650);
  static const Color _darkSurfaceRaised = Color(0xFF3A3060);
  static const Color _darkBorder = Color(0xFF3A3060);
  static const Color _darkBorderLight = Color(0xFF2E2650);
  static const Color _darkTextPrimary = Color(0xFFF3F0FC);
  static const Color _darkTextSecondary = Color(0xFFB4A9D6);
  static const Color _darkTextMuted = Color(0xFF7C709F);
  static const Color _darkOverlay = Color(0x40FFFFFF);
  static const Color _darkShimmer = Color(0xFF2E2650);

  static Color get bg => _isDark ? _darkBg : _lightBg;
  static Color get bgAlt => _isDark ? _darkBgAlt : _lightBgAlt;
  static Color get surface => _isDark ? _darkSurface : _lightSurface;
  static Color get surfaceAlt => _isDark ? _darkSurfaceAlt : _lightSurfaceAlt;
  static Color get surfaceRaised => _isDark ? _darkSurfaceRaised : _lightSurfaceRaised;
  static Color get border => _isDark ? _darkBorder : _lightBorder;
  static Color get borderLight => _isDark ? _darkBorderLight : _lightBorderLight;
  static Color get textPrimary => _isDark ? _darkTextPrimary : _lightTextPrimary;
  static Color get textSecondary => _isDark ? _darkTextSecondary : _lightTextSecondary;
  static Color get textMuted => _isDark ? _darkTextMuted : _lightTextMuted;
  static Color get overlay => _isDark ? _darkOverlay : _lightOverlay;
  static Color get shimmer => _isDark ? _darkShimmer : _lightShimmer;

  // ── Dristi violet brand palette ─────────────────────────────────────────────
  // `coral` is the primary brand accent (branding, active states, buttons).
  // (Token names kept for a drop-in reskin; the values are the Dristi violet set.)
  static const Color coral = Color(0xFF6B38D4);   // primary violet
  static const Color coral80 = Color(0xFF8455EF); // hover / lighter violet
  static const Color coral40 = Color(0xFFCBB8F0); // soft violet
  static const Color coralDark = Color(0xFF4C1D95); // deep violet (text/icons on light plates)
  // `gold` is the secondary accent — a thin amber, used sparingly on badges.
  static const Color gold = Color(0xFFA76500);   // amber
  static const Color gold80 = Color(0xFFC67C1A); // lighter amber
  static const Color gold40 = Color(0xFFFFDCBB); // soft amber fill
  // Amber "plate" stops — flattened; kept for badge/pill surfaces.
  static const Color goldHighlight = Color(0xFFFFF3E6); // amber sheen
  static const Color goldLight = Color(0xFFFFE8CC);
  static const Color goldDeep = Color(0xFF855000);
  static const Color goldShadow = Color(0xFFC08A3A);
  static const Color success = Color(0xFF16A34A);
  static const Color success80 = Color(0xFF45B56E);
  static const Color success40 = Color(0xFFA2DAB7);
  static const Color error = Color(0xFFBA1A1A);
  static const Color error80 = Color(0xFFD0322E);
  static const Color error40 = Color(0xFFFFDAD6);
  static const Color info = Color(0xFF8A4CFC);
  static const Color info80 = Color(0xFFA78BFA);
  static const Color info40 = Color(0xFFC1C3FA);
  // `purple` — secondary accent (stat tiles), the alt Dristi violet.
  static const Color purple = Color(0xFF8A4CFC);
  static const Color purple80 = Color(0xFFA78BFA);
  static const Color purple40 = Color(0xFFDDD6FE);
  static const Color teal = Color(0xFF0D9488);
  static const Color teal80 = Color(0xFF3DA9A0);
  static const Color teal40 = Color(0xFF9ED4CF);
  static const Color warning = Color(0xFFA76500);
  // `btnColor` — flat solid violet action fill with a faint lilac border.
  static const Color btnColor = Color(0xFF6B38D4);
  static const Color btnColor80 = Color(0xFF8455EF);
  static const Color btnColor40 = Color(0xFFCBB8F0);
  static const Color btnBorder = Color(0xFFD8CEF8);

  static List<Color> get coralGradient => [coral, coral80];
  static List<Color> get goldGradient => [gold, gold80];
  // Flattened — near-solid violet plate (metallic sheen removed).
  static const List<Color> goldMetallic = [Color(0xFF7C4DE0), Color(0xFF6B38D4), Color(0xFF6B38D4)];
  // Saturated violet gradient for premium/hero surfaces (stat cards) — white text.
  static const List<Color> royalMetallic = [Color(0xFF8455EF), Color(0xFF6B38D4), Color(0xFF5A2BB5)];
  static List<Color> get successGradient => [success, success80];
  static List<Color> get errorGradient => [error, error80];
  static List<Color> get bluePurpleGradient => [const Color(0xFF6B38D4), const Color(0xFF8A4CFC)];
  static List<Color> get darkGradient => [surface, surfaceAlt];
  static List<Color> get bgGradient => _isDark
      ? [bg, const Color(0xFF0F0B1E)]
      : [bg, const Color(0xFFE7E0F8)];
  static List<Color> get cardGradient => [surface, surfaceRaised];
  static List<Color> get navGradient => _isDark
      ? [const Color(0xFF221B3D), const Color(0xFF17132A)]
      : [const Color(0xFFFFFFFF), const Color(0xFFFEF7FF)];
  // Nav active-pill fill — the Dristi violet signature (tokenized, was hardcoded).
  static const List<Color> navActiveGradient = [Color(0xFF8455EF), Color(0xFF6B38D4)];

  // ── Radius scale (matches the reference: rounded-lg/xl/2xl/3xl) ──────────────
  static const double rInput = 10;   // inputs / small controls
  static const double rButton = 12;  // buttons  (rounded-xl)
  static const double rCard = 16;    // cards    (rounded-2xl)
  static const double rCardLg = 24;  // large cards (rounded-3xl)
  static const double rPill = 999;   // pills / chips

  // Montserrat display helper — headings, stat values, and the tiny uppercase
  // labels use this; body/inputs inherit Inter via the base textTheme.
  static TextStyle heading({
    double? size,
    FontWeight? weight,
    double? letterSpacing,
    Color? color,
    double? height,
  }) => GoogleFonts.montserrat(
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    color: color,
    height: height,
  ).copyWith(
    // Montserrat has no ₹ (U+20B9); Noto Sans (bundled) supplies the glyph.
    fontFamilyFallback: const ['NotoSans'],
  );

  // Soft, minimal elevation (Haze/shadcn-style) — barely-there in light mode.
  static List<BoxShadow> get shadowSm => [
    BoxShadow(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: _isDark ? 0.05 : 0.04), blurRadius: 3, offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> get shadowMd => [
    BoxShadow(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: _isDark ? 0.07 : 0.06), blurRadius: 8, offset: const Offset(0, 3)),
    BoxShadow(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: _isDark ? 0.03 : 0.035), blurRadius: 16, offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> get shadowLg => [
    BoxShadow(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: _isDark ? 0.09 : 0.08), blurRadius: 16, offset: const Offset(0, 6)),
    BoxShadow(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: _isDark ? 0.04 : 0.05), blurRadius: 32, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> shadowGlow(Color c) => [
    BoxShadow(color: c.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
    BoxShadow(color: c.withValues(alpha: 0.1), blurRadius: 28, offset: const Offset(0, 8)),
  ];
  // Flattened: primary-action glow is now the soft violet-tinted "luxury" shadow
  // (0 10px 30px -10px #6b38d4) rather than a warm metallic gold glow.
  static List<BoxShadow> get shadowGold => [
    BoxShadow(color: coral.withValues(alpha: _isDark ? 0.30 : 0.16), blurRadius: 20, offset: const Offset(0, 10)),
    BoxShadow(color: (_isDark ? Colors.black : coral).withValues(alpha: 0.06), blurRadius: 3, offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> get shadowInset => [
    BoxShadow(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: _isDark ? 0.04 : 0.06), blurRadius: 2, offset: const Offset(0, 1)),
  ];

  static BoxDecoration get cardDeco => BoxDecoration(
    gradient: LinearGradient(colors: cardGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
    borderRadius: BorderRadius.circular(rCard),
    border: Border.all(color: borderLight, width: 1),
    boxShadow: shadowMd,
  );

  static BoxDecoration cardDecoGlow(Color accent) => BoxDecoration(
    gradient: LinearGradient(colors: cardGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: accent.withValues(alpha: 0.3), width: 1),
    boxShadow: shadowGlow(accent),
  );

  static BoxDecoration get glassDeco => BoxDecoration(
    gradient: LinearGradient(
      colors: _isDark
          ? [const Color(0xCC1E293B), const Color(0x660F172A)]
          : [Colors.white.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: _isDark ? const Color(0x33FFFFFF) : Colors.white.withValues(alpha: 0.9), width: 1),
    boxShadow: [
      BoxShadow(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4)),
      BoxShadow(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: 0.04), blurRadius: 1, offset: const Offset(0, 1)),
    ],
  );

  static BoxDecoration get inputDeco => BoxDecoration(
    color: bgAlt,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: border, width: 1),
  );

  static BoxDecoration get inputDecoFocused => BoxDecoration(
    color: bgAlt,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: btnColor.withValues(alpha: 0.6), width: 1.5),
    boxShadow: [
      BoxShadow(color: btnColor.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 0)),
    ],
  );

  static Decoration get cornerAccent => BoxDecoration(
    gradient: const LinearGradient(colors: [Color(0xFF8455EF), Color(0xFF6B38D4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
  );

  static BoxDecoration get headerDeco => BoxDecoration(
    gradient: LinearGradient(
      colors: [surface, surfaceAlt],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    border: Border(
      bottom: BorderSide(color: borderLight, width: 1),
    ),
    boxShadow: shadowSm,
  );

  // ── Premium building blocks (flattened to the Dristi flat-violet look) ───────
  // Primary-action surface: a flat solid-violet plate (no metallic gradient),
  // hairline violet border, soft violet shadow. `radius` lets callers match
  // pills, buttons, and chips. All former "gold plate" call sites pick this up.
  static BoxDecoration premiumGoldDeco({double radius = 12}) => BoxDecoration(
    color: btnColor,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: coralDark.withValues(alpha: 0.35), width: 1),
    boxShadow: shadowGold,
  );

  // Flattened — no metal edge sheen anymore. Kept as a no-op so existing
  // call sites (FashionButton) compile without a structural change.
  static BoxDecoration goldSheen({double radius = 12}) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    color: Colors.transparent,
  );

  // Premium card: soft surface gradient with a hairline violet-tinted border and
  // a whisper of violet glow. Used for luxury content containers.
  static BoxDecoration premiumCardDeco({double radius = rCard}) => BoxDecoration(
    gradient: LinearGradient(colors: cardGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: coral.withValues(alpha: _isDark ? 0.26 : 0.20), width: 1),
    boxShadow: [
      ...shadowMd,
      BoxShadow(color: coral.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
    ],
  );

  // A 1px horizontal violet rule that fades at both ends — a refined divider.
  static BoxDecoration get goldHairline => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        coral.withValues(alpha: 0.0),
        coral.withValues(alpha: 0.5),
        coral80.withValues(alpha: 0.8),
        coral.withValues(alpha: 0.5),
        coral.withValues(alpha: 0.0),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
  );

  // Signature rainbow accent bar — violet → amber → light-violet. A thin strip
  // placed atop hero cards / the brand header (from-#6b38d4 via-#a76500 to-#8a4cfc).
  static const LinearGradient rainbowAccent = LinearGradient(
    colors: [Color(0xFF6B38D4), Color(0xFFA76500), Color(0xFF8A4CFC)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

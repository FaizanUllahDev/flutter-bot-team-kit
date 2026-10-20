---
name: flutter-responsive-ui
description: >-
  Applies dual responsive sizing for Flutter apps that keep legacy sizer and use
  flutter_screenutil via ScaleHelper for new features/UI. Use when building or
  reviewing screens, widgets, typography, padding, or layout under
  lib/ui/features or new common widgets; when user mentions ScaleHelper, ScreenUtil,
  sizer, responsiveness, or device scaling.
---

# Flutter Responsive UI

## Decision

| Path | Use |
|------|-----|
| New feature / new common widget | `ScaleHelper.sp(15)`, `ScaleHelper.w(16)`, `ScaleHelper.h(24)`, `ScaleHelper.r(8)` |
| Existing legacy UI | Keep `sizer` `.w/.h/.sp` + `DeviceSizeUtil`, no drive-by migration |

Import: resolve `ScaleHelper` from project `CURSOR.md` (or project docs).  
Never import `package:sizer/sizer.dart` in the same new-UI file.

## Init (already in app)

`ScreenUtilInit(designSize: ScaleHelper.designSize /* 390×844 */, minTextAdapt: true, splitScreenMode: true)` in `main.dart`.

## Checklist (new UI)

- [ ] All font sizes via `ScaleHelper.sp`
- [ ] Spacing/sizes via `ScaleHelper.w` / `h` / `r`
- [ ] No raw `Color(0xFF…)`, use `AppColors` / `appTheme`
- [ ] Light + dark considered
- [ ] Keyboard/safe area handled when forms present

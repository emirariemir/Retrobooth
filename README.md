<img width="2008" height="381" alt="github-repo-thumbnail" src="https://github.com/user-attachments/assets/36940e31-8c7b-4bda-ad54-7db37513e02f" />

# Retrobooth
A tiny open-source SwiftUI app that gives photos a tasteful retro vibe using Core Image custom filters. Pick multiple photos, swipe through them, apply a filter, and share — all with a smooth, native feel.

---

## Features
### SwiftUI UI/UX
- `NavigationStack` layout, paged `TabView` with page indicators
- Progress overlay while processing (thin-material card + `ProgressView`)
- Custom Filter Sheet to pick the active filter
### Photo workflow
- `PhotosPicker` (select up to 10 images)
- Inline `ShareLink` export (with SharePreview)
### Core Image pipeline
- Uses `CoreImage.CIFilterBuiltins` + `CIContext`
- Batch processing with orientation handling (`exifOrientation`)
### Delight & polish
- In-app review trigger via `StoreKit` after repeated use
- Lightweight usage tracking with `@AppStorage`
### Filters included
- Arctic Mist, Caramel Fade, Patina Grain, Polar Radiance, Silver Grit, Retro Pixel

---

## Screenshots (coming soon)

---

## Requirements
Xcode 15+
iOS 16+ (for PhotosPicker & NavigationStack)

---

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

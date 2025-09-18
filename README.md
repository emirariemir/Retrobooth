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

## Screenshots

| | | | | |
|---|---|---|---|---|
| <img alt="App store pic 1" src="https://github.com/user-attachments/assets/0a2d322d-1a48-49fa-bfdc-27a9668a0861" width="180" /> | <img alt="App store pic 2" src="https://github.com/user-attachments/assets/a3461811-00ea-47b1-9232-9fadbb868131" width="180" /> | <img alt="App store pic 3" src="https://github.com/user-attachments/assets/c646b17d-fcfb-46e2-917a-266cd077fb0d" width="180" /> | <img alt="App store pic 4" src="https://github.com/user-attachments/assets/ced83431-1d55-47d8-9666-f6ab7bd851d9" width="180" /> | <img alt="App store pic 5" src="https://github.com/user-attachments/assets/2a371752-cbe2-4ade-a52a-395f7c7c53cc" width="180" /> |

---

## Requirements
Xcode 15+
iOS 16+ (for PhotosPicker & NavigationStack)

---

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

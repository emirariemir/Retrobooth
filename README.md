# Retrobooth
An experimental SwiftUI playground where I explored some of the coolest iOS APIs while building a simple retro photo editor.

## What is Retrobooth?
Retrobooth lets you:
- Import a photo using the new `PhotosPicker`.
- Apply different Core Image filters (Sepia, Pixellate, Gaussian Blur, Crystallize, and more).
- Adjust filter intensity in real time with a slider.
- Share the processed photo using `ShareLink`.
- Prompt users for an App Store review after repeated interactions.
- Use confirmation dialogs for filter selection.

It’s not a full-featured app—just a playground for learning and trying out iOS frameworks. But along the way, I learned how to:
- Work with `CIImage` and safely apply Core Image filters.
- Build SwiftUI UIs for importing and previewing images.
- Manage state and context with `@State`, `@AppStorage`, and environment values.
- Hook into the StoreKit API to ask for ratings at the right time.
- Use SwiftUI’s modern APIs like `NavigationStack` and `ContentUnavailableView`.

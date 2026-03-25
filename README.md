# Tristan Harvey Godoy - Portfolio

[![Live Site](https://img.shields.io/badge/Live-Portfolio-ffdd33?style=for-the-badge&logo=flutter)](https://popodepo123.github.io/thgportfolio/)

A modern, high-performance personal portfolio built with Flutter, featuring a unique dual-mode interface that bridges the gap between professional presentation and developer-centric technical depth.

## 🚀 Key Features

- **Dual-Mode Experience**: Switch seamlessly between a clean **Professional View** and a terminal-inspired **Developer View**.
- **Helix/Vim-Style Developer View**: A fully functional TUI (Terminal User Interface) simulation with:
  - Vim-style keyboard navigation (`h`, `j`, `k`, `l`, `w`, `b`, `g`, `G`).
  - Real-time syntax highlighting for multiple languages.
  - Command-line mode for navigation and settings.
  - Project file tree with GitLab API integration.
- **TUI Splash Screen**: A custom-built boot sequence that tracks real-time asset download progress and system initialization.
- **Contribution Heatmap**: A unified GitHub and GitLab activity tracker.
- **Responsive Design**: Optimized for everything from mobile devices to large desktop monitors.

## 🛠️ Technologies Used

- **Framework**: [Flutter](https://flutter.dev) (Web)
- **Language**: [Dart](https://dart.dev)
- **State Management**: ValueNotifiers & StateProvider
- **Icons**: [FontAwesome](https://fontawesome.com)
- **Typography**: [Google Fonts (Fira Code)](https://fonts.google.com/specimen/Fira+Code)
- **Deployment**: GitHub Pages (docs/ directory)

## 📂 Project Structure

- `lib/pages/`: Main view logic (Professional vs. Developer).
- `lib/sections/`: Individual components for the Professional view (Hero, Projects, Skills, etc.).
- `lib/widgets/`: Reusable UI components like the `ContributionHeatmap` and `LoadingLogo`.
- `lib/loading_logo.dart`: The logic behind the animated "THG" logo.
- `docs/`: The compiled web release for GitHub Pages hosting.

## 🏁 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [FVM](https://fvm.app/) (Recommended)

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/popodepo123/thgportfolio.git
    cd thgportfolio
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```

### Running Locally

To run the application in Chrome:

```bash
flutter run -d chrome
```

## 🏗️ Deployment

To build the project for GitHub Pages:

```bash
flutter build web --release --base-href "/thgportfolio/"
rm -rf docs/*
cp -r build/web/* docs/
touch docs/.nojekyll
```

## 📧 Contact

**Tristan Harvey Godoy**
- **Email**: [godoytristanh@gmail.com](mailto:godoytristanh@gmail.com)
- **GitHub**: [@popodepo123](https://github.com/popodepo123)
- **GitLab**: [@godoytristanh](https://gitlab.com/godoytristanh)

---
*Built with ❤️ using Flutter & Dart.*

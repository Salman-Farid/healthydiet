#!/usr/bin/env bash
# Build signed release AAB for FitBook 2026
set -e
export PATH="$HOME/Flutter/flutter/bin:$PATH"
cd "$(dirname "$0")"
flutter pub get
python3 -c "
from pathlib import Path
p=Path('android/app/build.gradle.kts')
t=p.read_text()
t=t.replace('minSdk = flutter.minSdkVersion','minSdk = 23')
t=t.replace('targetSdk = flutter.targetSdkVersion','targetSdk = 36')
t=t.replace('compileSdk = flutter.compileSdkVersion','compileSdk = 36')
p.write_text(t)
print('gradle sdk pinned')
"
flutter analyze lib
flutter build appbundle --release
ls -lh build/app/outputs/bundle/release/app-release.aab

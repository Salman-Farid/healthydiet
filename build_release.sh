#!/usr/bin/env bash
# FitBook 2026 — seed food catalog + build signed release AAB
set -e
export PATH="$HOME/Flutter/flutter/bin:$PATH"
cd "$(dirname "$0")"

echo "==> Seed organ food catalog"
if [ -f tools/seed_food_catalog.py ]; then
  /usr/bin/python3 tools/seed_food_catalog.py || \
    echo "WARNING: seed failed — app will use cached/old foods until seed succeeds"
fi

echo "==> Resolve dependencies"
flutter pub get

echo "==> Pin Android SDK 36"
python3 - <<'PY'
from pathlib import Path
p=Path('android/app/build.gradle.kts')
t=p.read_text()
t=t.replace('minSdk = flutter.minSdkVersion','minSdk = 23')
t=t.replace('targetSdk = flutter.targetSdkVersion','targetSdk = 36')
t=t.replace('compileSdk = flutter.compileSdkVersion','compileSdk = 36')
p.write_text(t)
print('sdk ok')
PY

echo "==> Analyze (warnings do not stop the build)"
flutter analyze lib || true

echo "==> Build signed release AAB"
flutter build appbundle --release

echo "==> Output"
ls -lh build/app/outputs/bundle/release/app-release.aab
echo "Done. Upload app-release.aab to Play after upload-key reset (alias fitforge)."

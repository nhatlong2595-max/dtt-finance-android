from pathlib import Path
import re

manifest = Path("android/app/src/main/AndroidManifest.xml")
if not manifest.exists():
    raise SystemExit("Android manifest not found")

text = manifest.read_text()
permissions = [
    '<uses-permission android:name="android.permission.INTERNET"/>',
    '<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>',
]
for permission in permissions:
    if permission not in text:
        text = re.sub(r'(<manifest[^>]*>)', r'\1\n    ' + permission, text, count=1)

manifest.write_text(text)
print("Internet and APK install-request permissions enabled")

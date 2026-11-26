from pathlib import Path
import re
manifest = Path("android/app/src/main/AndroidManifest.xml")
if not manifest.exists():
    raise SystemExit("Android manifest not found")
text = manifest.read_text()
permission = '<uses-permission android:name="android.permission.INTERNET"/>'
if permission not in text:
    text = re.sub(r'(<manifest[^>]*>)', r'\1\n    ' + permission, text, count=1)
manifest.write_text(text)
print("Internet permission enabled for GitHub update checks")

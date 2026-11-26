from pathlib import Path
import re

path = Path("android/app/build.gradle.kts")
text = path.read_text()

if "isCoreLibraryDesugaringEnabled" not in text:
    match = re.search(r"compileOptions\\s*\\{", text)
    if not match:
        raise SystemExit("Could not find android.compileOptions block in generated Gradle file")
    insert_at = match.end()
    text = text[:insert_at] + "\\n        isCoreLibraryDesugaringEnabled = true" + text[insert_at:]

dependency = 'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")'
if dependency not in text:
    match = re.search(r"dependencies\\s*\\{", text)
    if match:
        insert_at = match.end()
        text = text[:insert_at] + "\\n    " + dependency + text[insert_at:]
    else:
        text += "\\n\\ndependencies {\\n    " + dependency + "\\n}\\n"

path.write_text(text)
print("Enabled core library desugaring in", path)

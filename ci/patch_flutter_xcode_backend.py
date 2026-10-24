"""Compatibilidad del stub debug de Flutter 1.12.13 con Xcode 16.

Solo modifica el SDK temporal del runner. No cambia Flutter/Dart, el motor
ni las dependencias de SRA. La huella evita aplicar el parche a otro SDK.
"""

import hashlib
import sys
from pathlib import Path


backend = Path(sys.argv[1]) / "packages/flutter_tools/bin/xcode_backend.sh"
original = backend.read_bytes()
expected_sha256 = "59b271e129331ad2ab52c413a9f04c20986925f426927454221d7e4150770a1c"
if hashlib.sha256(original).hexdigest() != expected_sha256:
    raise SystemExit("El xcode_backend.sh no coincide con el SDK fijado; parche cancelado.")

source = original.decode("utf-8")
old_flag = "        -fembed-bitcode-marker \\\n"
new_flag = "        -miphoneos-version-min=12.0 \\\n"
stub_end = '        -o "${derived_dir}/App.framework/App" -)"\n'
check_stub = '''
    # El script legado oculta el código de salida de clang mediante eval.
    if [[ ! -s "${derived_dir}/App.framework/App" ]]; then
      EchoError "Failed to link the debug App.framework stub."
      exit 1
    fi
'''
if source.count(old_flag) != 1 or source.count(stub_end) != 1:
    raise SystemExit("No se encontró el bloque debug esperado; parche cancelado.")

patched = source.replace(old_flag, new_flag).replace(stub_end, stub_end + check_stub)
backend.write_text(patched, encoding="utf-8")
print("SDK temporal: stub debug sin bitcode; destino iOS 12; verificación del binario activada.")

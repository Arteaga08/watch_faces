# watch_faces — Carátulas Wear OS (Watch Face Format)

Carátulas personales para Galaxy Watch 9 (Wear OS 7.0, 40 mm). Uso personal, no se publican.
Prevalece sobre `~/.claude/CLAUDE.md` en lo que choque (aquí no hay backend ni web).

## Stack
- **Watch Face Format (WFF) v4**, XML declarativo. Sin código: `android:hasCode="false"`.
  Evaluar v5 solo si el reloj y el validador lo confirman.
- AGP 9.0.0, Gradle 9.2.1 (wrapper con checksum fijo), daemon en **JDK 17**
  (`gradle/gradle-daemon-jvm.properties`).
- `compileSdk`/`minSdk`/`targetSdk` = 36 (WFF v4 requiere Wear OS 6 / API 36).

## Estructura
```
faces/<nombre>/        un módulo Gradle = un APK, paquete com.vidix.<nombre>
  src/main/res/raw/watchface.xml      la carátula
  src/main/res/xml/watch_face_info.xml
  src/main/res/drawable/preview.png
  src/main/res/values/strings.xml     nombre visible (español)
faces/template/        plantilla mínima (hora + fecha); base de new-face.sh
shared/palettes/       paletas de color (fuente de verdad para ColorConfiguration)
shared/fonts/          fuentes compartidas (solo con licencia libre)
shared/scripts/        validate.sh, install.sh, new-face.sh
shared/tools/          validador compilado (git-ignored)
```

## Comandos
```bash
./gradlew :faces:<nombre>:assembleDebug          # compilar
shared/scripts/validate.sh <nombre>              # validador oficial WFF (obligatorio antes de instalar)
shared/scripts/install.sh <nombre> [serial]      # valida + compila + adb install
shared/scripts/new-face.sh <nombre> "<Visible>"  # nueva carátula desde template

# adb inalámbrico (reloj: Opciones de desarrollador → Depuración inalámbrica)
adb pair <ip>:<puerto-de-emparejamiento>         # pide el código de 6 dígitos
adb connect <ip>:<puerto>
adb devices
adb shell wm size                                # resolución real del reloj
adb uninstall com.vidix.<nombre>
```

## Convenciones
- Identificadores, nombres de archivo y comentarios del XML en **inglés**; textos visibles en **español**.
- Lienzo lógico `432×432`; el sistema escala a la pantalla real.
- Cada carátula define su variante Always-On con `<Variant mode="AMBIENT" ...>`: solo trazos finos,
  sin animación, mínimo de píxeles encendidos.
- Colores: selector en el reloj vía `UserConfigurations` → `ColorConfiguration`, a partir de
  `shared/palettes/palettes.json`.
- Diseños **originales**: nada de recrear juegos o carátulas existentes (nombres, logos, formas).
- Validar con `validate.sh` antes de dar algo por hecho; reportar la salida real.
- Validador fijado a un commit de `google/watchface`; actualizarlo solo a propósito.
- Git: no `add`/`commit`/`push` sin aprobación explícita; trabajar en ramas.

## Límites de WFF (tenerlos presentes al diseñar)
Se puede: transformaciones (rotar/mover/escalar/alfa) con expresiones sobre tiempo y datos,
`AnimatedImage`/secuencias pre-renderizadas, `Gyro`, condiciones según datos, transiciones a Always-On.
No se puede: física o colisiones reales, azar verdadero, estado persistente, control táctil de juego,
sonido, blur o shaders, red.

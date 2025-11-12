#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}" && pwd)"
OUTPUT_DIR="${PROJECT_ROOT}/assets/icon/ios"
DEFAULT_SOURCE_SVG="${PROJECT_ROOT}/assets/icon/logo.svg"
DEFAULT_SOURCE_PNG="${PROJECT_ROOT}/assets/icon/logo.png"

usage() {
  cat <<'USAGE'
Usage: scripts/generate_ios_app_icons.sh [SOURCE_IMG]

Generate all iOS Runner AppIcon assets from the supplied square PNG or SVG.
If SOURCE_IMG is omitted the script prefers icon/draftmode.svg when present
and falls back to icon/draftmode-192x192.png.

USAGE
}

if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

# Determine source asset path
if [[ -n "${1:-}" ]]; then
  SOURCE_ASSET="${1}"
elif [[ -f "${DEFAULT_SOURCE_SVG}" ]]; then
  SOURCE_ASSET="${DEFAULT_SOURCE_SVG}"
else
  SOURCE_ASSET="${DEFAULT_SOURCE_PNG}"
fi

if [[ ! -f "${SOURCE_ASSET}" ]]; then
  echo "error: source image not found: ${SOURCE_ASSET}" >&2
  exit 1
fi

if [[ ! -d "${OUTPUT_DIR}" ]]; then
  echo "error: expected output directory not found: ${OUTPUT_DIR}" >&2
  exit 1
fi

echo "Source image: ${SOURCE_ASSET}"

SOURCE_EXT="${SOURCE_ASSET##*.}"
SOURCE_EXT=$(printf '%s' "${SOURCE_EXT}" | tr '[:upper:]' '[:lower:]')

ensure_sips_available() {
  if ! command -v sips >/dev/null 2>&1; then
    echo "error: sips tool not available. Run on macOS where sips is bundled." >&2
    exit 1
  fi
}

check_png_source() {
  ensure_sips_available
  if ! SIPS_DIMENSIONS=$(sips -g pixelWidth -g pixelHeight "${SOURCE_ASSET}" 2>/dev/null); then
    echo "error: failed to read image metadata via sips. macOS sandboxing may be blocking the command." >&2
    exit 1
  fi

  read -r SRC_WIDTH SRC_HEIGHT <<< "$(printf '%s' "${SIPS_DIMENSIONS}" | awk -F': ' '/pixelWidth|pixelHeight/ {print $2}' | tr '\n' ' ')"

  if [[ -z "${SRC_WIDTH}" ]] || [[ -z "${SRC_HEIGHT}" ]]; then
    echo "error: unable to determine source image dimensions" >&2
    exit 1
  fi

  if [[ "${SRC_WIDTH}" != "${SRC_HEIGHT}" ]]; then
    echo "warning: source image is not square (${SRC_WIDTH}x${SRC_HEIGHT}); output icons may be distorted" >&2
  fi

  MAX_TARGET=1024
  if (( SRC_WIDTH < MAX_TARGET || SRC_HEIGHT < MAX_TARGET )); then
    echo "warning: source image (${SRC_WIDTH}x${SRC_HEIGHT}) is smaller than ${MAX_TARGET}px; generated icons will be upscaled" >&2
  fi
}

command_is_usable() {
  local cmd="$1"
  local version_arg="${2:---version}"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    return 1
  fi
  if "${cmd}" "${version_arg}" >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

select_svg_renderer() {
  if command_is_usable rsvg-convert "--version"; then
    echo rsvg
  elif command_is_usable magick "--version"; then
    echo magick
  elif command_is_usable convert "--version"; then
    echo imagemagick-legacy
  elif command_is_usable inkscape "--version"; then
    echo inkscape
  else
    echo ""
  fi
}

render_svg_size() {
  local size="$1" target_path="$2"
  case "${SVG_RENDERER}" in
    rsvg)
      rsvg-convert -w "${size}" -h "${size}" "${SOURCE_ASSET}" -o "${target_path}"
      ;;
    inkscape)
      inkscape "${SOURCE_ASSET}" --export-type=png --export-filename="${target_path}" \
        --export-width="${size}" --export-height="${size}" --export-area-page
      ;;
    magick)
      magick -background none "${SOURCE_ASSET}" -resize "${size}x${size}" "${target_path}"
      ;;
    imagemagick-legacy)
      convert -background none "${SOURCE_ASSET}" -resize "${size}x${size}" "${target_path}"
      ;;
    *)
      return 1
      ;;
  esac
}

case "${SOURCE_EXT}" in
  png)
    check_png_source
    SVG_RENDERER=""
    ;;
  svg)
    SVG_RENDERER=$(select_svg_renderer)
    if [[ -z "${SVG_RENDERER}" ]]; then
      echo "error: no SVG renderer available. Install librsvg (rsvg-convert), Inkscape, or ImageMagick." >&2
      exit 1
    fi
    echo "Using SVG renderer: ${SVG_RENDERER}"
    ;;
  *)
    echo "error: unsupported source image extension: .${SOURCE_EXT}" >&2
    echo "Provide a PNG or SVG input." >&2
    exit 1
    ;;
esac

ICON_SPECS=$(cat <<'EOF'
Icon-App-20x20@1x.png 20
Icon-App-20x20@2x.png 40
Icon-App-20x20@3x.png 60
Icon-App-29x29@1x.png 29
Icon-App-29x29@2x.png 58
Icon-App-29x29@3x.png 87
Icon-App-40x40@1x.png 40
Icon-App-40x40@2x.png 80
Icon-App-40x40@3x.png 120
Icon-App-60x60@2x.png 120
Icon-App-60x60@3x.png 180
Icon-App-76x76@1x.png 76
Icon-App-76x76@2x.png 152
Icon-App-83.5x83.5@2x.png 167
Icon-App-1024x1024@1x.png 1024
EOF
)

echo "Generating iOS AppIcon images in ${OUTPUT_DIR}"

declare -a FAILED=()
while read -r filename size; do
  [[ -z "${filename}" ]] && continue
  target_path="${OUTPUT_DIR}/${filename}"
  if [[ "${SOURCE_EXT}" == "png" ]]; then
    if ! sips -z "${size}" "${size}" "${SOURCE_ASSET}" --out "${target_path}" >/dev/null; then
      echo "error: failed to generate ${filename}. If no other output is shown, macOS sandbox restrictions may be preventing sips from running." >&2
      FAILED+=("${filename}")
      continue
    fi
  else
    if ! render_svg_size "${size}" "${target_path}"; then
      echo "error: failed to generate ${filename} using ${SVG_RENDERER}." >&2
      FAILED+=("${filename}")
      continue
    fi
  fi
  echo "  • ${filename} (${size}x${size})"
done <<< "${ICON_SPECS}"

if (( ${#FAILED[@]} )); then
  echo "error: generation failed for ${FAILED[*]}" >&2
  exit 1
fi

echo "Done."

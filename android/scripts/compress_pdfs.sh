#!/bin/bash
# Compress PDF reports using Ghostscript for all languages.
# Usage: ./scripts/compress_pdfs.sh
# Requires: Ghostscript (gs) installed on the system.

set -euo pipefail

DOCS_DIR="$(cd "$(dirname "$0")/../assets/docs" && pwd)"

# Input -> Output pairs (space-separated)
PAIRS=(
  "Nanoplastics_in_the_Biosphere_Report_EN.pdf Nanoplastics_Report_EN_compressed.pdf"
  "Nanoplastics_in_the_Biosphere_Report_CS.pdf Nanoplastics_Report_CS_compressed.pdf"
  "Nanoplasticos_en_la_Biosfera_Informe_ES.pdf Nanoplastics_Report_ES_compressed.pdf"
  "Nanoplastics_in_the_Biosphere_Report_FR.pdf Nanoplastics_Report_FR_compressed.pdf"
  "Nanoplastics_in_the_Biosphere_Report_RU.pdf Nanoplastics_Report_RU_compressed.pdf"
)

if ! command -v gs &>/dev/null; then
  echo "ERROR: Ghostscript (gs) is not installed."
  echo "  macOS: brew install ghostscript"
  echo "  Linux: sudo apt install ghostscript"
  exit 1
fi

echo "Compressing PDFs in: $DOCS_DIR"
echo "---"

for pair in "${PAIRS[@]}"; do
  input="${pair%% *}"
  output="${pair##* }"
  input_path="$DOCS_DIR/$input"
  output_path="$DOCS_DIR/$output"

  if [ ! -f "$input_path" ]; then
    echo "SKIP: $input (not found)"
    continue
  fi

  input_size=$(du -h "$input_path" | cut -f1)
  echo -n "Compressing $input ($input_size) -> $output ... "

  gs -sDEVICE=pdfwrite \
     -dCompatibilityLevel=1.4 \
     -dPDFSETTINGS=/ebook \
     -dNOPAUSE -dBATCH -dQUIET \
     -sOutputFile="$output_path" \
     "$input_path"

  output_size=$(du -h "$output_path" | cut -f1)
  echo "done ($output_size)"
done

echo "---"
echo "Compression complete. Compressed files:"
ls -lh "$DOCS_DIR"/*_compressed.pdf

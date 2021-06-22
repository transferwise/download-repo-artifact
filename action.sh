#!/bin/bash

ARTIFACT_NAME=$1;
ARTIFACT_PATH=$2;

FILTER="
[
    .artifacts[]
        | select( .expired == false and .name == \"${ARTIFACT_NAME}\" )
]
    | first
    | .archive_download_url
";

TEMP_FILE=$(mktemp);
PAGE_SIZE=100;
for iteration in $(seq 1 60); do
    curl --silent \
        --header "Authorization: token ${GITHUB_TOKEN}" \
        --header 'Accept: application/vnd.github.v3+json' \
        "https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/artifacts?per_page=${PAGE_SIZE}" > $TEMP_FILE;
    if [ $? -ne 0 ]; then
        echo "::error ::Can't get artifact list";
        exit 1;
    fi;

    URL=$(jq --raw-output --from-file <(echo $FILTER) < $TEMP_FILE);
    if [ "$URL" != "null" ]; then
        break;
    fi;

    echo "::warning ::Artifact missing in iteration $iteration";
    sleep 1;
done;

if [ "$URL" == "null" ]; then
    echo '::error ::Artifact not found';
    exit 1;
fi;

ARTIFACT_FILE=$(mktemp);
curl --silent --location \
    --header "Authorization: token $GITHUB_TOKEN" \
    $URL > $ARTIFACT_FILE;
if [ $? -ne 0 ]; then
    echo "::error ::Couldn't fetch artifact";
    exit 1;
fi;

mkdir -p "$ARTIFACT_PATH";
unzip -d "$ARTIFACT_PATH" $ARTIFACT_FILE;

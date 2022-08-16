#!/bin/bash
source ./secret.sh
curl \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token ${git_hub_token}" \
  https://api.github.com/repos/${git_hub_user}/${git_hub_repo}/hooks  \
  | jq '.[] |.id' > web-hook-id.txt
while IFS= read -r id; do
    echo "Github id read from file: $id"
    curl \
      -X DELETE \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: token ${git_hub_token}" \
      https://api.github.com/repos/${git_hub_user}/${git_hub_repo}/hooks/${id}
done < web-hook-id.txt
rm web-hook-id.txt

#!/bin/bash

# Docker Registry Tool v1.0.0
# Copyright © 2021 NewsNow Publishing Limited
# ----------------------------------------------------------------------
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ----------------------------------------------------------------------

if [ ${BASH_VERSINFO[0]} -lt 4 ]; then
  echo "$0: Need bash v4 or greater, but running only bash $BASH_VERSION; aborting" >&2
  exit 1
fi

gc() {
  local registryContainer="$1"

  [ -n "$registryContainer" ] || return 0

  echo -n "Garbage collecting: " >&2

  if [ "$DRY_RUN" == "0" ]; then
    docker exec $registryContainer bin/registry garbage-collect /etc/docker/registry/config.yml | grep 'manifests eligible' >&2
  else
    docker exec $registryContainer bin/registry garbage-collect /etc/docker/registry/config.yml -d | grep 'manifests eligible' >&2
  fi
}

tag_digest() {
  local tag="$1"

  curl -ksSL -I \
             -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
	     "${registry}/v2/${repo}/manifests/$tag" \
	     | awk 'tolower($1) == "docker-content-digest:" { print $2 }' \
	     | tr -d $'\r'
}

delete() {
  local registry="$1"
  local repo="$2"
  local digest="$3"

  curl -f -ksSL -X DELETE -I -H "Accept: application/vnd.docker.distribution.manifest.v2+json" "${registry}/v2/${repo}/manifests/${digest}" >/dev/null 2>&1
}

list() {
  local registry="$1"
  local repo="$2"
  local oldest="$3"

  local tags=($(curl -ksSL "${registry}/v2/${repo}/tags/list" | jq -r '.tags[]' 2>/dev/null | sort))

  # If there's a ':latest' tag, look up the digest
  local digest_latest=$(tag_digest latest)

  # Create associated array keyed on digests of non-numeric tags
  # Create associated array keyed on tags looking up digests
  local -A digests_to_keep tag_digests
  for tag in "${tags[@]}"
  do
    local digest=$(tag_digest "$tag")

    if [ -n "$digest" ]; then
      tag_digests[$tag]="$digest"

      if ! [[ $tag =~ ^[0-9]+$ ]]; then
        digests_to_keep[$digest]="1"
      fi
    fi
  done

  if [ "$MODE" == "terse" ]; then
    echo "$repo:"
  fi

  local tag
  local count=0
  for tag in "${tags[@]}"
  do

    local digest="${tag_digests[$tag]}"

    if [ "$MODE" == "terse" ]; then

      echo -n "$(printf ' - %-15s' "$tag")"
      echo -n ": digest $digest"

    elif [ "$MODE" == "long" ]; then

      echo -n "$(printf '%-50s %s' $repo:$tag $digest)"

    fi

    if [ "$PRUNE" != "1" ]; then
      echo
      continue
    fi

    # Skip any tag that has the same digest as ':latest' tag
    if [ -n "$digest_latest" ] && [[ $digest == $digest_latest ]]; then
      echo "; skipping delete (is :latest)"
      continue
    fi

    if ! [[ $tag =~ ^[0-9]+$ ]]; then
      echo "; skipping delete (tag is textual)"
      continue
    fi

    if [ -z "$digest" ]; then
      echo "; skipping delete (digest not found)"
      continue
    fi

    # Skip any tag that has the same digest as a textually (actually non-numerically) tag
    if [ -n "${digests_to_keep[$digest]}" ]; then
      echo "; skipping delete (is also textually tagged)"
      continue
    fi

    if [[ $tag > $oldest ]]; then
      echo "; skipping delete (too recent)"
      continue
    fi

    if [ $count -lt "$PRUNE_MAX" ]; then
      count=$((count+1))

      if [ "$DRY_RUN" == "1" ]; then
        echo -n "; skipping delete (dry run)"
      else
        if delete "$registry" "$repo" "$digest"; then
          echo -n "; deleted."
        else
          echo "; delete failed; exiting"
          exit -1
        fi
      fi
    else
      echo -n "; skipping delete (deleted enough)"
    fi

    echo
  done

}

repos() {
  for repo in "$@"
  do
    list "$REGISTRY" "$repo" "$OLDEST"
  done
}

usage() {
  cat <<_EOE_ >&2
Usage: $0 [list|prune|delete] [OPTIONS]

  MANDATORY OPTIONS

  --registry <uri>                 - registry uri

  LIST/PRUNE OPTIONS

  --repo <repo>|--repos <repo>     - specify repo(s)
  --terse|--long                   - output format

  PRUNE OPTIONS

  --no-dry-run|--execute|-x        - actually delete
  --prune-older-than <age>         - prune only YYYYMMDDHHMMSS tags < <age> old
  --prune-less-than <tag>          - prune only tags alphanumerically < <tag>
  --prune-tag-format <date-format> - tag date format
  --prune-max <count>              - prune at most <count> tags per repo
  --gc-container <name|id>         - garbage collect in registry container <name|id>

  (<age> is any argument to 'date -d')
  (<date-format> is any FORMAT parsed by 'date')

  DELETE OPTIONS

  --digest <digest>                - digest(s) to delete

_EOE_

exit 0
}

# Assign sensible default options
ACTION="list"
MODE=${MODE:-terse}
PRUNE_MAX=${PRUNE_MAX:-2}
PRUNE=${PRUNE:-0}
DRY_RUN=${DRY_RUN:-1}
PRUNE_AGE=${PRUNE_AGE:-'1 week'}
PRUNE_TAG_FORMAT=${PRUNE_TAG_FORMAT:-'+%Y%m%d%H%M%S'}

# Override these with any specified here
[ -f /etc/default/registry ] && . /etc/default/registry

# Prepare arrays
REPOS=()
DIGESTS=()

# Parse command line
while true;
do
  case "$1" in
    --list|list) shift; ACTION="list"; ;;
    --prune|prune) shift; ACTION="list"; PRUNE="1"; ;;
    --delete|delete) shift; ACTION="delete"; ;;

    --repo|--repos) shift; REPOS+=("$1"); shift; ;;
    --terse) shift; MODE="terse"; ;;
    --long) shift; MODE="long"; ;;

    --no-dry-run|--execute|-x) shift; DRY_RUN="0"; ;;
    --prune-older-than) shift; PRUNE_AGE="$1"; shift; ;;
    --prune-less-than) shift; OLDEST="$1"; unset PRUNE_AGE; shift; ;;
    --prune-max) shift; PRUNE_MAX="$1"; shift; ;;
    --prune-tag-format) shift; PRUNE_TAG_FORMAT="$1"; shift; ;;

    --registry|--registry-uri) shift; REGISTRY="$1"; shift; ;;
    --gc-container) shift; REGISTRY_CONTAINER="$1"; shift; ;;

    --digest|--digests) shift; DIGESTS+=("$1"); shift; ;;

    --help|help) shift; usage; ;;

    *) break; ;;
  esac
done

if [ -z "$REGISTRY" ]; then
  echo "$0: must provide --registry <registry>" >&2
  echo "Try '$0 --help' for more information." >&2
  exit 1
fi

if [ "$ACTION" == "list" ]; then

  if [ "$PRUNE" == "1" ]; then

    echo "Assuming:" >&2

    [ -n "$PRUNE_AGE" ] && \
      OLDEST=$(date -u -d "$PRUNE_AGE ago" "$PRUNE_TAG_FORMAT") && \
      echo "  --prune-tag-format  $PRUNE_TAG_FORMAT" >&2 && \
      echo "  --prune-older-than  $PRUNE_AGE" >&2

    [ -n "$OLDEST" ] && echo "  --prune-less-than   $OLDEST" >&2

    echo "  --prune-max         $PRUNE_MAX" >&2

    echo >&2
  fi

  # Get repos list
  if [ -z "${REPOS[0]}" ]; then
    REPOS=($(curl -ksSL "$REGISTRY/v2/_catalog" | jq -r '.repositories[]'))
  fi

  repos "${REPOS[@]}"

  [ "$PRUNE" == "1" ] && gc "$REGISTRY_CONTAINER"

elif [ "$ACTION" == "delete" ]; then

  if [ -z "${REPOS[0]}" ] || [ -z "${DIGESTS[0]}" ]; then
    echo "$0: must provide --repo <repo> and --digest <digest>" >&2
    echo "Try '$0 --help' for more information." >&2
    exit 1
  fi

  REPO="${REPOS[0]}"

  for digest in "${DIGESTS[@]}"
  do
    echo -n "$(printf '%s %s' $REPO $digest)"

    if [ "$DRY_RUN" == "1" ]; then
      echo "; skipping delete (dry run)"
    else
      if delete "$REGISTRY" "$REPO" "$digest"; then
        echo "; deleted"
      else
        echo "; delete failed"
      fi
    fi
  done

  gc "$REGISTRY_CONTAINER"

else
  usage

fi
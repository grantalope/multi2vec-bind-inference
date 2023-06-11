#!/usr/bin/env bash

set -eou pipefail

# Docker push rules
# If on tag (e.g. 1.0.0)
# - any commit is pushed as :<model>-<semver>
# - any commit is pushed as :<model>-latest
# - any commit is pushed as :<model>
git_hash=
remote_repo=${REMOTE_REPO?Variable REMOTE_REPO is required}
docker_username=${DOCKER_USERNAME?Variable DOCKER_USERNAME is required}
docker_password=${DOCKER_PASSWORD?Variable DOCKER_PASSWORD is required}
git_tag=$GITHUB_REF_NAME
model_name="imagebind"

function main() {
  init
  echo "git ref type is $GITHUB_REF_TYPE"
  echo "git ref name is $GITHUB_REF_NAME"
  echo "git tag is $git_tag"
  push_tag
}

function init() {
  if [ ! -z "$MODEL_TAG_NAME" ]; then
    # a model tag name was specified to overwrite the model name. This is the
    # case, for example, when the original model name contains characters we
    # can't use in the docker tag
    model_name="$MODEL_TAG_NAME"
  fi

  git_hash="$(git rev-parse HEAD | head -c 7)"

  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
  docker buildx create --use
  echo "$docker_password" | docker login -u "$docker_username" --password-stdin
}

function push_tag() {
  if [ ! -z "$git_tag" ] && [ "$GITHUB_REF_TYPE" == "tag" ]; then
    tag_git="$remote_repo:$model_name-$git_tag"
    tag_latest="$remote_repo:$model_name-latest"
    tag="$remote_repo:$model_name"

    echo "Tag & Push $tag, $tag_latest, $tag_git"
    docker buildx build --platform=linux/arm64,linux/amd64 \
      --push \
      --tag "$tag_git" \
      --tag "$tag_latest" \
      --tag "$tag" \
      .
  fi
}

main "${@}"

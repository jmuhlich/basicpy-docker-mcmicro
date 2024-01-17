JAX_VERSION=0.4.23

docker buildx build \
    --push \
    --platform linux/amd64,linux/arm64/v8 \
    --build-arg JAX_VERSION="$JAX_VERSION" \
    -t yfukai/conda-jax:$JAX_VERSION \
    -t yfukai/conda-jax:latest \
    "."

docker buildx build \
    --push \
    --platform linux/amd64 \
    --build-arg BASE_IMAGE="nvidia/cuda:11.5.2-cudnn8-devel-ubuntu20.04" \
    --build-arg JAX_VERSION="$JAX_VERSION" \
    --build-arg JAX_VERSION_EXTRA="cuda11_cudnn82" \
    -t yfukai/conda-jax:$JAX_VERSION-cuda \
    -t yfukai/conda-jax:latest-cuda \
    "."

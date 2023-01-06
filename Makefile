MAKEFLAGS	+=	--silent --jobs 1
TAG_PREFIX	:=	ghcr.io/gemtek-indonesia
ARM_CPUS	:=	cortex-a55 cortex-a76 neoverse-n1
CPU_FEATS	:=	"-C target-feature=+neon,+aes,+sha2,+fp16"
RECIPE_BS	:=	$(addprefix native-aarch64-bs-,$(ARM_CPUS))
REGISTRY_BS	:=	$(addprefix push-native-aarch64-bs-,$(ARM_CPUS))

.PHONY: all native-aarch64-bs ${RECIPE_BS} ${REGISTRY_BS}
.ONESHELL: all native-aarch64-bs ${RECIPE_BS} ${REGISTRY_BS}

all: | ${RECIPE_BS}

native-aarch64-bs: | ${RECIPE_BS}

push-native-aarch64-bs: | ${REGISTRY_BS}

$(RECIPE_BS):
	export CURRENT_CPU=$(strip $(subst native-aarch64-bs-,,$@))
	echo "\033[92mBuilding Docker Image - Substrate Builder for $${CURRENT_CPU}\033[0m"
	docker build \
		-t ${TAG_PREFIX}/native-aarch64-$${CURRENT_CPU}:builder-substrate \
		-f native/builder-substrate.Dockerfile \
		--build-arg CPU_ARCH="aarch64" \
		--build-arg CPU_NAME="$${CURRENT_CPU}" \
		--build-arg RUSTFLAGS_FEATURES=${CPU_FEATS} \
		.

$(REGISTRY_BS):
	export CURRENT_CPU=$(strip $(subst push-native-aarch64-bs-,,$@))
	echo "\033[92mPushing Docker Image - Substrate Builder for $${CURRENT_CPU}\033[0m"
	docker push ${TAG_PREFIX}/native-aarch64-$${CURRENT_CPU}:builder-substrate

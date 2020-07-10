
Profile ?= 1
CWD = $(shell pwd)

ifeq ($(Profile),1)
build/Release/ccls: build/Generate/out.profdata
endif

# ifeq ($(MAKECMDGOALS),GenerateOnly)
# build/Generate/out.profdata: GenerateOnly
# 	rm build/Generate/out.profdata || true
# 	rm build/Generate/default.profraw || true
# endif


# .PHONEY: GenerateOnly
# GenerateOnly:
# 	rm build/Generate/out.profdata || true
# 	rm build/Generate/default.profraw || true


build/Release/ccls: build/Release/build.ninja
	ninja -C build/Release ccls

build/Release/build.ninja: build/Release
	cmake -G Ninja \
		-DCMAKE_CXX_COMPILER=${HOME}/.llvm/bin/clang++ \
		-DCMAKE_BUILD_TYPE=Release \
		-DClang_DIR=${HOME}/.llvm/lib/cmake/clang \
		-DUSE_SYSTEM_RAPIDJSON=OFF \
		-S. \
		-Bbuild/Release \
		-DCCLS_LTO=ON \
		-DCCLS_LTO_FLAVOR=full \
		-DCCLS_PROFILE=USE \
		-DCCLS_PROFDATA=$(CWD)/build/Generate/out.profdata \
		-DCMAKE_INSTALL_PREFIX=${HOME}/.local

build/Release:
	mkdir -p build/Release

build/Generate/out.profdata: build/Generate/ccls
	ln -sf build/Generate/compile_commands.json .
	rm -rf .ccls-cache
	build/Generate/ccls --index=.
	cd build/Generate && llvm-profdata merge -output=out.profdata default.profraw

build/Generate/ccls: build/Generate/build.ninja
	ninja -C build/Generate ccls

build/Generate/build.ninja: build/Generate
	cmake -G Ninja \
		-DCMAKE_CXX_COMPILER=${HOME}/.llvm/bin/clang++ \
		-DCMAKE_BUILD_TYPE=$(BuildType) \
		-DClang_DIR=${HOME}/.llvm/lib/cmake/clang \
		-DUSE_SYSTEM_RAPIDJSON=OFF \
		-S. \
		-Bbuild/Generate \
		-DCCLS_LTO=ON \
		-DCCLS_LTO_FLAVOR=thin \
		-DCCLS_PROFILE=GENERATE \
		-DCMAKE_INSTALL_PREFIX=${HOME}/.local

build/Generate:
	mkdir -p build/Generate

# game/app specific values
export APP_VERSION="1.0"
export ICONSDIR="res/mac"
export ICONSFILENAME="AppIcon"
export PRODUCT_NAME="openxcom"
export EXECUTABLE_NAME="openxcom"
export PKGINFO="APPLXCOM"
export COPYRIGHT_TEXT="X-Com Copyright © 1994 Mythos Games. All rights reserved."

#constants
source ../MSPScripts/constants.sh

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
# I think it has to be done in the root because of the bin folder
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake \
-DCMAKE_BUILD_TYPE=Debug \
-DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config \
-DYAMLCPP_INCLUDE_DIR=/usr/local/opt/yaml-cpp/include \
-DYAMLCPP_LIBRARY=/usr/local/opt/yaml-cpp/lib/libyaml-cpp.dylib \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -\
B ${X86_64_BUILD_FOLDER} .
cmake --build ${X86_64_BUILD_FOLDER} -j$NCPU

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cmake \
-DCMAKE_BUILD_TYPE=Debug \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -\
B ${ARM64_BUILD_FOLDER} .
cmake --build ${ARM64_BUILD_FOLDER} -j$NCPU

# create the app bundle
"../MSPScripts/build_app_bundle.sh" "skiplipo"

#lipo the executable
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -create

# we only do one Frameworks folder since the ones OpenRCT2 supplies are Universal 2 already
mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}" || exit 1;
#for some reason libFLAC is only referenced by libSDL_mixer for arm64 so we copy it instead of lipo'ing it
cp -a ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libFLAC.8.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libjpeg.9.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libjpeg.9.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libjpeg.9.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libmikmod.3.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libmikmod.3.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libmikmod.3.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libogg.0.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libogg.0.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libogg.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libpng16.16.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libpng16.16.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libpng16.16.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL_gfx.15.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL_gfx.15.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libSDL_gfx.15.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL_image-1.2.0.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL_image-1.2.0.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libSDL_image-1.2.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL_mixer-1.2.0.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL_mixer-1.2.0.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libSDL_mixer-1.2.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL-1.2.0.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL-1.2.0.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libSDL-1.2.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libtiff.5.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libtiff.5.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libtiff.5.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libvorbis.0.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libvorbis.0.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbis.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.3.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.3.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.3.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libwebp.7.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libwebp.7.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libwebp.7.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libyaml-cpp.0.7.0.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libyaml-cpp.0.7.0.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libyaml-cpp.0.7.0.dylib" -create
cp -a ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libyaml-cpp.0.7.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
cp -a "${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/." "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

#sign and notarize
"../MSPScripts/sign_and_notarize.sh" "$1"
$ALPINE_VERSION="3.17.2"
$GCC_VERSION="12.2.0"
$CMAKE_VERSION="3.25.2"
$OPENCV_VERSION="4.7.0"
$CATCH_VERSION="v3.3.1"

docker build -t morfin/myalpine:$($ALPINE_VERSION)_CMake_$($CMAKE_VERSION) `
    --build-arg ALPINE_VERSION=$ALPINE_VERSION `
    --build-arg GCC_VERSION=$GCC_VERSION `
    --build-arg CMAKE_VERSION=$CMAKE_VERSION `
    .

docker build -t morfin/myalpine:$($ALPINE_VERSION)_CMake_$($CMAKE_VERSION)_OpenCV_$($OPENCV_VERSION)_Release `
    --build-arg ALPINE_VERSION=$ALPINE_VERSION `
    --build-arg GCC_VERSION=$GCC_VERSION `
    --build-arg CMAKE_VERSION=$CMAKE_VERSION `
    --build-arg BUILD_TYPE=RELEASE `
    --build-arg BUILD_OPENCV=ON `
    --build-arg OPENCV_VERSION=$OPENCV_VERSION `
    .

docker build -t morfin/myalpine:$($ALPINE_VERSION)_CMake_$($CMAKE_VERSION)_OpenCV_$($OPENCV_VERSION)_Catch_$($CATCH_VERSION)_Release `
    --build-arg ALPINE_VERSION=$ALPINE_VERSION `
    --build-arg GCC_VERSION=$GCC_VERSION `
    --build-arg CMAKE_VERSION=$CMAKE_VERSION `
    --build-arg BUILD_TYPE=RELEASE `
    --build-arg BUILD_OPENCV=ON `
    --build-arg OPENCV_VERSION=$OPENCV_VERSION `
    --build-arg BUILD_CATCH=ON `
    --build-arg CATCH_VERSION=$CATCH_VERSION `
    .

docker build -t morfin/myalpine:$($ALPINE_VERSION)_CMake_$($CMAKE_VERSION)_OpenCV_$($OPENCV_VERSION)_Debug `
    --build-arg ALPINE_VERSION=$ALPINE_VERSION `
    --build-arg GCC_VERSION=$GCC_VERSION `
    --build-arg CMAKE_VERSION=$CMAKE_VERSION `
    --build-arg BUILD_TYPE=DEBUG `
    --build-arg BUILD_OPENCV=ON `
    --build-arg OPENCV_VERSION=$OPENCV_VERSION `
    .

docker build -t morfin/myalpine:$($ALPINE_VERSION)_CMake_$($CMAKE_VERSION)_OpenCV_$($OPENCV_VERSION)_Catch_$($CATCH_VERSION)_Debug `
    --build-arg ALPINE_VERSION=$ALPINE_VERSION `
    --build-arg GCC_VERSION=$GCC_VERSION `
    --build-arg CMAKE_VERSION=$CMAKE_VERSION `
    --build-arg BUILD_TYPE=DEBUG `
    --build-arg BUILD_OPENCV=ON `
    --build-arg OPENCV_VERSION=$OPENCV_VERSION `
    --build-arg BUILD_CATCH=ON `
    --build-arg CATCH_VERSION=$CATCH_VERSION `
    .

docker build -t morfin/myalpine:$($ALPINE_VERSION)_CMake_$($CMAKE_VERSION)_OpenCV_$($OPENCV_VERSION)_Release_Debug `
    --build-arg ALPINE_VERSION=$ALPINE_VERSION `
    --build-arg GCC_VERSION=$GCC_VERSION `
    --build-arg CMAKE_VERSION=$CMAKE_VERSION `
    --build-arg BUILD_TYPE=RELEASE_DEBUG `
    --build-arg BUILD_OPENCV=ON `
    --build-arg OPENCV_VERSION=$OPENCV_VERSION `
    .

docker build -t morfin/myalpine:$($ALPINE_VERSION)_CMake_$($CMAKE_VERSION)_OpenCV_$($OPENCV_VERSION)_Catch_$($CATCH_VERSION)_Release_Debug `
    --build-arg ALPINE_VERSION=$ALPINE_VERSION `
    --build-arg GCC_VERSION=$GCC_VERSION `
    --build-arg CMAKE_VERSION=$CMAKE_VERSION `
    --build-arg BUILD_TYPE=RELEASE_DEBUG `
    --build-arg BUILD_OPENCV=ON `
    --build-arg OPENCV_VERSION=$OPENCV_VERSION `
    --build-arg BUILD_CATCH=ON `
    --build-arg CATCH_VERSION=$CATCH_VERSION `
    .

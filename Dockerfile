ARG ALPINE_VERSION
FROM alpine:$ALPINE_VERSION as builder

RUN apk add --quiet --no-cache \
  build-base \
  dejagnu \
  isl-dev \
  make \
  mpc1-dev \
  mpfr-dev \
  texinfo \
  zlib-dev

ARG GCC_VERSION
RUN wget -q https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz && \
  tar -xzf gcc-$GCC_VERSION.tar.gz && \
  rm -f gcc-$GCC_VERSION.tar.gz

WORKDIR /gcc-$GCC_VERSION

RUN ./configure \
  --prefix=/usr/local \
  --build=$(uname -m)-alpine-linux-musl \
  --host=$(uname -m)-alpine-linux-musl \
  --target=$(uname -m)-alpine-linux-musl \
  --with-pkgversion="Alpine $GCC_VERSION" \
  --enable-checking=release \
  --disable-fixed-point \
  --disable-libmpx \
  --disable-libmudflap \
  --disable-libsanitizer \
  --disable-libssp \
  --disable-libstdcxx-pch \
  --disable-multilib \
  --disable-nls \
  --disable-symvers \
  --disable-werror \
  --enable-__cxa_atexit \
  --enable-default-pie \
  --enable-languages=c,c++ \
  --enable-shared \
  --enable-threads \
  --enable-tls \
  --with-linker-hash-style=gnu \
  --with-system-zlib
RUN make --silent -j$(nproc)
RUN make --silent -j$(nproc) install-strip

FROM alpine:$ALPINE_VERSION

RUN apk add --quiet --no-cache \
  autoconf \
  automake \
  binutils \
  cmake \
  file \
  ffmpeg-dev \
  git \
  gmp \
  isl-dev \
  libc-dev \
  libffi-dev \
  libjpeg-turbo-dev \
  libpng-dev \
  libressl-dev \
  libwebp-dev \
  linux-headers \
  libtool \
  make \
  musl \
  openblas \
  openblas-dev \
  openjpeg-dev \
  openssl \
  tiff-dev \
  mpc1 \
  mpfr4 \
  musl-dev \
  pkgconf \
  zlib-dev \
  isl-dev \
  python3 \
  python3-dev

COPY --from=builder /usr/local/ /usr/

RUN rm -rf /usr/bin/cc && ln -s /usr/bin/gcc /usr/bin/cc

# Pip install
RUN wget https://bootstrap.pypa.io/get-pip.py && \
  python get-pip.py && \
  python3 get-pip.py && \
  rm get-pip.py

# Pip upgrade
RUN python -m pip install pip --upgrade

#Install virtualenv
RUN python -m pip install virtualenv

# Install PyTest
RUN python -m pip install pytest

# Install NumPy
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN python -m pip install numpy


# Install CMake
ARG CMAKE_VERSION
RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.zip &> /dev/null && \
  unzip cmake-$CMAKE_VERSION.zip &> /dev/null && \
  rm cmake-$CMAKE_VERSION.zip && \
  mv cmake-$CMAKE_VERSION cmake && \
  cd cmake && \
  mkdir build && \
  cd build && \
  cmake .. &> /dev/null && \
  make -j`nproc` && make install && cd ../.. && rm -rf cmake

ARG BUILD_TYPE

# Install OpenCV
ARG BUILD_OPENCV
ARG OPENCV_VERSION
RUN if [[ "$BUILD_OPENCV" == "ON" ]] && [ "$BUILD_TYPE" == "DEBUG" -o "$BUILD_TYPE" == "RELEASE_DEBUG" ] ; then \
  git clone https://github.com/opencv/opencv_contrib.git &> /dev/null && \
  cd opencv_contrib && \
  git checkout $OPENCV_VERSION &> /dev/null && \
  cd .. && \
  git clone https://github.com/opencv/opencv.git &> /dev/null && \
  cd opencv && \
  git checkout $OPENCV_VERSION &> /dev/null && \
  mkdir buildD && \
  cd buildD && \
  cmake \
  -D CMAKE_BUILD_TYPE=DEBUG  \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D INSTALL_PYTHON_EXAMPLES=OFF \
  -D INSTALL_C_EXAMPLES=OFF \
  -D WITH_FFMPEG=ON \
  -D WITH_TBB=ON \
  -D INSTALL_PYTHON_EXAMPLES=OFF \
  -D BUILD_EXAMPLES=OFF \
  -D BUILD_DOCS=OFF \
  -D BUILD_PERF_TESTS=OFF \
  -D BUILD_TESTS=OFF \
  -D BUILD_opencv_apps=OFF \
  -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
  -D BUILD_opencv_python2=OFF \
  -D PYTHON3_INCLUDE_DIR=$(python3 -c 'from distutils.sysconfig import get_python_inc; print(get_python_inc())') \
  -D PYTHON3_PACKAGES_PATH=$(python3 -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())') \
  -D PYTHON3_EXECUTABLE=$(which python3) \
  -D PYTHON_DEFAULT_EXECUTABLE=$(which python3) \
  -S .. -B . ; \
  make -j`nproc` && make install && cd ../.. && \
  rm -rf opencv opencv_contrib ; fi
RUN if [[ "$BUILD_OPENCV" == "ON" ]] && [ "$BUILD_TYPE" == "RELEASE" -o "$BUILD_TYPE" == "RELEASE_DEBUG" ] ; then \
  git clone https://github.com/opencv/opencv_contrib.git &> /dev/null && \
  cd opencv_contrib && \
  git checkout $OPENCV_VERSION &> /dev/null && \
  cd .. && \
  git clone https://github.com/opencv/opencv.git &> /dev/null && \
  cd opencv && \
  git checkout $OPENCV_VERSION &> /dev/null && \
  mkdir buildR && \
  cd buildR && \
  cmake \
  -D CMAKE_BUILD_TYPE=RELEASE  \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D INSTALL_PYTHON_EXAMPLES=OFF \
  -D INSTALL_C_EXAMPLES=OFF \
  -D WITH_FFMPEG=ON \
  -D WITH_TBB=ON \
  -D INSTALL_PYTHON_EXAMPLES=OFF \
  -D BUILD_EXAMPLES=OFF \
  -D BUILD_DOCS=OFF \
  -D BUILD_PERF_TESTS=OFF \
  -D BUILD_TESTS=OFF \
  -D BUILD_opencv_apps=OFF \
  -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
  -D BUILD_opencv_python2=OFF \
  -D PYTHON3_INCLUDE_DIR=$(python3 -c 'from distutils.sysconfig import get_python_inc; print(get_python_inc())') \
  -D PYTHON3_PACKAGES_PATH=$(python3 -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())') \
  -D PYTHON3_EXECUTABLE=$(which python3) \
  -D PYTHON_DEFAULT_EXECUTABLE=$(which python3) \
  -S .. -B . ; \
  make -j`nproc` && make install && cd ../.. && \
  rm -rf opencv opencv_contrib ; fi

# Install Catch
ARG BUILD_CATCH
ARG CATCH_VERSION
RUN if [[ "$BUILD_CATCH" == "ON" ]] && [ "$BUILD_TYPE" == "DEBUG" -o "$BUILD_TYPE" == "RELEASE_DEBUG" ] ; then \
  git clone https://github.com/catchorg/Catch2.git &> /dev/null && \
  cd Catch2 && \
  git checkout $CATCH_VERSION &> /dev/null && cd .. && \
  mkdir buildD && \
  cd buildD && \
  cmake -D CMAKE_BUILD_TYPE=DEBUG \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    ../Catch2 && \
  make -j`nproc` && make install && cd .. && rm -rf Catch2 buildD ; fi
RUN if [[ "$BUILD_CATCH" == "ON" ]] && [ "$BUILD_TYPE" == "RELEASE" -o "$BUILD_TYPE" == "RELEASE_DEBUG" ] ; then \
  git clone https://github.com/catchorg/Catch2.git &> /dev/null && \
  cd Catch2 && \
  git checkout $CATCH_VERSION &> /dev/null && cd .. && \
  mkdir buildR && \
  cd buildR && \
  cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    ../Catch2 && \
  make -j`nproc` && make install && cd .. && rm -rf Catch2 buildR ; fi

WORKDIR /src

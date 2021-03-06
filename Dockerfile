FROM alpine:3.11 as builder

RUN apk add --quiet --no-cache \
  build-base \
  dejagnu \
  isl-dev \
  make \
  mpc1-dev \
  mpfr-dev \
  texinfo \
  zlib-dev
RUN wget -q https://ftp.gnu.org/gnu/gcc/gcc-9.2.0/gcc-9.2.0.tar.gz && \
  tar -xzf gcc-9.2.0.tar.gz && \
  rm -f gcc-9.2.0.tar.gz

WORKDIR /gcc-9.2.0

RUN ./configure \
  --prefix=/usr/local \
  --build=$(uname -m)-alpine-linux-musl \
  --host=$(uname -m)-alpine-linux-musl \
  --target=$(uname -m)-alpine-linux-musl \
  --with-pkgversion="Alpine 9.2.0" \
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

FROM alpine:3.11

RUN apk add --quiet --no-cache \
  autoconf \
  automake \
  binutils \
  cmake \
  file \
  git \
  gmp \
  isl \
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
  python \
  python-dev \
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
RUN python3 -m pip install pip --upgrade

#Install virtualenv
RUN python -m pip install virtualenv
RUN python3 -m pip install virtualenv

# Install PyTest
RUN python -m pip install pytest
RUN python3 -m pip install pytest

# Install NumPy
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN python -m pip install numpy
RUN python3 -m pip install numpy

# Install CMake 3.16.4
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.4/cmake-3.16.4.zip &> /dev/null && \
  unzip cmake-3.16.4.zip &> /dev/null && \
  rm cmake-3.16.4.zip && \
  mv cmake-3.16.4 cmake && \
  cd cmake && \
  mkdir build && \
  cd build && \
  cmake .. &> /dev/null && \
  make -j$(nproc) && make install && cd ../.. && rm -rf cmake

# Install OpenCV 4.2.0
RUN git clone https://github.com/opencv/opencv_contrib.git &> /dev/null && \
  cd opencv_contrib && \
  git checkout 4.2.0 &> /dev/null && \
  cd .. && \
  git clone https://github.com/Itseez/opencv.git &> /dev/null && \
  cd opencv && \
  git checkout 4.2.0 &> /dev/null && \
  mkdir buildD && mkdir buildR && \
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
  -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
  -D PYTHON_EXECUTABLE=/usr/local/bin/python .. && \
  make -j$(nproc) && make install && cd ../.. && \
  cp -p $(find /usr/local/lib/python3.8/site-packages -name cv2.*.so) \
  /usr/lib/python3.8/site-packages/cv2.so && rm -rf opencv opencv_contrib

# Install Catch v2.11.1
# RUN git clone https://github.com/catchorg/Catch2.git &> /dev/null && \
#   cd Catch2 && \
#   git checkout v2.11.1 &> /dev/null && \
#   cd .. && \
#   mkdir build && \
#   cd build && \
#   cmake ../Catch2 && \
#   make -j$(nproc) && make install && cd .. && \
#   cd -D CMAKE_BUILD_TYPE=RELEASE .. && rm -rf Catch2 build

WORKDIR /src
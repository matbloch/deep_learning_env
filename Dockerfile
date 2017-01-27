#FROM ubuntu:14.04
#FROM ubuntu:16.04
FROM kaixhin/caffe
MAINTAINER Matthias Bloch <matbloch@ethz.ch>

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    gfortran \
    git \
    graphicsmagick \
    libgraphicsmagick1-dev \
	libatlas-base-dev \
	libatlas-dev \
    libavcodec-dev \
    libavformat-dev \
    libboost-all-dev \
    libgtk2.0-dev \
    libjpeg-dev \
    liblapack-dev \
    libswscale-dev \
    pkg-config \
	libopencv-dev \
    python-dev \
    python-pip \
    python-numpy \
    python-nose \
    python-scipy \
    python-pandas \
    python-protobuf\
    python-setuptools \
	libprotobuf-dev \
	libgoogle-glog-dev \
	libgflags-dev \
	protobuf-compiler \
	libhdf5-dev \
	libleveldb-dev \
	liblmdb-dev \
	libsnappy-dev \
	bc \
	gfortran > /dev/null \
    software-properties-common \
    wget \
    zip \
	python-matplotlib \
	python-pil \
	build-essential \
	cython \
	python-skimage \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	
# --------- Torch
RUN curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash -e
RUN git clone https://github.com/torch/distro.git ~/torch --recursive
RUN cd ~/torch && ./install.sh && \
    cd install/bin && \
    ./luarocks install nn && \
    ./luarocks install dpnn && \
    ./luarocks install image && \
    ./luarocks install optim && \
    ./luarocks install csvigo && \
    ./luarocks install torchx && \
    ./luarocks install tds

RUN ln -s /root/torch/install/bin/* /usr/local/bin
	
# --------- OpenCV
RUN cd ~ && \
    mkdir -p ocv-tmp && \
    cd ocv-tmp && \
    curl -L https://github.com/Itseez/opencv/archive/2.4.11.zip -o ocv.zip && \
    unzip ocv.zip && \
    cd opencv-2.4.11 && \
    mkdir release && \
    cd release && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D BUILD_PYTHON_SUPPORT=ON \
          .. && \
    make -j8 && \
    make install && \
    rm -rf ~/ocv-tmp

# --------- Dlib
RUN cd ~ && \
    mkdir -p dlib-tmp && \
    cd dlib-tmp && \
    curl -L \
         https://github.com/davisking/dlib/archive/v19.0.tar.gz \
         -o dlib.tar.bz2 && \
    tar xf dlib.tar.bz2 && \
    cd dlib-19.0/python_examples && \
    mkdir build && \
    cd build && \
    cmake ../../tools/python && \
    cmake --build . --config Release && \
    cp dlib.so /usr/local/lib/python2.7/dist-packages && \
rm -rf ~/dlib-tmp

# --------- OpenFace

RUN cd /root && git clone https://github.com/cmusatyalab/openface.git && \
cd openface && \
# download models
./models/get-models.sh && \
pip2 install -r requirements.txt && \
python2 setup.py install && \
pip2 install -r demos/web/requirements.txt && \
pip2 install -r training/requirements.txt

# Add to Python path
ENV PYTHONPATH=/root/openface:$PYTHONPATH

# --------- Python packages
ADD . /root/deep_learning_utils
RUN cd /root/deep_learning_utils && \
    pip2 install -r requirements.txt
	
# Add to Python path
ENV PYTHONPATH=/root/deep_learning_utils:$PYTHONPATH

EXPOSE 8000 9000

# Set the default directory where CMD will execute
WORKDIR /root/deep_learning_utils

FROM bentou/ubuntuxenialbazel

# Download and build TensorFlow.

RUN git clone https://github.com/tensorflow/tensorflow.git && \
    cd tensorflow && \
    git checkout r0.11
WORKDIR /tensorflow

# TODO(craigcitro): Don't install the pip package, since it makes it
# more difficult to experiment with local changes. Instead, just add
# the built directory to the path.

RUN apt-get update && apt-get install -y swig

#RUN tensorflow/tools/ci_build/builds/configured CPU
RUN ./configure
RUN bazel build -c opt //tensorflow:libtensorflow.so

#RUN tensorflow/tools/ci_build/builds/configured CPU \
#    bazel build -c opt tensorflow/tools/pip_package:build_pip_package && \
#    bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip && \
#    pip install --upgrade /tmp/pip/tensorflow-*.whl && \
#    rm -rf /tmp/pip && \
#    rm -rf /root/.cache
# Clean up pip wheel and Bazel cache when done.

RUN cp bazel-bin/tensorflow/libtensorflow.so /usr/local/lib

ENV GOLANG_VERSION 1.7.3
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 508028aac0654e993564b6e2014bf2d4a9751e3b286661b0b0040046cf18028e

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

COPY go-wrapper /usr/local/bin/


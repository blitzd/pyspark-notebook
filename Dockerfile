FROM buildpack-deps:trusty


# install java
RUN \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    apt-get install -y oracle-java7-installer && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk7-installer

ENV JAVA_HOME /usr/lib/jvm/java-7-oracle


# install spark
ENV SPARK_VERSION 1.4.0
ENV SPARK_HOME /usr/local/src/spark-$SPARK_VERSION

RUN \
    mkdir -p $SPARK_HOME && \
    curl -SL "http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION.tgz" -o spark.tgz && \
    tar -xzC $SPARK_HOME --strip-components=1 -f spark.tgz && \
    rm spark.tgz && \
    cd $SPARK_HOME && \
    build/mvn -DskipTests clean package

ENV PYTHONPATH $SPARK_HOME/python/:$PYTHONPATH


# install python
ENV PYTHON_VERSION 2.7.10
ENV PYTHON_SOURCE /usr/local/src/python-$PYTHON_VERSION

# get python source
RUN \
    mkdir -p $PYTHON_SOURCE && \
    curl -SL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz && \
    tar -xJC $PYTHON_SOURCE --strip-components=1 -f python.tar.xz && \
    rm python.tar.xz && \
    cd $PYTHON_SOURCE && \
    ./configure --enable-shared --enable-unicode=ucs4 && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    curl -SL 'https://bootstrap.pypa.io/get-pip.py' | python2 && \
    rm -rf $PYTHON_SOURCE && \
    find /usr/local/lib/python2.7 \
        \( -type d -a -name test -o -name tests \) -o \
        \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
        | xargs rm -rf


# install python packages
RUN apt-get install -y libatlas-base-dev gfortran python-zmq

RUN pip install py4j \
    ipython[notebook] \
    jsonschema \
    jinja2 \
    terminado \
    tornado \
    pygments \
    pyyaml \
    numpy

RUN pip install scipy \
    scikit-learn \
    numexpr \
    pandas

RUN pip install matplotlib \
    seaborn \
    bokeh

# install notebook
RUN ipython profile create pyspark
COPY pyspark-notebook.py /root/.ipython/profile_pyspark/startup/pyspark-notebook.py

VOLUME /notebook
WORKDIR /notebook

EXPOSE 8888

CMD ipython notebook --no-browser --profile=pyspark --ip=*

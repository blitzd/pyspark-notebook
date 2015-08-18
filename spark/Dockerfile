FROM ubuntu:trusty

MAINTAINER Prabeesh K.

RUN \
    apt-get -y update &&\
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" > /etc/apt/sources.list.d/webupd8team-java.list &&\
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list.d/webupd8team-java.list &&\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 &&\
    apt-get -y update &&\
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections &&\
    apt-get install -y oracle-java7-installer &&\
    apt-get install -y curl

ENV SPARK_VERSION 1.4.1
ENV SPARK_HOME /usr/local/src/spark-$SPARK_VERSION

RUN \
    mkdir -p $SPARK_HOME &&\
    curl -s http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION.tgz | tar -xz -C $SPARK_HOME --strip-components=1 &&\
    cd $SPARK_HOME &&\
    build/mvn -DskipTests clean package

RUN echo 'export PATH=/opt/anaconda/bin:$PATH' > /etc/profile.d/conda.sh
RUN ( echo "=======================" ) && \
    ( echo "Installing Python      " ) && \
    ( echo "=======================" ) && \
    wget --quiet http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash /Miniconda3-latest-Linux-x86_64.sh -b -p /opt/anaconda && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    test -f /opt/anaconda/bin/conda && \
    export PATH=/opt/anaconda/bin:$PATH && \
    conda install --yes pip && \
    conda install --yes numpy && \
    conda install --yes scipy && \
    conda install --yes matplotlib && \
    conda install --yes ipython==3.2 && \
    conda install --yes scikit-learn && \
    conda install --yes scikit-image && \
    conda install --yes pandas && \
    conda install --yes requests && \
    conda install --yes h5py && \ 
    conda install --yes pyzmq && \
    conda install --yes tornado && \
    conda install --yes jinja2 && \
    conda install --yes jsonschema

ENV PYSPARK_PYTHON /opt/anaconda/bin/ipython

RUN /opt/anaconda/bin/ipython profile create pyspark

RUN apt-get clean &&\
    /opt/anaconda/bin/conda clean -y -i -t -p

RUN cd $SPARK_HOME && \
    mkdir packages && \
    cd packages && \
    wget http://central.maven.org/maven2/com/databricks/spark-csv_2.10/1.2.0/spark-csv_2.10-1.2.0.jar && \
    cd ~ && \
    wget http://apache.mirror.iweb.ca//commons/csv/binaries/commons-csv-1.1-bin.tar.gz && \
    tar xzf commons-csv-1.1-bin.tar.gz && \
    mv commons-csv-1.1/commons-csv-1.1.jar $SPARK_HOME/packages && \
    rm -rf commons-csv*

COPY pyspark-notebook.py /root/.ipython/profile_pyspark/startup/pyspark-notebook.py

VOLUME /notebook
WORKDIR /notebook

EXPOSE 8888

ENV PYSPARK_DRIVER_PYTHON=/opt/anaconda/bin/ipython 
ENV PYSPARK_DRIVER_PYTHON_OPTS="notebook --no-browser --notebook-dir=/notebook --ip=*" 
CMD $SPARK_HOME/bin/pyspark --jars $SPARK_HOME/packages/spark-csv_2.10-1.2.0.jar,$SPARK_HOME/packages/commons-csv-1.1.jar
#CMD /opt/anaconda/bin/ipython notebook --no-browser --profile=pyspark --ip=*

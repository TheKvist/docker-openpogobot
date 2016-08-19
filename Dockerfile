FROM centos:centos7

RUN yum -y install epel-release && \
    yum -y update && \
    yum -y install \
		python-pip \
		python-virtualenv \
		protobuf-python \
		python-devel \
		gcc \
		make \
		git && \
    yum -y clean all

ENV OpenPoGoBotVersion master
ENV OpenPoGoBotRepository https://github.com/torvitas/OpenPoGoBot.git
RUN mkdir -p /usr/local/pogobot && \
    cd /usr/local/pogobot && \
    git clone ${OpenPoGoBotRepository} . && \
    git checkout ${OpenPoGoBotVersion} && \
    virtualenv env && \
    source env/bin/activate && \
    pip install setuptools pip --upgrade && \
    pip install -r requirements.txt
RUN cd /tmp/ && \
    curl -O http://pgoapi.com/pgoencrypt.tar.gz && \
    tar zxvf pgoencrypt.tar.gz && \
    cd pgoencrypt/src/ && \
    make lib && \
    cp -r libencrypt.so /usr/local/lib/ && \
    cd / && \
    rm -rf /tmp/*
WORKDIR "/usr/local/pogobot/"
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["python", "pokecli.py", "config/config.yml"]
VOLUME ["/usr/local/pogobot/data"]
COPY src/ /usr/local/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

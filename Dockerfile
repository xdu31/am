FROM java:8-jre
# Optional set of tools for debugging
RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
# As suggested by a user, for some people this line works instead of the first one. Use whichever works for your case
# RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list
RUN sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
RUN apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install telnet \
    && apt-get install dnsutils -y \
    && apt-get install vim -y
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME
# See https://www.apache.org/dist/tomcat/tomcat-8/KEYS
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
05AB33110949707C93A279E3D3EFE6B686867BA6 \
07E48665A34DCAFAE522E5E6266191C37C037D42 \
47309207D818FFD8DCD3F83F1931D684307A10A5 \
541FBE7D8F78B25E055DDEE13C370389288584E7 \
61B832AC2F1C5A90F0F9B00A1C506407564C17A3 \
79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED \
9BA44C2621385CB966EBA586F72C284D731FABEE \
A27677289986DB50844682F8ACB77FC2E86E29AC \
A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 \
DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 \
F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE \
F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.5.59
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
RUN set -x \
    && curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
    && curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
    && gpg --verify tomcat.tar.gz.asc \
    && tar -xvf tomcat.tar.gz --strip-components=1 \
    && rm bin/*.bat \
    && rm tomcat.tar.gz*
EXPOSE 8080
ENV AM_VERSION 6.5.0
ADD ./artifacts/AM-${AM_VERSION}.zip /tmp
RUN unzip /tmp/AM-${AM_VERSION}.zip -d /opt \
    && cp /opt/openam/AM-eval-${AM_VERSION}.war $CATALINA_HOME/webapps/openam.war \
    && rm /tmp/AM-${AM_VERSION}.zip
ENV AM_HOME /opt/openam
ENV PATH $AM_HOME:$PATH
CMD ["catalina.sh", "run"]

FROM tomcat:7-jre8

ENV TOMCAT_WEBAPPS "$CATALINA_HOME"/webapps
ENV OFFICE_HOME /usr/lib/libreoffice

# current Stylesheets stable (= master branch) version 
# https://github.com/TEIC/Stylesheets/releases
ENV STYLESHEETS_URL https://github.com/TEIC/Stylesheets/releases/download/v7.43.0/tei-xsl-7.43.0.zip

# current Stylesheets development version
# ENV STYLESHEETS_URL http://jenkins.tei-c.org/job/Stylesheets-dev/lastSuccessfulBuild/artifact/tei-xsl-7.44.0a.zip

# current TEI Guidelines stable (= master branch) version 
# https://github.com/TEIC/TEI/releases
ENV GUIDELINES_URL https://github.com/TEIC/TEI/releases/download/P5_Release_3.2.0/tei-3.2.0.zip

# current TEI Guidelines development version
# ENV GUIDELINES_URL http://jenkins.tei-c.org/job/TEIP5-dev/lastSuccessfulBuild/artifact/P5/tei-3.3.0a.zip

USER root:root
COPY oxgarage.properties /etc/
COPY log4j.xml /var/cache/oxgarage/log4j.xml

ADD $STYLESHEETS_URL /tmp/
ADD $GUIDELINES_URL /tmp/

#COPY tei-xsl-7.43.0.zip /tmp/tei-xsl-7.43.0.zip
#COPY tei-3.2.0.zip /tmp/tei-3.2.0.zip
COPY ege-webclient-0.3.war /tmp/ege-webclient.war
COPY ege-webservice-0.5.2.war /tmp/ege-webservice.war

RUN unzip -q /tmp/tei-xsl*.zip -d  /usr/share/ \
    && rm -Rf /tmp/tei-xsl*.zip \
    && unzip -q /tmp/tei-*.zip -d  /usr/share/ \
    && rm -Rf /tmp/tei-*.zip \
        /usr/share/doc/tei-* \
        /usr/share/xml/tei/Exemplars \
        /usr/share/xml/tei/Test \
        /usr/share/xml/tei/xquery \
        /usr/share/xml/tei/odd/Utilities \
        /usr/share/xml/tei/odd/ReleaseNotes \
        /usr/share/xml/tei/custom/templates 
        
RUN mkdir "$TOMCAT_WEBAPPS"/ege-webclient \
    && unzip -q /tmp/ege-webclient.war -d "$TOMCAT_WEBAPPS"/ege-webclient/ \
    && rm /tmp/ege-webclient.war
RUN mkdir "$TOMCAT_WEBAPPS"/ege-webservice \
    && unzip -q /tmp/ege-webservice.war -d "$TOMCAT_WEBAPPS"/ege-webservice/ \
    && rm /tmp/ege-webservice.war
# RUN apk --update add libreoffice \

# https://www.howtoinstall.co/en/ubuntu/xenial/fonts-noto
# RUN ["/bin/bash", "-c", "apt-get update -qq && apt-get install -y libreoffice ttf-dejavu ttf-linux-libertine font-noto && ln -s $OFFICE_HOME /usr/lib/openoffice"]
RUN apt-get update -qq && apt-get install -y apt-utils libreoffice \
# RUN apk --update add libreoffice \
    ttf-dejavu \
    ttf-linux-libertine \ 
    fonts-noto \
    procps \
    && ln -s $OFFICE_HOME /usr/lib/openoffice 

COPY webservice_web.xml "$TOMCAT_WEBAPPS"/ege-webservice/WEB-INF/web.xml
COPY tomcat-users.xml "$CATALINA_HOME"/conf/tomcat-users.xml

COPY manager-context.xml "$TOMCAT_WEBAPPS"/manager/META-INF/context.xml
COPY manager-context.xml "$TOMCAT_WEBAPPS"/host-manager/META-INF/context.xml

# add some Jetty jars needed for CORS support
ADD http://central.maven.org/maven2/org/eclipse/jetty/jetty-servlets/9.4.7.v20170914/jetty-servlets-9.4.7.v20170914.jar "$TOMCAT_WEBAPPS"/ege-webservice/WEB-INF/lib/
ADD http://central.maven.org/maven2/org/eclipse/jetty/jetty-util/9.4.7.v20170914/jetty-util-9.4.7.v20170914.jar "$TOMCAT_WEBAPPS"/ege-webservice/WEB-INF/lib/

#RUN chown -R tomcat:tomcat /var/cache/oxgarage \
#    "$TOMCAT_WEBAPPS"/*

#USER tomcat:tomcat
ADD tomcat/tomcat-users.xml $CATALINA_HOME/conf/

ADD tomcat/run.sh $CATALINA_HOME/bin/run.sh
RUN chmod +x $CATALINA_HOME/bin/run.sh

ENV JPDA_ADDRESS="8000"
ENV JPDA_TRANSPORT="dt_socket"


EXPOSE 8080
CMD ["run.sh"]


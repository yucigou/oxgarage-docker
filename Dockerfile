FROM tomcat:7-jre8

ENV TOMCAT_WEBAPPS "$CATALINA_HOME"/webapps
ENV OFFICE_HOME /usr/lib/libreoffice

# current Stylesheets stable (= master branch) version 
ENV STYLESHEETS_URL http://jenkins.tei-c.org/job/Stylesheets/lastSuccessfulBuild/artifact/tei-xsl-7.43.0.zip

# current TEI Guidelines stable (= master branch) version
ENV GUIDELINES_URL http://jenkins.tei-c.org/job/TEIP5/lastSuccessfulBuild/artifact/P5/tei-3.2.0.zip

USER root:root
COPY oxgarage.properties /etc/
COPY log4j.xml /var/cache/oxgarage/log4j.xml

ADD $STYLESHEETS_URL /tmp/
ADD $GUIDELINES_URL /tmp/

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

# https://www.howtoinstall.co/en/ubuntu/xenial/fonts-noto
RUN apt-get update -qq && apt-get install -y apt-utils libreoffice \
    ttf-dejavu \
    ttf-linux-libertine \ 
    fonts-noto \
    procps \
    && ln -s $OFFICE_HOME /usr/lib/openoffice 

COPY webservice_web.xml "$TOMCAT_WEBAPPS"/ege-webservice/WEB-INF/web.xml

# add some Jetty jars needed for CORS support
ADD http://central.maven.org/maven2/org/eclipse/jetty/jetty-servlets/9.4.7.v20170914/jetty-servlets-9.4.7.v20170914.jar "$TOMCAT_WEBAPPS"/ege-webservice/WEB-INF/lib/
ADD http://central.maven.org/maven2/org/eclipse/jetty/jetty-util/9.4.7.v20170914/jetty-util-9.4.7.v20170914.jar "$TOMCAT_WEBAPPS"/ege-webservice/WEB-INF/lib/


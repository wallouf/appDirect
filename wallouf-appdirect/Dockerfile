FROM tomcat:8.0.20-jre8

RUN mkdir /apps

WORKDIR /apps/

EXPOSE 8080

RUN ln -s /usr/local/tomcat/ /apps/tomcat

RUN rm -Rf /usr/local/tomcat/webapps/*

COPY  wallouf-appdirect-application/target/*.tar.gz /apps

RUN tar -zxvf /apps/*.tar.gz

RUN rm /apps/*.tar.gz

CMD ["/apps/wallouf-appdirect-application/wallouf-appdirect-boot.sh","start"]


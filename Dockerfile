FROM maven:3.6.1-jdk-8-alpine as base 
	
	COPY pom.xml .
	RUN mvn dependency:go-offline
	
	RUN mkdir -p /opt/app
	COPY . /opt/app
	WORKDIR /opt/app/
	
	RUN mvn package
	
	####################################################
	################# Production Image #################
	####################################################
	FROM amazoncorretto:8u222 as run 
	LABEL MAINTAINER Florian Tieben <Sreeni@daimler.com>

	EXPOSE 8080
	
	RUN yum install shadow-utils.x86_64 -y
	RUN adduser java --uid 1008
	USER java
	
	COPY --from=base /opt/app/target/pipelines-java-*.jar /opt/pipelines-java.jar
	CMD exec java $JAVA_OPTS -jar /opt/pipelines-java.jar
	#ENTRYPOINT ["java", "-jar", "/opt/pipelines-java.jar"]

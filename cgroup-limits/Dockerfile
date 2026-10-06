FROM eclipse-temurin:21.0.5_11-jdk
WORKDIR /app
COPY Hog.java .
RUN javac Hog.java
# heap ceiling above the cgroup limit on purpose: the JVM believes it may grow, the kernel disagrees
ENTRYPOINT ["java", "-Xmx512m", "Hog"]

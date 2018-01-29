FROM docker.elastic.co/logstash/logstash-oss:6.1.1

RUN bin/logstash-plugin install logstash-output-amazon_es

ADD mysql-connector-java-5.1.41-bin.jar /usr/share/logstash/mysql-connector-java-5.1.41-bin.jar
ADD logstash.conf /usr/share/logstash/pipeline/logstash.conf
ADD logstash-output.conf /usr/share/logstash/pipeline/logstash-output.conf

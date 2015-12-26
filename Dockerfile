FROM index.alauda.cn/library/ubuntu
MAINTAINER titushuang "ituzhi@163.com"
ENV REFRESHED_AT 2015-10-12

RUN apt-get update \
    && apt-get install -y mysql-server-5.6 python python-dev python-pip libmysqlclient-dev nginx

RUN pip install MySQL-python flask 
RUN pip install -U flask-cors

RUN mkdir -p /home/toptopic /home/toptopic/web

COPY init.sh /home/toptopic/init.sh
COPY web /home/toptopic/web
COPY question.txt /home/toptopic/question.txt

COPY nginx/global.conf /etc/nginx/conf.d/
COPY nginx/nginx.conf /etc/nginx/nginx.conf

RUN ln -s /home/toptopic/web/www /usr/share/nginx/html

RUN chmod +x /home/toptopic/init.sh 
RUN chmod -R 755 /home/toptopic/web

RUN ./etc/init.d/mysql start &&\  
    mysql -e "grant all privileges on *.* to 'root'@'%' identified by 'dbpasswd';"&&\  
    mysql -e "grant all privileges on *.* to 'root'@'127.0.0.1' identified by 'dbpasswd';"&&\  
    mysql -e "CREATE DATABASE top_topic_zhihu; use top_topic_zhihu;"&&\ 
    mysql -e "CREATE TABLE top_topic_zhihu.question(question_id varchar(30) NOT NULL, title varchar(200), ask_time datetime,followers int)"&&\ 
    mysql -e "load data infile '/home/toptopic/question.txt' into table top_topic_zhihu.question fields terminated by ';;'"&&\ 
    mysql -e "grant all privileges on *.* to 'root'@'localhost' identified by 'dbpasswd';"

EXPOSE 2223 5000

CMD [ "service mysqld start && /etc/init.d/nginx start" ]
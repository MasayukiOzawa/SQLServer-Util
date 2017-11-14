# https://github.com/Microsoft/mssql-docker
# http://docs.docker.jp/engine/reference/builder.html
# https://github.com/twright-msft/mssql-node-docker-demo-app
# docker build -t sqlserver .
# docker run -d --name sqlcontainer -d -p 1433:1433 sqlserver
# docker logs -f --tail 10 sqlcontainer

FROM microsoft/mssql-server-linux:latest
COPY ./setupdb.sh /tmp
RUN chmod +x /tmp/setupdb.sh
COPY ./docker-entrypoint.sh /usr/mssql/docker-entrypoint.sh
# COPY ./WideWorldImporters-Full.bak /var/opt/mssql/data/WideWorldImporters-Full.bak
ENV SA_PASSWORD=G02HDsQToOn116
ENV MSSQL_PID=Express
ENV ACCEPT_EULA=Y
ENV MSSQL_LCID=1041
ENV TZ=Asia/Tokyo
EXPOSE 1433
ENTRYPOINT [ "/bin/bash", "/usr/mssql/docker-entrypoint.sh" ]

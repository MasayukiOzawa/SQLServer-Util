FROM datadog/agent:7.52.0
RUN apt-get update && apt-get install -y \
    unixodbc \
    libodbc2 \
    libodbcinst2 \
    unixodbc-common \
    libltdl7 \
    odbcinst \
    openssl \
    libreadline8 \
    readline-common 
RUN curl  https://packages.microsoft.com/ubuntu/23.04/prod/pool/main/m/msodbcsql18/msodbcsql18_18.3.2.1-1_amd64.deb -o /tmp/msodbcsql18_18.3.2.1-1_amd64.deb
RUN ACCEPT_EULA=y dpkg -i /tmp/msodbcsql18_18.3.2.1-1_amd64.deb && rm /tmp/msodbcsql18_18.3.2.1-1_amd64.deb
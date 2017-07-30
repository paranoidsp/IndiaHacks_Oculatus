FROM r-base:latest

MAINTAINER Tanmai Gopal "tanmaig@hasura.io"

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev/unstable \
    libxt-dev \
    libssl-dev

# Download and install shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

RUN R -e "install.packages(c('googleVis','tm.plugin.sentiment','shiny', 'rmarkdown', 'tm', 'wordcloud', 'memoise','RColorBrewer','rJava','tm.plugin.webmining','devtools','rhighcharts','corrplot'), repos='http://cran.rstudio.com/')"

RUN R -e "install_github("metagraf/rHighcharts")"

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY /myapp /srv/shiny-server/
COPY /RData /srv/shiny-server/

EXPOSE 80

COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
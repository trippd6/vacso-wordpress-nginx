FROM centos:7

RUN groupadd nginx -g 33 && \
    useradd -u 33 -g 33 nginx

RUN yum update -y && \
    yum install pcre-devel pcre-static pcre openssl openssl-libs openssl-devel libxml2 libxml2-devel libxslt libxslt-devel gd-devel perl-ExtUtils-Embed GeoIP-devel gperftools-devel -y && \
    yum groupinstall "Development tools" -y && \
    yum clean all

COPY nginx-1.10.1.tar.gz /tmp/

COPY ngx_cache_purge.tar.gz /tmp/

WORKDIR /tmp/

RUN tar -xvzf nginx-1.10.1.tar.gz

RUN tar -xvzf ngx_cache_purge.tar.gz 

WORKDIR /tmp/nginx-1.10.1

RUN ./configure  --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-ipv6 --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module --with-http_image_filter_module --with-http_geoip_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_stub_status_module --with-http_perl_module --with-mail --with-mail_ssl_module --with-pcre --with-pcre-jit --with-google_perftools_module --with-debug --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic' --with-ld-opt='-Wl,-z,relro -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -Wl,-E'  --add-module=../ngx_cache_purge

RUN make

RUN make install

RUN mkdir /var/lib/nginx

RUN mkdir /var/lib/nginx/tmp

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

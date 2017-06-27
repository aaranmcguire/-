FROM bvlc/caffe:gpu

## Run Updates
RUN apt update; \
	apt upgrade -y --no-install-recommends;

## Install Helpers & Dependencies
RUN apt install -y --no-install-recommends \
	curl \
	wget \
	sudo \
	libssl-dev;

## Install Torch7
ENV TORCH_ROOT '/opt/torch'
RUN apt install -y --no-install-recommends \
	git \
	software-properties-common;

RUN git clone https://github.com/torch/distro.git $TORCH_ROOT --recursive; \
	cd $TORCH_ROOT; \
	$TORCH_ROOT/install-deps; \
	$TORCH_ROOT/install.sh -b;

ENV LUA_PATH '/opt/torch/install/share/lua/5.1/?.lua;/opt/torch/install/share/lua/5.1/?/init.lua;./?.lua;/opt/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
ENV LUA_CPATH '/opt/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
ENV PATH /opt/torch/install/bin:$PATH
ENV LD_LIBRARY_PATH /opt/torch/install/lib:$LD_LIBRARY_PATH
ENV DYLD_LIBRARY_PATH /opt/torch/install/lib:$DYLD_LIBRARY_PATH
ENV LUA_CPATH /opt/torch/install/lib/?.so;$LUA_CPATH

RUN luarocks install dpnn; \
	luarocks install nn; \
	luarocks install cutorch; \
	luarocks install cunn;

RUN git clone https://github.com/soumith/cudnn.torch -b R6; \
	cd cudnn.torch; \
	luarocks make;

# Install OpenResty
RUN wget -qO - https://openresty.org/package/pubkey.gpg | sudo apt-key add -; \
	add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"; \
	apt update;
RUN apt install -y --no-install-recommends \
	openresty;

# Install Lua Lapis
RUN luarocks install lapis;

# Install PostgreSQL
RUN apt install -y --no-install-recommends \
	postgresql;

RUN /etc/init.d/postgresql start &&\
	su - postgres -c "psql --command \"CREATE USER fiber WITH SUPERUSER PASSWORD 'fiber';\"" &&\
	su - postgres -c "createdb -O fiber fiber";

# Install Application
COPY ./src /workspace/FiberClasification

EXPOSE 8080:8080

ENTRYPOINT ["/bin/sh", "-c", "cd /workspace/FiberClasification; lapis server;"]
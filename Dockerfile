FROM --platform=linux/amd64 ubuntu:latest 
WORKDIR /dar_one_docker
COPY . . 

RUN apt-get update -y
RUN apt-get install wget -y
RUN apt-get install vim -y

# download, install, and link julia 
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.2-linux-x86_64.tar.gz
RUN tar zxvf julia-1.8.2-linux-x86_64.tar.gz
ENV PATH="${PATH}:/dar_one_docker/julia-1.8.2/bin"
# Use the DAR1 package environment from anywhere in the container.
ENV JULIA_PROJECT=/dar_one_docker/Dar_One
RUN julia --project=/dar_one_docker/Dar_One -e 'using Pkg; Pkg.instantiate()'

# other dependencies 
RUN apt-get install -y gfortran make 
RUN apt-get install -y python-is-python3
# future: try netcdf-bin instead? does it still work? 
RUN apt-get install -y libnetcdff-dev 

# copy docker-built exec file to correct location
# TODO: better way to do this?
RUN cp /dar_one_docker/Dar_One/mitgcmuv /dar_one_docker/darwin3/verification/dar_one_config/build/mitgcmuv

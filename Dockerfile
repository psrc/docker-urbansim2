# PSRC UrbanSim2 Docker
FROM continuumio/miniconda

# Set the internal container working directory
ENV wd /udst

WORKDIR ${wd}

# Install required anaconda python packages    
RUN conda install \
    numpy \
    pandas \
    pytables \
    scipy \
    statsmodels \
    toolz

# Install required pip packages -- these are not in anaconda at all   
RUN pip install prettytable zbox 

# Grab UDST urbansim packages
RUN git clone https://github.com/UDST/urbansim.git
RUN git clone https://github.com/UDST/urbansim_defaults.git
RUN git clone https://github.com/UDST/orca.git
RUN git clone https://github.com/UDST/pandana.git
    
# Grab PSRC urbansim2 
RUN git clone https://github.com/psrc/urbansim2.git psrc_urbansim    

# Set some env variables
ENV DATA_HOME=${wd}/psrc_urbansim
ENV PYTHONPATH=${wd}/psrc_urbansim:${wd}/urbansim:${wd}/urbansim_defaults:${wd}/orca:${wd}/pandana

# Copy base year HDF5 file
COPY psrc_base_year_2014.h5 ${wd}/psrc_urbansim/data

#TODO Copy settings.yaml -- (be sure datafile name is in node 'store')

#TODO Hana's magic changes
RUN git config --global user.email "docker@psrc.org" && git config --global user.name "Docker"

WORKDIR ${wd}/urbansim_defaults
RUN git remote add psrcedits https://github.com/hanase/urbansim_defaults.git
RUN git pull psrcedits dev

WORKDIR ${wd}/urbansim
RUN git remote add psrcedits https://github.com/hanase/urbansim.git
RUN git pull psrcedits dev

# I like colored directory listings
RUN echo "alias ls='ls --color'" > /root/.bashrc

# RUN THIS: default command!
WORKDIR ${wd}/psrc_urbansim
CMD python simulate.py

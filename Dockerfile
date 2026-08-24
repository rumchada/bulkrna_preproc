#I have a conda env with all of the pre-loaded dependendcies
FROM continuumio/miniconda3

# I assume this is where the work is being done
WORKDIR /work

#Grab the working yaml
COPY ./envs/bulkrna_pipeline_copy.yaml /tmp/bulkrna_pipeline_copy.yaml

#create the conda env
RUN conda config --system --set channel_priority strict
RUN conda env create -n bulkrna_env -f /tmp/bulkrna_pipeline_copy.yaml


# set to the current system's path
ENV PATH=/opt/conda/envs/bulkrna_env/bin:$PATH

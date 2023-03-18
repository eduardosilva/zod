# Dockerfile for a Python-based audio metadata extraction tool

# Use the Python 3.10.10-bullseye base image
FROM python:3.10.10-bullseye

# Install necessary system dependencies
RUN apt update \
    && apt install software-properties-common ffmpeg -y

# Set the working directory for the container
WORKDIR /app

# Copy the requirements file to the working directory and install the dependencies
COPY requirements.txt ./
RUN pip install Cython numpy 
RUN git clone --recursive https://github.com/CPJKU/madmom.git \
    && cd madmom \
    && git submodule update --init --remote \
    && python setup.py develop --user \
    && cd ../;

RUN pip install --no-cache-dir -r requirements.txt

# Copy the metadata script to the working directory
COPY metadata.py ./

VOLUME ["/song_folder"]
WORKDIR /song_folder

# Set the entry point to the metadata script
ENTRYPOINT ["python", "/app/metadata.py", "-f"]

# Default file
CMD ["file.mp3"]

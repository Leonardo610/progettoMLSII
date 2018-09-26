# Use an official Python runtime as a parent image
FROM maven:3-jdk-7

# Copy the current directory contents into the container at /app
ADD . /progettoml

# Install any needed packages specified in requirements.txt and the software

RUN apt-get update \
&& apt-get install -y git gcc g++ make libgfortran3 python python-dev tree \
&& apt-get clean \
&& curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" \
&& python get-pip.py

RUN pip install --trusted-host pypi.python.org -r /progettoml/requirements.txt
#RUN cat /progettoml/requirements.txt | xargs -n 1 pip install



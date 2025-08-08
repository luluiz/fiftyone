# Copyright 2017-2025, Voxel51, Inc.
# Modifications Copyright 2025, luluiz
# voxel51.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG PYTHON_VERSION=3.11
ARG FO_VERSION=1.7.2

FROM python:${PYTHON_VERSION}-slim

# Environment variables for FiftyOne backend
ENV PYTHONUNBUFFERED=1
ENV FIFTYONE_DATABASE_URI=mongodb://fiftyone_user:fiftyone_password@mongodb:27017/fiftyone
ENV FIFTYONE_DEFAULT_APP_ADDRESS=0.0.0.0
ENV FIFTYONE_DEFAULT_APP_PORT=5151
ENV FIFTYONE_SERVER_ADDRESS=0.0.0.0
ENV FIFTYONE_SERVER_PORT=5151
ENV FIFTYONE_DISABLE_SERVICES=true

WORKDIR /app

# Install system dependencies
RUN apt-get -qq update && apt-get -qq install -y \
    ffmpeg \
    libcurl4 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
ARG FO_VERSION
RUN pip --no-cache-dir install -q -U pip setuptools wheel && \
    pip --no-cache-dir install \
    fiftyone==${FO_VERSION} \
    pymongo>=4.0.0 \
    motor>=3.0.0

# Copy backend configuration and scripts
COPY requirements.txt .
COPY entrypoint.sh /entrypoint.sh
COPY health-check.py /health-check.py

RUN chmod +x /entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python /health-check.py || exit 1

# Expose backend port
EXPOSE 5151

ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "-m", "fiftyone.server.main", "--port", "5151"]

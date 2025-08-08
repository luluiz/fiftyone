#!/usr/bin/env python
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

"""Health check script for FiftyOne backend."""

import sys
import urllib.request
import urllib.error


def check_health():
    """Check if the FiftyOne backend is healthy."""
    try:
        # Try to connect to the health endpoint
        response = urllib.request.urlopen(
            "http://localhost:5151/health", timeout=5
        )
        if response.getcode() == 200:
            print("Backend is healthy")
            return True
    except urllib.error.URLError:
        pass
    except Exception as e:
        print(f"Health check failed: {e}")

    # Fallback: try to import fiftyone and check basic functionality
    try:
        import fiftyone as fo

        # Basic connectivity test
        datasets = fo.list_datasets()
        print("FiftyOne backend is responding")
        return True
    except Exception as e:
        print(f"FiftyOne health check failed: {e}")
        return False


if __name__ == "__main__":
    if check_health():
        sys.exit(0)
    else:
        sys.exit(1)

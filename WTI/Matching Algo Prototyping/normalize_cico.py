import pandas as pd
import numpy as np
import datetime
import time

# sort by plateno and timestamp and geofence
data = data.sort_values(by=["plateno", "datestamp_entry", "geofence_name"])

# check if matching with previous and next locations
data["prev_match"] = data["geofence_name"].eq(data["geofence_name"].shift(1))
data["next_match"] = data["geofence_name"].eq(data["geofence_name"].shift(-1))
data["continuing"] = np.where((data["prev_match"]) & (data["next_match"]), 1, 0)

## select only not continuing
data = data.loc[
    :,
    [
        "plateno",
        "geofence_name",
        "datestamp_entry",
        "datestamp_left",
        "dwell_time",
        "dwell_time_hms",
        "continuing",
    ],
]
data = data.loc[data["continuing"] == 0]

# check if geofence has the same next geofence
data["has_same_next"] = np.where(
    data["geofence_name"].eq(data["geofence_name"].shift(-1)), 1, 0
)

# adjust timestamp
data["new_datestamp_left"] = np.where(
    data["has_same_next"] == 1, data["datestamp_left"].shift(-1), data["datestamp_left"]
)

# remove adjusted timestamp
data["to_remove"] = data["has_same_next"].shift(1) == 1
data = data.loc[
    data["to_remove"] == False,
    [
        "plateno",
        "geofence_name",
        "datestamp_entry",
        "new_datestamp_left",
        "dwell_time",
        "dwell_time_hms",
    ],
]

data.rename(columns={"new_datestamp_left": "datestamp_left"}, inplace=True)

data["dwell_time"] = (
    data["datestamp_left"] - data["datestamp_entry"]
).dt.total_seconds()
data["dwell_time_hms"] = pd.to_datetime(data["dwell_time"], unit="s").dt.strftime(
    "%H:%M:%S"
)
data.reset_index(drop=True, inplace=True)

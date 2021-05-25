import pandas as pd
import numpy as np
import datetime
import time
import geopandas as gpd


# read data
data = pd.read_csv("cico.csv")


# convert to datestamp
data["datestamp_entry"] = pd.to_datetime(data["datestamp_entry"])
data["datestamp_left"] = pd.to_datetime(data["datestamp_left"])

# sort by plateno and datestamp entry
data = data.sort_values(by=["plateno", "datestamp_entry", "geofence_name"])


# check if continuing
data["prev_match"] = data["geofence_name"].eq(data["geofence_name"].shift(1))
data["next_match"] = data["geofence_name"].eq(data["geofence_name"].shift(-1))
data["continuing"] = np.where((data["prev_match"]) & (data["next_match"]), 1, 0)


# select relevant columns and those that are not continuing
data = data.loc[
    data["continuing"] == 0,
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


# check if same next
data["has_same_next"] = np.where(
    data["geofence_name"].eq(data["geofence_name"].shift(-1)), 1, 0
)

# adjust datestamp left
data["new_datestamp_left"] = np.where(
    data["has_same_next"] == 1, data["datestamp_left"].shift(-1), data["datestamp_left"]
)


# remove those with same next
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

# rename columns
data.rename(columns={"new_datestamp_left": "datestamp_left"}, inplace=True)

# compute for new datestamp
data["dwell_time"] = (
    data["datestamp_left"] - data["datestamp_entry"]
).dt.total_seconds()
data["dwell_time_hms"] = pd.to_datetime(data["dwell_time"], unit="s").dt.strftime(
    "%H:%M:%S"
)

# reset index
data.reset_index(drop=True, inplace=True)


data.to_csv("normalized_cico.csv", index=False)

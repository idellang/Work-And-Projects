import pandas as pd
import numpy as np
import datetime
import time

data = pd.read_csv("points_inside_geofences.csv")

# make sure datestamp column is datetime object
data["datestamp"] = pd.to_datetime(data["datestamp"])

# create tracking period of 30 mins
data["track_period"] = data["datestamp"].dt.floor("30T")

# groupby and get timestart, end, count, duration
data["time_start"] = data.groupby(
    ["plateno", "geofence_name", "track_period"]
).transform("min")

data["time_end"] = data.groupby(["plateno", "geofence_name", "track_period"]).transform(
    "max"
)["datestamp"]

data["count"] = data.groupby(["plateno", "geofence_name", "track_period"]).transform(
    "count"
)["datestamp"]

data["duration"] = (data["time_end"] - data["time_start"]).dt.total_seconds()


# filter those that are less than 5 points and 5 mins
# data = data.loc[(data["count"] > 5) & (data["duration"] > 300), :]

# sort values by plateno, geofence name and track period
data = data.sort_values(by=["plateno", "geofence_name", "track_period"])
data = data.loc[
    :,
    [
        "plateno",
        "geofence_name",
        "track_period",
        "time_start",
        "time_end",
        "duration",
        "count",
    ],
]

# remove duplicates and sort values
data.drop_duplicates(inplace=True)
data = data.sort_values(by=["plateno", "track_period"])
data = data.sort_values(by=["plateno", "geofence_name"])

# get time end at prev loc and time at next loc
data["time_end_prev_loc"] = data.groupby(["plateno", "geofence_name"])[
    "time_end"
].shift(1)
data["time_start_next_loc"] = data.groupby(["plateno", "geofence_name"])[
    "time_start"
].shift(-1)

# get time diff from prev location and next location
data["time_diff_next_loc"] = (
    data["time_start_next_loc"] - data["time_end"]
).dt.total_seconds()
data["time_diff_prev_loc"] = (
    data["time_start"] - data["time_end_prev_loc"]
).dt.total_seconds()

# check if continuing
# continuing is time from prev location and next location is less than 5 mins or 300 secs
data["continue_next_loc"] = data["time_diff_next_loc"] < 300
data["continue_prev_loc"] = data["time_diff_prev_loc"] < 300
data["continuing"] = data["continue_prev_loc"] & data["continue_next_loc"]

# filter not continuing CICO
data = data.loc[(data["continuing"] == False), :]


# create column lead time diff prev loc which is the time difference from previous location
data["lead_time_diff_prev_loc"] = data.groupby(["plateno", "geofence_name"])[
    "time_diff_prev_loc"
].shift(-1)

# create new column lead time end which is the time end of next CICO
data["lead_time_end"] = data.groupby(["plateno", "geofence_name"])["time_end"].shift(-1)


# comppute for actual time end using these conditions

# time end from previous location is null. These are the first locations visited by vehicles
c1 = data["time_end_prev_loc"].isnull()

# difference from previous location and next loocation
c2 = data["lead_time_diff_prev_loc"] < 300
c3 = data["time_diff_next_loc"] <= 300

condition = (c1 | c2) & c3

# adjust for actual time end.
data["actual_time_end"] = np.where(condition, data["lead_time_end"], data["time_end"])

# for those with missign actual time end, use the time end column
data["actual_time_end"] = np.where(
    data["time_diff_next_loc"].isnull(), data["time_end"], data["actual_time_end"]
)

# filter those with actual time and select relevant columns
data = data.loc[data["actual_time_end"].notnull(), :]
data = data.loc[:, ["plateno", "geofence_name", "time_start", "actual_time_end"]]


# compute for dwell time
data["duration"] = (data["actual_time_end"] - data["time_start"]).dt.total_seconds()

# remove those CICO that were used to adjust time end
data["ranking"] = data.groupby(["plateno", "geofence_name", "actual_time_end"])[
    "duration"
].rank(ascending=False)
data = data.loc[data["ranking"] != 2, :]

# select needed columns
data = data.loc[
    :, ["plateno", "geofence_name", "time_start", "actual_time_end", "duration"]
]

# rename columns
data = data.rename(
    columns={
        "time_start": "datestamp_entry",
        "actual_time_end": "datestamp_left",
        "duration": "dwell_time",
    }
).reset_index(drop=True)

# sory by datestamp
data = data.sort_values(by="datestamp_entry").reset_index(drop=True)

# add dwell time on HMS
data["dwell_time_hms"] = pd.to_datetime(data["dwell_time"], unit="s").dt.strftime(
    "%H:%M:%S"
)

data = data.reset_index().rename(columns={"index": "cico_id"})


print(data)
data.to_csv("cico.csv", index=False)

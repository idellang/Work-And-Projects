import pandas as pd
import numpy as np
import datetime
import time


# read data
data = pd.read_csv("kodigo_points.csv")

# convert to datestamp
data["datestamp"] = pd.to_datetime(data["datestamp"])

## create track period column
data["track_period"] = data["datestamp"].dt.floor("30T")

# compute timestart, time_end, num_points, and duration per group
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


## filter those that are below 5 mins and below 5 points
data = data.loc[(data["count"] > 5) & (data["duration"] > 300), :]
data = data.sort_values(by=["plateno", "geofence_name", "track_period"])

# select necessary columns
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

# get distinct values
data.drop_duplicates(inplace=True)

## arrange by geofence and track period
data = data.sort_values(by=["plateno", "track_period"])
data = data.sort_values(by=["plateno", "geofence_name"])

# get timestart to next loc and time end at prev loc
data["time_end_prev_loc"] = data.groupby(["plateno", "geofence_name"])[
    "time_end"
].shift(1)
data["time_start_next_loc"] = data.groupby(["plateno", "geofence_name"])[
    "time_start"
].shift(-1)

# get difference from prev loc
data["time_diff_next_loc"] = (
    data["time_start_next_loc"] - data["time_end"]
).dt.total_seconds()
data["time_diff_prev_loc"] = (
    data["time_start"] - data["time_end_prev_loc"]
).dt.total_seconds()


## create boolean to check if the geofence is just continuing
data["continue_next_loc"] = data["time_diff_next_loc"] < 300
data["continue_prev_loc"] = data["time_diff_prev_loc"] < 300
data["continuing"] = data["continue_prev_loc"] & data["continue_next_loc"]

# filter those that are not continuing
data = data.loc[(data["continuing"] == False), :]

## create new columns to adjust time end if continuing
data["lead_time_diff_prev_loc"] = data.groupby(["plateno", "geofence_name"])[
    "time_diff_prev_loc"
].shift(-1)
data["lead_time_end"] = data.groupby(["plateno", "geofence_name"])["time_end"].shift(-1)


## get actual time end
c1 = data["time_end_prev_loc"].isnull()
c2 = data["lead_time_diff_prev_loc"] < 300
c3 = data["time_diff_next_loc"] <= 300

condition = (c1 | c2) & c3

data["actual_time_end"] = np.where(condition, data["lead_time_end"], data["time_end"])

## adjust for last geofences visited by vehicle
data["actual_time_end"] = np.where(
    data["time_diff_next_loc"].isnull(), data["time_end"], data["actual_time_end"]
)

## select relevant columns and rows
data = data.loc[data["actual_time_end"].notnull(), :]
data = data.loc[:, ["plateno", "geofence_name", "time_start", "actual_time_end"]]

## calculate new duration
data["duration"] = (data["actual_time_end"] - data["time_start"]).dt.total_seconds()

## remove rows that were not adjusted
data["ranking"] = data.groupby(["plateno", "geofence_name", "actual_time_end"])[
    "duration"
].rank(ascending=False)

data = data.loc[data["ranking"] != 2, :]

## select final columns
data = data.loc[
    :, ["plateno", "geofence_name", "time_start", "actual_time_end", "duration"]
]

data = data.rename(
    columns={
        "time_start": "datestamp_entry",
        "actual_time_end": "datestamp_left",
        "duration": "dwell_time",
    }
).reset_index(drop=True)

## sort by start date
data = data.sort_values(by="datestamp_entry").reset_index(drop=True)

# get dwell time in hour minute second format
data["dwell_time_hms"] = pd.to_datetime(data["dwell_time"], unit="s").dt.strftime(
    "%H:%M:%S"
)


print(data)
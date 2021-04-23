import pandas as pd
import ast
import numpy as np


def extract_data(csv_file):
    data = pd.read_csv(csv_file)
    cols_needed = ["trip_number", "so_number", "vehicle_plate_no"]
    dropoffs = data["dropoffs"]
    pickups = data["pickups"]

    data = data[data.columns.intersection(cols_needed)]

    dropoff_name = []
    dropoff_arrival = []
    pickup_name = []
    pickup_arrival = []

    for dropoff in dropoffs:
        dropoff_dict = ast.literal_eval(dropoff)
        for value in dropoff_dict:
            dropoff_name.append(value.get("name", "No name"))
            dropoff_arrival.append(value.get("arrival", "No arrival"))

    for pickup in pickups:
        pickup_dict = ast.literal_eval(pickup)
        for value in pickup_dict:
            pickup_name.append(value.get("name", "No name"))
            pickup_arrival.append(value.get("arrival", "No arrival"))

    data["dropoff_name"] = np.array(dropoff_name)
    data["dropoff_arrival"] = pd.to_datetime(np.array(dropoff_arrival))
    data["pickup_name"] = np.array(pickup_name)
    data["pickup_arrival"] = pd.to_datetime(np.array(pickup_arrival))

    data["dropoff_arrival"] += pd.DateOffset(hours=8)
    data["pickup_arrival"] += pd.DateOffset(hours=8)
    return data


trans = extract_data("Transpecial-FO-Jan2021.csv")
trans.to_csv("Transpecial-FO-Jan2021-extracted.csv")

ehd = extract_data("EHD_Logistics-FO-Jan2021.csv")
ehd.to_csv("EHD_Logistics-FO-Jan2021-extracted.csv")

pan = extract_data("Pan_Logistics-FO-Jan2021.csv")
pan.to_csv("Pan_Logistics-FO-Jan2021-extracted.csv")

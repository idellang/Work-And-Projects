"""
Get DC of each geofence. 
"""
import pandas as pd
import numpy as np


## load data

geofences = pd.read_csv("Geofence Library/TMSUITE-Geofences-asof-0517-Formatted.csv")
dcs = pd.read_csv("Geofence Library/Nestle-P-Geofences.csv")

## select column names for geofences

geofences = geofences.loc[:, ["name", "group_names", "geofence_code"]]

## create new column for group names


def extract_group(row):
    """Create mapping for fixed group names"""
    if "Nestle" in row["group_names"]:
        return "Nestle"
    elif "DHL" in row["group_names"]:
        return "DHL"
    elif "HAVI" in row["group_names"]:
        return "HAVI"
    else:
        return np.nan


geofences["group_names_new"] = geofences.apply(extract_group, axis=1)

# combine two dataframes
geofences_with_dcs = pd.merge(
    geofences, dcs, how="left", left_on="name", right_on="Dropoffs"
)


# drop duplicates
geofences_with_dcs.drop_duplicates(inplace=True)

# create new columns dcs and num dcs
nunique_pickups = geofences_with_dcs.groupby("name")["Pickups"].nunique()
pickups = geofences_with_dcs.groupby("name")["Pickups"].apply(list)
nunique_pickups.name = "num_dc"
pickups.name = "DC"

# join dataframes
geofences_with_dcs = (
    geofences_with_dcs.loc[
        :, ["name", "group_names", "geofence_code", "group_names_new"]
    ]
    .drop_duplicates()
    .set_index("name")
    .join(nunique_pickups)
    .join(pickups)
)

# replace nan with None
geofences_with_dcs["DC"] = (
    geofences_with_dcs["DC"]
    .apply(str)
    .str.replace("nan", "None")
    .str.replace("\[|\]|'", "")
)

geofences.to_csv("geofences_with_dc.csv")

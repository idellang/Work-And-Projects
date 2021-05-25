import geopandas as gpd
import pandas as pd
import numpy as np

# load geofence
zipfile = "TMSUITE-Geofences-asof-0429 SHP.zip"
geofences = gpd.read_file(zipfile)


## load gps points and convert to geopandas dataframe
gps_points = pd.read_csv("Nestle_March_Kodigo_GPS-Formatted-v2.csv")
gps_points = gpd.GeoDataFrame(
    gps_points,
    geometry=gpd.points_from_xy(gps_points["longitude"], gps_points["latitude"]),
)

## add crs to gps_points data
gps_points.set_crs(epsg=4326, inplace=True)

### Spatial join
points_inside_geofence = gpd.sjoin(gps_points, geofences, how="inner", op="within")

# select columns and rename
points_inside_geofence = points_inside_geofence.loc[
    :, ["plateno", "name", "created_left"]
]
points_inside_geofence = points_inside_geofence.rename(
    columns={"name": "geofence_name", "created_left": "datestamp"}
)

# convert to datetime
data = points_inside_geofence.sort_values(by="datestamp")

data.to_csv("points_inside_geofences.csv", index=False)

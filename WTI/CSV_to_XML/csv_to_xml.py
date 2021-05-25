import pandas as pd
import numpy as np
import os


# read data
df = pd.read_csv("DSSI-Fix-to-xml.csv")

## function to create xml
def convert_row2(row):
    """substitute dataframe details into the xml text string"""

    return f"""<status xmlns="http://www.kewill.com/logistics/klic/status" type="tag">
    <ediCustomerNumber>{row['customer_number']}</ediCustomerNumber>
    <ediParam1>4</ediParam1>
    <ediParam2>s</ediParam2>
    <ediParam3>s</ediParam3>
    <ediReference>Webcast</ediReference>
    <internalNumber>{row['so_number']}</internalNumber>
    <ediFunction1>2</ediFunction1>
    <ediCustomerSearchName>STANDAARD</ediCustomerSearchName>
    <fileHeader type = "tag">
        <trackingAndTracing type = "tag">
            <dateTimeZone>{row['datestamp']}</dateTimeZone>
            <code>{row['code']}</code>
            <remark_1>LAT:{row['latitude']},LONG:{row['longitude']}</remark_1>
            <remark_2>{row['alert_message']}, {row['location']}</remark_2>
        </trackingAndTracing>
    </fileHeader>
</status>
    """


# store xml output per row
df["xml"] = df.apply(convert_row2, axis=1)

##convert datestamp to text
df.datestamp = pd.to_datetime(df.datestamp)
df["datestamp"] = df["datestamp"].dt.strftime("%Y%m%d%H%M%S")

## create function to save xml files
def save_xml(row):
    with open(
        f"xml_folder/{row['so_number']}_webcast_{row['code_name']}_{row['datestamp']}.xml",
        "w",
    ) as f:
        f.write(row["xml"])


# create folder
if not os.path.exists("xml_folder"):
    os.makedirs("xml_folder")

# apply save xml
df.apply(save_xml, axis=1)

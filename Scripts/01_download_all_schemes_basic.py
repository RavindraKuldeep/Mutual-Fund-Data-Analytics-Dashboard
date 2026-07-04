import requests
import pandas as pd
import time


# MFAPI ka URL
url = "https://api.mfapi.in/mf"

# Saari schemes is list me store hongi
all_schemes = []

# Ek baar me 500 schemes lenge
limit = 500

# Download starting point
offset = 0


print("Scheme list download ho rahi hai...")


while True:

    # MFAPI se data lena
    response = requests.get(
        url,
        params={
            "limit": limit,
            "offset": offset
        }
    )

    # JSON data ko Python list me convert karna
    data = response.json()

    # Agar data khatam ho gaya to loop band
    if len(data) == 0:
        break

    # Downloaded schemes ko main list me add karna
    all_schemes.extend(data)

    print("Downloaded schemes:", len(all_schemes))

    # Agar 500 se kam records mile to last page hai
    if len(data) < limit:
        break

    # Agle 500 records ke liye
    offset = offset + limit

    # Har request ke baad thoda wait
    time.sleep(0.2)


# List ko table me convert karna
df = pd.DataFrame(all_schemes)


# Columns ke naam simple banana
df = df.rename(
    columns={
        "schemeCode": "Scheme_Code",
        "schemeName": "Scheme_Name"
    }
)


# Duplicate scheme codes remove karna
df = df.drop_duplicates(
    subset=["Scheme_Code"]
)


# Scheme Code ke according sorting
df = df.sort_values(
    by="Scheme_Code"
)


# CSV file save karna
df.to_csv(
    "Raw_Data/MFAPI_All_Schemes.csv",
    index=False
)


print("\nDownload complete.")
print("Total schemes:", len(df))
print("CSV file Raw_Data folder me save ho gayi.")
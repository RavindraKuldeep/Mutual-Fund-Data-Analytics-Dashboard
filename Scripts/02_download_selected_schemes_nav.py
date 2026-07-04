import os
import time
import pandas as pd
import requests

# 1. File aur folders
excel_file = "Mutual_Fund_Master.xlsx"
raw_folder = "Raw_Data"
processed_folder = "Processed_Data"

os.makedirs(raw_folder, exist_ok=True)
os.makedirs(processed_folder, exist_ok=True)

# 2. Selected schemes Excel se read karo
schemes = pd.read_excel(excel_file, sheet_name="Selected_Schemes")

# Sirf Selected = Yes wali schemes
schemes = schemes[
    schemes["Selected"].astype(str).str.strip().str.lower() == "yes"
]
print("Total selected schemes:", len(schemes))

all_nav = []
summary = []

# 3. Har scheme ka NAV download karo
for index, row in schemes.iterrows():
    code = str(row["Scheme_Code"]).replace(".0", "").strip()
    name = row["Scheme_Name"]
    category = row["Category"]

    print("Downloading:", code, "-", name)

    try:
        url = "https://api.mfapi.in/mf/" + code
        response = requests.get(url, timeout=60)
        data = response.json()["data"]

        nav_df = pd.DataFrame(data)
        nav_df["Date"] = pd.to_datetime(
            nav_df["date"],
            format="%d-%m-%Y"
        )
        nav_df["NAV"] = pd.to_numeric(nav_df["nav"])

        nav_df["Scheme_Code"] = code
        nav_df["Scheme_Name"] = name
        nav_df["Category"] = category

        all_nav.append(
            nav_df[
                ["Category", "Scheme_Code", "Scheme_Name", "Date", "NAV"]
            ]
        )

        start_date = nav_df["Date"].min()
        end_date = nav_df["Date"].max()
        required_date = end_date - pd.DateOffset(years=5)

        if start_date <= required_date:
            eligible = "Yes"
            remark = "Complete 5-year NAV history available"
        else:
            eligible = "No"
            remark = "Complete 5-year NAV history not available"

        summary.append({
            "Category": category,
            "Scheme_Code": code,
            "Scheme_Name": name,
            "NAV_Start_Date": start_date,
            "NAV_End_Date": end_date,
            "Five_Year_Eligible": eligible,
            "Eligibility_Remark": remark
        })

    except Exception as error:
        summary.append({
            "Category": category,
            "Scheme_Code": code,
            "Scheme_Name": name,
            "NAV_Start_Date": "",
            "NAV_End_Date": "",
            "Five_Year_Eligible": "No",
            "Eligibility_Remark": str(error)
        })

    time.sleep(1)

# 4. Output CSV files save karo
if all_nav:
    final_nav = pd.concat(all_nav, ignore_index=True)
    final_nav.to_csv(
        raw_folder + "/Selected_Schemes_NAV_History.csv",
        index=False
    )

summary_df = pd.DataFrame(summary)
summary_df.to_csv(
    processed_folder + "/Scheme_Eligibility_Check.csv",
    index=False
)

print("\nKaam complete ho gaya.")
print("NAV file Raw_Data folder me bani hai.")
print("Eligibility file Processed_Data folder me bani hai.")
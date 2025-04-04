#  YouTube Channel Analytics with YouTube API, Python, PostgreSQL & Power BI

This project is designed to extract and analyze YouTube video statistics using the YouTube Data API. It helps track **growth metrics** such as likes, views, and comments over time for selected channels. The processed data is stored in a **PostgreSQL** database and visualized using **Power BI** for insights and reporting.

---

## Technologies Used

- **Python**: For data extraction and processing  
- **YouTube Data API v3**: To collect channel and video statistics  
- **PostgreSQL**: For storing historical data and enabling time-based growth tracking  
- **Power BI**: For interactive dashboards and visualizations  
- **pandas**: For data wrangling  

---

## Features

- Fetch video statistics (views, likes, comments) for specific YouTube channels
- Store historical video data for trend analysis
- Calculate growth rates for:
  - Views
  - Likes
  - Comments
- Clean and structure data using Python & pandas
- Visualize trends, top-performing videos, and channel growth in Power BI

---

## Project Structure
 - Python source code - youtube.py
 - required modules - requirements.txt
 - SQL File - EDAYotubeChannels
 - Scraped data files - csv files 
 - PowerBI Dashboards - pbix file	



## Import the cleaned data tables from your PostgreSQL database

Use calculated columns or measures to create:

Monthly growth charts

Channel performance comparisons

Bar charts for top 5 mostly viewed, liked, commented videos.


###  Growth Rate Formula

Growth Rate = (Metric_today - Metric_yesterday) / Metric_yesterday * 100

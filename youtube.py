#Imported the necessary modules. 
from googleapiclient.discovery import build
import pandas as pd 

#To set up Pandas to display max rows 
pd.set_option('display.max.rows', 2000)

api_key = 'AIzaSyCKO-rjjmtguaS7_mp0f0-z_SJNa62D8Jo'

#The Channels ID's I want to Scrape.
channel_ids = [
                'UCO5QSoES5yn2Dw7YixDYT5Q',
                'UCaG7EroyixUjRKZF-FnVq4Q',
                'UCzd0MT-KhUK1OMk7Ac9DBBQ',
                'UCAqdOqqhVM6PF9Kc_YjFdUg',
                'UC-6IQO6g1NuJiaS3uTId3oQ',
                'UCMPQUxRnbGwODoclug5QZiA',
                'UCOpwnST30vJmriyEe1i1z-g', 
                'UC51pzLZON3TDUDHTt_UVLGA',
                'UCfCAy6CkaliVqbwqKT2VSYw',
                'UCgkD3J4uFcWJ0S0clSX9BFA'
]


#Create the Youtube API
youtube = build('youtube', 'v3', developerKey=api_key)

#This Function gets Channel Statistics 
def get_channel_stats(youtube, channel_ids):
    request = youtube.channels().list(
        part= "snippet, contentDetails, statistics",                               #The info I want to get about the channels
        id= ','.join(channel_ids), 
        maxResults = 10                                                            #Return only 10 items cause, I'm making the call for 10 Channels 
    )
    response = request.execute()                                                   #Making the Request 

    all_channels = [ ]                                                             #This stores Statistics for all Channel (List of Dictionaries)                               
    for i in range(len(response['items'])):
        data = dict(Channel_id = response['items'][i]['id'],
                    Channel_name = response['items'][i]['snippet']['title'], 
                    Subscribers = response['items'][i]['statistics']['subscriberCount'], 
                    Views = response['items'][i]['statistics']['viewCount'], 
                    Total_videos = response['items'][i]['statistics']['videoCount'],
                    Playlist_id = response['items'][i]['contentDetails']['relatedPlaylists']['uploads']
                )
        all_channels.append(data)                                                  #append each Channel Dict to the list. 
    return all_channels                                                            #Return the list


#Channel_statistics holds All Channel Statistics returned from the function.
channel_statistics = get_channel_stats(youtube,channel_ids)  


#Put into a dataFrame and then Convert it into CSV File.
df = pd.DataFrame(channel_statistics)
df.to_csv(r'C:\Users\user\Desktop\youtubeAPI/Channel_stats.csv')



#converting the Data types of the columns 'Subscribers, Views, Total_videos' to Numeric
df['Subscribers'] = pd.to_numeric(df['Subscribers'])
df['Views'] = pd.to_numeric(df['Views'])
df['Total_videos'] = pd.to_numeric(df['Total_videos'])


print(df)

#Function below is for getting statistics about each video in the playlist of each Channel.

def get_video_details(youtube, playlist_ids):
    channel_videos_stats = []
    playlist_ids = list(playlist_ids)                                               #passing list of playlist ids 

    for playlist_id in playlist_ids:                                                #Looping through each Play list 
        next_page_token = None                                                      #This Parameter shows that still we have some pages to be scraped beacuse This is the first call its value is None 
                                                                      
        video_ids = [ ]                                                             #This stores all video ID of a particular channel

        while True:
            request = youtube.playlistItems().list(                                 #Creating Playlist Request with the required Parameters 
                part = "contentDetails", 
                playlistId = playlist_id,
                maxResults = 50,                                                    #Max Response I could get one at a time is 50 videos that's why i used pageToken parameters to make the request for all the videos through a Loop.
                pageToken = next_page_token
                )

            response = request.execute()                                            #Execute the Request and get the Response which is in Dictionary Format.

            for i in range(len(response['items'])):                                 #The Length of Item's returned is 50 at a time so looping through to get their ID
                video_id = response['items'][i]['contentDetails']['videoId']
                video_ids.append(video_id)
        
            next_page_token = response.get('nextPageToken')
            if not next_page_token:
                break
        
        all_videos_stats = []                                                         #This list stores all the statiscs of a particular channel.

        for i in range(0, len(video_ids), 50):                                        #Making a API call only on 50 Video IDs at a time that's why Looping though 50 at a time. 
            request = youtube.videos().list(
                part = "snippet, statistics", 
                id = ','.join(video_ids[i:i+50])
                )

            response = request.execute()
            for video in response['items']:                                            #Item is a list contains statistics for 50 videos 
                video_stats = dict(   
                            Channel_id = video['snippet']['channelId'],                 #Creating a Dictionary for dataFrame cause, I will create a separate table for the statistics 
                            Title= video['snippet']['title'], 
                            Publish_date= video['snippet']['publishedAt'],
                            Views = video['statistics']['viewCount'],
                            Likes= video['statistics'].get('likeCount', 0),             #Using get() to eliminate any errors.
                            Comments =video['statistics'].get('commentCount', 0)
                                    )
                all_videos_stats.append(video_stats)

        channel_videos_stats.append(all_videos_stats)                                   #This list contains the list of videos statistics for each channels 

    return channel_videos_stats                                                         #Returns a nested list of Channel's Videos Statistics.


video_details = get_video_details(youtube, df['Playlist_id'])                          #Call the Function and send Playlist_id Column value of the DataFrame(df)

flat_list = [item for sublist in video_details for item in sublist]                    #Flatten nested list into one so I could create a DataFrame for the videos Statistics
video_Details = pd.DataFrame(flat_list)


print(video_Details)                                                                    #Print Data Frame for the Videos Statistics.

#Change the Data types of these Columns: Publish_date, Views, Likes
video_Details['Publish_date'] = pd.to_datetime(video_Details['Publish_date']).dt.date       
video_Details['Views'] = pd.to_numeric(video_Details['Views'])
video_Details['Likes'] = pd.to_numeric(video_Details['Likes'])

#Add additional 'Month' Column as formatted month Date
video_Details['Month'] = pd.to_datetime(video_Details['Publish_date']).dt.strftime('%b')

print(video_Details)
print(video_Details.dtypes)

#Save your DataFrame into a CSV File.
video_Details.to_csv(r'C:\Users\user\Desktop\youtubeAPI/VideoStatistics.csv')





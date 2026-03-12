public class NotificationContent {
    public String notificationTitle;
    public String notificationBody;
    public ConnectApi.FeedItemInput chatterPostBody;
    public Boolean postToChatterEnabled;
    public Boolean pushNotificationEnabled;
    
    public NotificationContent() {
        this.notificationTitle = '';
        this.notificationBody = '';
        this.chatterPostBody = null;
        this.postToChatterEnabled = false;
        this.pushNotificationEnabled = false;
    }
}
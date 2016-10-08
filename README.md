# backgroundSender
Test OBJ-C App to send stuff in the background

This app is very simple; it provides the user with two options, to SEND or to SCHEDULE.

SEND will send a https request to https://jsonplaceholder.typicode.com/posts/1

SCHEDULE will schedule a local notification to be fired in 5 seconds. You should put the app in the background after hitting the button. When you get the local notification, you will have the option to "Send HTTP Request". This will try to send a request to https://jsonplaceholder.typicode.com/posts/1, but I have never gotten the request to return, ever.

Good luck!

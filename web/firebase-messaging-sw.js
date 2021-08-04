importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyC3zPvm0t7NxRQnOjm3qVlQGoXCUQhGWt0",
    authDomain: "lune-vpn-e6d12.firebaseapp.com",
    projectId: "lune-vpn-e6d12",
    storageBucket: "lune-vpn-e6d12.appspot.com",
    messagingSenderId: "728682371792",
    appId: "1:728682371792:web:f7a60c50a66fb534ef5cd5",
    measurementId: "G-4MYE8PK8CH",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});
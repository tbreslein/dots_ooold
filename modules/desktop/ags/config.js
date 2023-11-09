// example content of ~/.config/ags/config.js
import Widget from "resource:///com/github/Aylur/ags/widget.js";
import App from "resource:///com/github/Aylur/ags/app.js";

const exampleWindow = Widget.Window({
  name: "example-window",
  child: Widget.Label({
    label: "example-content",
  }),
});

export default {
  closeWindowDelay: {
    "window-name": 500, // milliseconds
  },
  notificationPopupTimeout: 5000, // milliseconds
  cacheNotificationActions: false,
  maxStreamVolume: 1.5, // float
  style: App.configDir + "/style.css",
  windows: [
    // NOTE: the window will still render, if you don't pass it here
    // but if you don't, the window can't be toggled through App or cli
    exampleWindow,
  ],
};

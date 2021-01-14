Synopsis
```conf
http {
vhost_traffic_status_zone;

    ...

    server {

        ...

        location /status {
            vhost_traffic_status_display;
            vhost_traffic_status_display_format html;
        }
    }
}
```

Description

This is an Nginx module that provides access to virtual host status information. It contains the current status such as servers, upstreams, caches. This is similar to the live activity monitoring of nginx plus. The built-in html is also taken from the demo page of old version.

First of all, the directive vhost_traffic_status_zone is required, and then if the directive vhost_traffic_status_display is set, can be access to as follows:

 - /status/format/json
    If you request /status/format/json, will respond with a JSON document containing the current activity data for using in live dashboards and third-party monitoring tools.
 - /status/format/html
    If you request /status/format/html, will respond with the built-in live dashboard in HTML that requests internally to /status/format/json.
 - /status/format/jsonp
    If you request /status/format/jsonp, will respond with a JSONP callback function containing the current activity data for using in live dashboards and third-party monitoring tools.
 - /status/format/prometheus
    If you request /status/format/prometheus, will respond with a prometheus document containing the current activity data.
 - /status/control
    If you request /status/control, will respond with a JSON document after it reset or delete zones through a query string. See the Control.
   
[https://github.com/vozlt/nginx-module-vts](https://github.com/vozlt/nginx-module-vts)
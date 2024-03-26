# docker-logrotate

A multi-platform docker container of logrotate, can be used as a sidecar.

Docker image: [imroc/logrotate:latest]((https://hub.docker.com/repository/docker/imroc/logrotate/general).

## Configuration

For crond, you can configure it through the following environment variables:

| Environment      | Description                                    | Default                         |
| ---------------- | ---------------------------------------------- | ------------------------------- |
| `CRON_EXPR`      | cron expression for logrotate                  | `*/5 * * * *` (every 5 minutes) |
| `CROND_LOGLEVEL` | log level of crond, 0~8, 0 is the most verbose | 8                               |

For logrotate, you can directly mount `logrotate.conf` to `/etc/logrotate.conf`, or configure the following environment variables:

| Environment              | Description                              | Default |
| ------------------------ | ---------------------------------------- | ------- |
| `LOGROTATE_FILE_PATTERN` | the file pattern of logs                 |         |
| `LOGROTATE_FILESIZE`     | Files exceeding this size can be rotated | 50M     |
| `LOGROTATE_FILENUM`      | Number of files to keep rotating         | 5       |

## Example: Rotate the logs of nginx ingress controller

Configure `values.yaml` for [ingress-nginx](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx) helm chart:

```yaml
controller:
  config:
    access-log-path: /var/log/nginx/nginx_access.log
    error-log-path: /var/log/nginx/nginx_error.log
  extraVolumes:
    - name: log
      emptyDir: {}
  extraVolumeMounts:
    - name: log
      mountPath: /var/log/nginx
  extraContainers: # logrotate sidecar
    - name: logrotate
      image: imroc/logrotate:latest
      imagePullPolicy: IfNotPresent
      env:
        - name: LOGROTATE_FILE_PATTERN
          value: "/var/log/nginx/nginx_*.log"
        - name: LOGROTATE_FILESIZE
          value: "20M"
        - name: LOGROTATE_FILENUM
          value: "10"
        - name: CRON_EXPR
          value: "*/1 * * * *"
        - name: CROND_LOGLEVEL
          value: "7"
      volumeMounts:
        - name: log # share log directory
          mountPath: /var/log/nginx
```

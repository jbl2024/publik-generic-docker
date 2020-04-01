# Publik

Heavily inspired by https://github.com/IMIO/docker-teleservices

## Local installation

Update your hosts file (c:\Windows\System32\Drivers\etc\ on window, /etc/hosts elsewhere):

127.0.0.1	hobo.localhost authentic.localhost chrono.localhost combo.localhost agent-combo.localhost fargo.localhost passerelle.localhost wcs.localhost bijoe.localhost

```
$ docker-compose up
```

http://combo.localhost

Login / pwd : admin@localhost / admin

Note: no certificate/https available yet

## Convenient tools

- maildev: http://localhost:1080
- adminer: http://localhost:9000

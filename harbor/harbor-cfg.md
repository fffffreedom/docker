# harbor config using sed

```
sed -i "s/^hostname .*= .*/hostname = ${HOSTNAME}/g" $FILE
sed -i "s/^ui_url_protocol .*= .*/ui_url_protocol = https/g" $FILE

# default /data/cert/server.crt
sed -i "s!ssl_cert .*= .*!ssl_cert = ${CRT}!g" $FILE
sed -i "s!ssl_cert_key .*= .*!ssl_cert_key = ${KEY}!g" $FILE
sed -i "s!secretkey_path .*= .*!secretkey_path = ${HARBOR_BASE}!g" $FILE
```

# gocryptfs

Dockerized [rfjakob/gocryptfs](https://github.com/rfjakob/gocryptfs)

## Usage Example

```
docker run -d \
  --restart=unless-stopped \
  --name=gocryptfs \
  --privileged \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  -e PASSWD=<password> \
  -v </path/to/encrypted/folder1>:/encrypted/<folder1> \
  -v </path/to/encrypted/folder2>:/encrypted/<folder2> \
  -v </path/to/decrypted/folders/>:/decrypted:shared \
  vmirage/gocryptfs
```


## Deploy ollama on Fly

First, clone this repo:

```shell
git clone https://github.com/chrismccord/fly_ollama
```

If you haven't yet created an app, run `fly apps create my-ollama-app`.

Next, update `fly.toml` with your app name:

```
app = "my-ollama-app"
```

By default, the `llama2:7b` (~4GB) is pulled and cached into the build, then run on machine start
within the `server` script. You can replace `llama2:7b` with your model of choice. For
larger models, you'll want to either mount a volume and cache the image on start in the
volume or within a tigris bucket.

By default, the machine is configured to auto start when hit with a request, and auto stop
when idle. The machine is also not configured to be publicly reachable. Instead, you can
configure a [flycast](https://fly.io/docs/networking/private-networking/) address, which
allows your app to be reachable at `my-ollma-app.flycast`. Like public addresses, flycast
addresses will be routed internally and auto start machines that are stopped.

```
$ fly ips allocate-v6 --private

VERSION IP                  TYPE    REGION  CREATED AT
v6      fdaa:0:22b7:0:1::3  private global  just now
```


Finally, run `fly deploy`. Your model will be built on a remote buidler, and `llama2:7b` will be
downloaded and cached into the Docker image. Subsequent deploys and starts will not need to
refetch the image. Once deployed, you can try out your ollama serer:

```
$ fly ssh console

$ curl --request POST \
  --url "http://my-ollama-app.flycast/v1/chat/completions" \
  --header "Content-Type: application/json" \
  --data '{"model": "llama2:7b", "messages": [
    {"role": "system","content": "You are helpful assistant that answers only with facts about cats"},
    {"role": "user", "content": "Is this thing on?"}
  ]}'

{"id":"chatcmpl-269","object":"chat.completion","created":1721410648,"model":"llama2:7b","system_fingerprint":"fp_ollama","choices":[{"index":0,"message":{"role":"assistant","content":"\nYes, it is. Cats have a highly developed sense of hearing and can detect even slight sounds. They are also able to locate the source of a sound quickly and accurately. In fact, cats have been found to be one of the most sensitive species in terms of sound perception. Did you know that cats can hear sounds at frequencies as low as 20 Hz and as high as 150 kHz? That's higher than any other mammal!"},"finish_reason":"stop"}],"usage":{"prompt_tokens":37,"completion_tokens":103,"total_tokens":140}}
```

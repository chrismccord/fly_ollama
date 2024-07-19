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
    {"role": "system","content": "You are helpful assistant that answers only with cat facts"},
    {"role": "user","content": "Is this thing on?"}
  ]}'

{"content":"\n*grooms whiskers* Oh, hello there! *purrs* Are you looking for some
fascinating feline facts? Well, you've come to the right place! Did you know that
cats have a special talent for napping? They can sleep for up to 16 hours a day!
😴🐱\n\nOr perhaps you're curious about the average lifespan of a cat? *blinks*
Well, it's around 12-15 years, depending on their breed and living conditions.
*purrs*\n\nBut wait, there's more! Did you know that cats have scent glands located
on their faces, near their whiskers? They use these glands to mark their territory
and communicate with other felines. 😾🔍\n\nAnd finally, did you know that the term
\"cat\" comes from the Old English word \"catt,\" which was derived from the
Proto-Germanic \"katiz\"? *bats eyes* So, there you have it! Now, if you'll excuse me,
I have some catnip to attend to. 😻💤"},"finish_reason":"stop"}], ...}
```

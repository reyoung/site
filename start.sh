docker run -d -v $(pwd):/srv -p 80:80 -p 443:443 -e PORT=80 ludovicc/caddy-hugo

FROM nginx:alpine AS builder

COPY index.template.html /usr/share/nginx/html/index.template.html

FROM nginx:alpine

RUN apk add --no-cache curl

COPY --from=builder /usr/share/nginx/html/index.template.html /usr/share/nginx/html/index.template.html
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

CMD ["/entrypoint.sh"]

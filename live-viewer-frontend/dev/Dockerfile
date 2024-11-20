FROM nginx:alpine
COPY public /usr/share/nginx/html
RUN apk add rsync
CMD ["sh", "-c", "(nginx &); while true; do rsync -az --delete /app/ /usr/share/nginx/html/; sleep 1; done"]

FROM node:20-alpine AS build
RUN apk add --no-cache unzip curl
WORKDIR /app
RUN curl -L https://github.com/snowplow-incubator/snowplow-javascript-tracker-examples/archive/refs/heads/master.zip -o master.zip \
    && unzip master.zip \
    && rm master.zip
WORKDIR /app/snowplow-javascript-tracker-examples-master/react
RUN yarn install \
    && yarn build

FROM node:20-alpine
WORKDIR /app
COPY --from=build /app/snowplow-javascript-tracker-examples-master/react/build /app/build
RUN npm install -g serve
EXPOSE 3000
CMD ["serve", "-s", "build", "-l", "3000"]

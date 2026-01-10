FROM node:18 AS build
WORKDIR /app

COPY provedcode-frontend-vitya199909/package*.json ./
RUN npm install

COPY provedcode-frontend-vitya199909/ .
ARG REACT_APP_BASE_URL
ENV REACT_APP_BASE_URL=$REACT_APP_BASE_URL

RUN npm run build

# ---------- runtime stage ----------
FROM nginx:alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
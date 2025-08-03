FROM node:20-alpine3.19

# Argument & Environment Setup
ARG NEXT_PUBLIC_VERSION
ENV NEXT_PUBLIC_VERSION=$NEXT_PUBLIC_VERSION

# Install dependencies
RUN apk add --no-cache g++ make py3-pip bash nginx

# Create nginx user & working dirs
RUN adduser -D -g 'www' www
RUN mkdir /www
RUN chown -R www:www /var/lib/nginx && chown -R www:www /www

# Install pnpm & pm2
RUN npm --no-update-notifier --no-fund --global install pnpm@10.6.1 pm2

# App directory
WORKDIR /app

# Copy app files and nginx config
COPY . /app
COPY var/docker/nginx.conf /etc/nginx/nginx.conf

# Install and build
RUN pnpm install
RUN NODE_OPTIONS="--max-old-space-size=4096" pnpm run build

# Expose port for Koyeb (IMPORTANT!)
EXPOSE 4200

# Start the app and nginx
CMD ["sh", "-c", "nginx && pnpm run pm2"]
